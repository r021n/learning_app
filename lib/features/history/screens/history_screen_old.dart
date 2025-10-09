import 'package:flutter/material.dart';
import 'package:learning_app/app/widgets/confirm_dialog.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'package:learning_app/features/home/providers/material_provider.dart';
import 'package:learning_app/features/history/providers/attempt_provider.dart';
import 'package:learning_app/core/models/attempt_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pengerjaan')),
      body: Consumer<AttemptProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.attempts.isEmpty) {
            return const Center(child: Text('Belum ada riwayat pengerjaan'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: provider.attempts.length,
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
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        context.read<AttemptProvider>().deleteAttempt(attempt.id);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$materialTitle telah dihapus')));
      },
      confirmDismiss: (direction) async {
        return await showConfirmDialog(
          context,
          title: 'Hapus Riwayat?',
          content:
              'Apakah anda yakin ingin menghapus riwayat pengerjaan "$materialTitle"?',
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          title: Text(materialTitle),
          subtitle: Text('Selesai pada: $formattedDate'),
          trailing: Text(
            'Skor: ${attempt.score}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          onTap: () {
            context.go('/history/overview/${attempt.id}');
          },
        ),
      ),
    );
  }
}
