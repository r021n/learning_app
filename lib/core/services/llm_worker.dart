import 'dart:isolate';
import 'package:cactus/cactus.dart';

class WorkerRequest {
  final int id;
  final String prompt;
  WorkerRequest(this.id, this.prompt);
}

class WorkerResponse {
  final int id;
  final String result;
  WorkerResponse(this.id, this.result);
}

Future<void> llmWorkerEntryPoint(Map<String, dynamic> args) async {
  final mainSendPort = args['sendPort'] as SendPort;
  final localModelPath = args['modelPath'] as String;
  final workerReceivePort = ReceivePort();
  CactusLM? lm;

  mainSendPort.send(workerReceivePort.sendPort);

  try {
    lm = await CactusLM.init(
      modelUrl: localModelPath,
      contextSize: 2048,
      threads: 4,
      gpuLayers: 0,
      onProgress: (progress, status, isError) {
        mainSendPort.send({
          'type': 'progress',
          'progress': progress,
          'status': status,
        });
      },
    );

    mainSendPort.send(true);
  } catch (e) {
    mainSendPort.send(false);
    return;
  }

  await for (final message in workerReceivePort) {
    if (message is WorkerRequest) {
      try {
        final result = await lm.completion(
          [ChatMessage(role: 'user', content: message.prompt)],
          maxTokens: 500,
          temperature: 0.7,
        );

        final startIndex = result.text.indexOf('{');
        final endIndex = result.text.indexOf('}');
        if (startIndex != -1 && endIndex != -1) {
          // Adjusting substring to include the closing brace '}'
          final cleanJson = result.text.substring(startIndex, endIndex + 1);
          mainSendPort.send(WorkerResponse(message.id, cleanJson));
        } else {
          mainSendPort.send(WorkerResponse(message.id, '{}'));
        }
      } catch (e) {
        mainSendPort.send(WorkerResponse(message.id, '{"error": "$e"}'));
      }
    } else if (message == 'SHUTDOWN') {
      break;
    }
  }

  lm.dispose();
  workerReceivePort.close();
  Isolate.exit();
}
