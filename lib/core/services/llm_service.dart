import 'dart:async';
import 'dart:isolate';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:learning_app/core/services/llm_worker.dart';

class LlmService {
  Isolate? _isolate;
  late final ReceivePort _mainReceivePort;
  SendPort? _workerSendPort;
  int _requestIdCounter = 0;
  final Map<int, Completer<String>> _activeRequests = {};

  final Completer<bool> _isInitialized = Completer<bool>();
  Future<bool> get isInitialized => _isInitialized.future;

  Future<void> initialize() async {
    _mainReceivePort = ReceivePort();
    try {
      final modelPath = await _copyModelFromAssets();

      final workerArgs = {
        'sendPort': _mainReceivePort.sendPort,
        'modelPath': modelPath,
        'rootIsolateToken': RootIsolateToken.instance!,
      };

      _isolate = await Isolate.spawn(llmWorkerEntryPoint, workerArgs);
      _mainReceivePort.listen((_handleMessagesFromWorker));
    } catch (e) {
      print('Gagal menginisialisasi LlmService: $e');
      _isInitialized.completeError(
        'Gagal menyalin model atau spawn isolate: $e',
      );
    }
  }

  void _handleMessagesFromWorker(dynamic message) {
    if (message is SendPort) {
      _workerSendPort = message;
    } else if (message is bool) {
      if (message) {
        _isInitialized.complete(true);
        print('LlmService: Worker Isolate siap.');
      } else {
        _isInitialized.completeError(
          'Gagal menginisialisasi model di worker isolate',
        );
      }
    } else if (message is WorkerResponse) {
      final completer = _activeRequests[message.id];
      if (completer != null) {
        completer.complete(message.result);
        _activeRequests.remove(message.id);
      }
    }
  }

  Future<String> run(String prompt) async {
    await isInitialized;

    final id = _requestIdCounter++;
    final completer = Completer<String>();
    _activeRequests[id] = completer;

    _workerSendPort?.send(WorkerRequest(id, prompt));

    return completer.future;
  }

  void dispose() {
    _workerSendPort?.send('SHUTDOWN');
    _mainReceivePort.close();
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
  }

  Future<String> _copyModelFromAssets() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final localModelPath = '${appDocDir.path}/gemma3-1b-instruct.gguf';

      final localFile = File(localModelPath);
      if (await localFile.exists()) {
        print('Model sudah ada di local storage: $localModelPath');
        return localModelPath;
      }

      print('Menyalin model dari assets ke local storage...');

      final byteData = await rootBundle.load(
        'assets/models/gemma3-1b-instruct.gguf',
      );
      final buffer = byteData.buffer;

      await localFile.writeAsBytes(buffer.asUint8List());
      print('Model berhasil disalin ke: $localModelPath');
      return localModelPath;
    } catch (e) {
      print('Gagal menyalin model dari assets: $e');
      rethrow;
    }
  }
}
