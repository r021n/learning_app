// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:learning_app/app/widgets/confirm_dialog.dart';
// import 'package:learning_app/features/history/providers/attempt_provider.dart';
// import 'package:learning_app/features/overview/providers/sync_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:learning_app/core/models/attempt_model.dart';
// import 'package:learning_app/core/models/material_model.dart' as mt;
// import 'package:learning_app/core/repositories/local_storage_repository.dart';

// class OverviewScreen extends StatefulWidget {
//   final String attemptId;
//   const OverviewScreen({super.key, required this.attemptId});

//   @override
//   State<OverviewScreen> createState() => _OverviewScreenState();
// }

// class _OverviewScreenState extends State<OverviewScreen> {
//   Attempt? _attempt;
//   mt.Material? _material;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   void _loadData() {
//     final repo = context.read<LocalStorageRepository>();
//     _attempt = repo.getAttemptById(widget.attemptId);
//     if (_attempt != null) {
//       _material = repo.getMaterialById(_attempt!.materialId);
//     }
//     setState(() => _isLoading = false);
//   }

//   Future<void> _handleDelete() async {
//     final confirmed = await showConfirmDialog(
//       context,
//       title: 'Hapus Riwayat',
//       content: 'Apakah anda yakin ingin menghapus riwayat pekerjaan ini?',
//     );

//     if (confirmed == true && mounted) {
//       await context.read<AttemptProvider>().deleteAttempt(widget.attemptId);

//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Riwayat telah dihapus')));

//       context.pop();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     if (_attempt == null || _material == null) {
//       return Scaffold(
//         appBar: AppBar(),
//         body: const Center(child: Text('Data pengerjaan tidak ditemukan')),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Hasil Pengerjaan'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete_outline),
//             onPressed: _handleDelete,
//             tooltip: 'Hapus Riwayat',
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildScoreCard(),
//             const SizedBox(height: 24.0),
//             _buildTopicList(
//               context,
//               '✔️ Hal yang Dikuasai',
//               _attempt!.masteredTopics,
//               Colors.green,
//             ),
//             const SizedBox(height: 16.0),
//             _buildTopicList(
//               context,
//               '❌ Hal yang Perlu Ditingkatkan',
//               _attempt!.unmasteredTopics,
//               Colors.red,
//             ),
//             const SizedBox(height: 24.0),
//             Text(
//               'Rincian Jawaban',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const Divider(),
//             _buildQnAList(),
//           ],
//         ),
//       ),
//       bottomNavigationBar: _buildSyncButton(),
//     );
//   }

//   Widget _buildScoreCard() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           children: [
//             Text('Total Skor', style: Theme.of(context).textTheme.titleMedium),
//             Text(
//               _attempt!.score.toString(),
//               style: Theme.of(context).textTheme.displayLarge,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTopicList(
//     BuildContext context,
//     String title,
//     List<String> topics,
//     Color color,
//   ) {
//     if (topics.isEmpty) return const SizedBox.shrink();
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title, style: Theme.of(context).textTheme.titleLarge),
//         const SizedBox(height: 8),
//         ...topics.map(
//           (topic) => Card(
//             color: color.withValues(alpha: 0.1),
//             child: ListTile(
//               leading: Icon(Icons.check_circle_outline, color: color),
//               title: Text(topic),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildQnAList() {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: _material!.questions.length,
//       itemBuilder: (context, index) {
//         final question = _material!.questions[index];
//         final answer = _attempt!.userAnswers[index];

