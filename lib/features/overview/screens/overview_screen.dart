import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_app/app/widgets/confirm_dialog.dart';
import 'package:learning_app/features/history/providers/attempt_provider.dart';
import 'package:learning_app/features/overview/providers/sync_provider.dart';
import 'package:provider/provider.dart';
import 'package:learning_app/core/models/attempt_model.dart';
import 'package:learning_app/core/models/material_model.dart' as mt;
import 'package:learning_app/core/repositories/local_storage_repository.dart';

class OverviewScreen extends StatefulWidget {
  final String attemptId;
  const OverviewScreen({super.key, required this.attemptId});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  Attempt? _attempt;
  mt.Material? _material;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final repo = context.read<LocalStorageRepository>();
    _attempt = repo.getAttemptById(widget.attemptId);
    if (_attempt != null) {
      _material = repo.getMaterialById(_attempt!.materialId);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _handleDelete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus Riwayat',
      content: 'Apakah anda yakin ingin menghapus riwayat pekerjaan ini?',
    );

    if (confirmed == true && mounted) {
      await context.read<AttemptProvider>().deleteAttempt(widget.attemptId);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Riwayat telah dihapus')));

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_attempt == null || _material == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Data pengerjaan tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Pengerjaan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _handleDelete,
            tooltip: 'Hapus Riwayat',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildScoreCard(),
            const SizedBox(height: 24.0),
            _buildTopicList(
              context,
              '✔️ Hal yang Dikuasai',
              _attempt!.masteredTopics,
              Colors.green,
            ),
            const SizedBox(height: 16.0),
            _buildTopicList(
              context,
              '❌ Hal yang Perlu Ditingkatkan',
              _attempt!.unmasteredTopics,
              Colors.red,
            ),
            const SizedBox(height: 24.0),
            Text(
              'Rincian Jawaban',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            _buildQnAList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildSyncButton(),
    );
  }

  Widget _buildScoreCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Total Skor', style: Theme.of(context).textTheme.titleMedium),
            Text(
              _attempt!.score.toString(),
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicList(
    BuildContext context,
    String title,
    List<String> topics,
    Color color,
  ) {
    if (topics.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...topics.map(
          (topic) => Card(
            color: color.withValues(alpha: 0.1),
            child: ListTile(
              leading: Icon(Icons.check_circle_outline, color: color),
              title: Text(topic),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQnAList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _material!.questions.length,
      itemBuilder: (context, index) {
        final question = _material!.questions[index];
        final answer = _attempt!.userAnswers[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ExpansionTile(
            title: Text(
              'Pertanyaan ${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              question.questionText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pertanyaan Lengkap: ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      question.questionText,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Divider(height: 24),
                    Text(
                      'Jawaban Anda',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      answer.isEmpty ? '(Tidak dijawab)' : answer,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSyncButton() {
    final isSyncing = context.watch<SyncProvider>().isSyncing;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        icon: isSyncing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white),
              )
            : const Icon(Icons.sync),
        label: Text(isSyncing ? 'Menyinkronkan...' : 'Kembali & Sinkronkan'),
        onPressed: isSyncing
            ? null
            : () async {
                final syncProvider = context.read<SyncProvider>();
                final success = await syncProvider.syncAllUsynced();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Data berhasil disinkronkan'
                            : 'Beberapa data gagal disinkronkan.',
                      ),
                      backgroundColor: success ? Colors.green : Colors.orange,
                    ),
                  );
                  context.go('/home');
                }
              },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
      ),
    );
  }
}
