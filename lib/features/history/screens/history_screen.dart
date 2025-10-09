// import 'package:flutter/material.dart';
// import 'package:learning_app/app/widgets/confirm_dialog.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import 'package:go_router/go_router.dart';

// import 'package:learning_app/features/home/providers/material_provider.dart';
// import 'package:learning_app/features/history/providers/attempt_provider.dart';
// import 'package:learning_app/core/models/attempt_model.dart';

// class HistoryScreen extends StatelessWidget {
//   const HistoryScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Riwayat Pengerjaan')),
//       body: Consumer<AttemptProvider>(
//         builder: (context, provider, child) {
//           if (provider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (provider.attempts.isEmpty) {
//             return const Center(child: Text('Belum ada riwayat pengerjaan'));
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(8.0),
//             itemCount: provider.attempts.length,
//             itemBuilder: (context, index) {
//               final attempt = provider.attempts[index];
//               return _buildAttemptCard(context, attempt);
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildAttemptCard(BuildContext context, Attempt attempt) {
//     final formattedDate = DateFormat(
//       'd MMMM yyyy, HH:mm',
//       'id_ID',
//     ).format(attempt.completedAt);
// final materialTitle =
//     context
//         .read<MaterialProvider>()
//         .materials
//         .where((m) => m.id == attempt.materialId)
//         .firstOrNull
//         ?.title ??
//     'Materi tidak ditemukan';

//     return Dismissible(
//       key: Key(attempt.id),
//       direction: DismissDirection.endToStart,
//       background: Container(
//         color: Colors.red,
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.symmetric(horizontal: 20.0),
//         child: const Icon(Icons.delete, color: Colors.white),
//       ),
//       onDismissed: (direction) {
//         context.read<AttemptProvider>().deleteAttempt(attempt.id);

//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('$materialTitle telah dihapus')));
//       },
//       confirmDismiss: (direction) async {
//         return await showConfirmDialog(
//           context,
//           title: 'Hapus Riwayat?',
//           content:
//               'Apakah anda yakin ingin menghapus riwayat pengerjaan "$materialTitle"?',
//         );
//       },
//       child: Card(
//         margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//         child: ListTile(
//           title: Text(materialTitle),
//           subtitle: Text('Selesai pada: $formattedDate'),
//           trailing: Text(
//             'Skor: ${attempt.score}',
//             style: Theme.of(context).textTheme.titleMedium,
//           ),
//           onTap: () {
//             context.go('/history/overview/${attempt.id}');
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'package:learning_app/app/widgets/confirm_dialog.dart';
import 'package:learning_app/features/home/providers/material_provider.dart';
import 'package:learning_app/features/history/providers/attempt_provider.dart';
import 'package:learning_app/core/models/attempt_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Pengerjaan',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Consumer<AttemptProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.attempts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.attempts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_edu_outlined,
                      size: 80,
                      color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Riwayat masih kosong',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selesaikan sebuah materi untuk melihat riwayat pengerjaan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.attempts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final attempt = provider.attempts[index];
              return _buildAttemptCard(context, attempt);
            },
          );
        },
      ),
    );
  }

  Widget _buildAttemptCard(BuildContext context, Attempt attempt) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formattedDate = DateFormat(
      'd MMMM yyyy, HH:mm',
      'id_ID',
    ).format(attempt.completedAt);
    final materialTitle =
        context
            .read<MaterialProvider>()
            .materials
            .where((m) => m.id == attempt.materialId)
            .firstOrNull
            ?.title ??
        'Materi tidak ditemukan';

    return Dismissible(
      key: Key(attempt.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: colorScheme.onErrorContainer),
            const SizedBox(width: 8),
            Text(
              'Hapus',
              style: TextStyle(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        context.read<AttemptProvider>().deleteAttempt(attempt.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$materialTitle telah dihapus'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      confirmDismiss: (direction) async {
        return await showConfirmDialog(
          context,
          title: 'Hapus Riwayat ?',
          content:
              'Apakah anda yakin ingin menghapus riwayat pengerjaan "$materialTitle"?',
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 2,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.go('/history/overview/${attempt.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        materialTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formattedDate,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('SKOR', style: theme.textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Text(
                      attempt.score.toString(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