//         return Card(
//           margin: const EdgeInsets.symmetric(vertical: 8),
//           child: ExpansionTile(
//             title: Text(
//               'Pertanyaan ${index + 1}',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             subtitle: Text(
//               question.questionText,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Pertanyaan Lengkap: ',
//                       style: Theme.of(context).textTheme.bodySmall,
//                     ),
//                     Text(
//                       question.questionText,
//                       style: Theme.of(context).textTheme.bodyLarge,
//                     ),
//                     const Divider(height: 24),
//                     Text(
//                       'Jawaban Anda',
//                       style: Theme.of(context).textTheme.bodySmall,
//                     ),
//                     Text(
//                       answer.isEmpty ? '(Tidak dijawab)' : answer,
//                       style: Theme.of(context).textTheme.bodyLarge,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSyncButton() {
//     final isSyncing = context.watch<SyncProvider>().isSyncing;

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: ElevatedButton.icon(
//         icon: isSyncing
//             ? const SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: CircularProgressIndicator(color: Colors.white),
//               )
//             : const Icon(Icons.sync),
//         label: Text(isSyncing ? 'Menyinkronkan...' : 'Kembali & Sinkronkan'),
//         onPressed: isSyncing
//             ? null
//             : () async {
//                 final syncProvider = context.read<SyncProvider>();
//                 final success = await syncProvider.syncAllUsynced();

//                 if (mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         success
//                             ? 'Data berhasil disinkronkan'
//                             : 'Beberapa data gagal disinkronkan.',
//                       ),
//                       backgroundColor: success ? Colors.green : Colors.orange,
//                     ),
//                   );
//                   context.go('/home');
//                 }
//               },
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(vertical: 16.0),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:learning_app/app/widgets/confirm_dialog.dart';
import 'package:learning_app/features/history/providers/attempt_provider.dart';
import 'package:learning_app/features/overview/providers/sync_provider.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final repo = context.read<LocalStorageRepository>();
    _attempt = repo.getAttemptById(widget.attemptId);
    if (_attempt != null) {
      _material = repo.getMaterialById(_attempt!.materialId);
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus Riwayat?',
      content: 'Apakah anda yakin ingin menghapus riwayat pengerjaan ini?',
    );

    if (confirmed == true && mounted) {
      await context.read<AttemptProvider>().deleteAttempt(widget.attemptId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Riwayat pengerjaan telah dihapus'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_attempt == null || _material == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outlined,
                  size: 80,
                  color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Data tidak ditemukan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tidak dapat memuat rincian untuk pengerjaan ini. Mungkin data telah dihapus.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hasil Pengerjaan',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _handleDelete,
            tooltip: 'Hapus Riwayat',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildScoreHeader(context),
            const SizedBox(height: 32),
            _buildTopicsSection(
              context,
              'Hal yang dikuasai',
              _attempt!.masteredTopics,
              Icons.check_circle_outline,
              theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            _buildTopicsSection(
              context,
              'Hal yang perlu ditingkatkan',
              _attempt!.unmasteredTopics,
              Icons.highlight_off_outlined,
              theme.colorScheme.error,
            ),
            const SizedBox(height: 32),
            Text(
              'Tinjauan Jawaban',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildQnAList(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildSyncButton(context),
    );
  }

  Widget _buildScoreHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final score = _attempt!.score;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            Text(
              _material!.title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 10,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                  Center(
                    child: Text(
                      score.toString(),
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total Skor Anda',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicsSection(
    BuildContext context,
    String title,
    List<String> topics,
    IconData icon,
    Color color,
  ) {
    if (topics.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: topics.map((topic) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      topic,
                      style: theme.textTheme.bodyMedium?.copyWith(color: color),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQnAList(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _material!.questions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final question = _material!.questions[index];
        final userAnswer = _attempt!.userAnswers[index];
        final feedback = _attempt!.feedback[index];

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
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
            leading: Icon(Icons.circle, color: theme.colorScheme.primary),
            children: [
              Container(
                color: theme.scaffoldBackgroundColor,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Pertanyaan: ', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text(
                      question.questionText,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const Divider(height: 24),
                    Text('Jawaban Anda', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text(
                      userAnswer.isEmpty ? '(Tidak dijawab)' : userAnswer,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const Divider(height: 24),
                    Text('Feedback', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text(
                      feedback,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
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

  Widget _buildSyncButton(BuildContext context) {
    final isSyncing = context.watch<SyncProvider>().isSyncing;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: ElevatedButton.icon(
        icon: isSyncing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.sync),
        label: Text(isSyncing ? 'Menyinkronkan...' : 'Selesai & Sinkronkan'),
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
                            : 'Beberapa data gagal disinkronkan',
                      ),
                      backgroundColor: success ? Colors.green : Colors.orange,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.go('/home');
                }
              },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
