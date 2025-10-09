// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'package:learning_app/features/auth/providers/auth_provider.dart';
// import 'package:learning_app/features/home/providers/material_provider.dart';
// import 'package:learning_app/core/providers/connectivity_provider.dart';

// import 'package:learning_app/features/home/widgets/material_card.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _syncData();
//     });
//   }

//   Future<void> _syncData() async {
//     final materialProvider = context.read<MaterialProvider>();
//     final isOnline = context.read<ConnectivityProvider>().isOnline;

//     final success = await materialProvider.syncMaterials(isOnline: isOnline);
//     if (!success && mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(materialProvider.errorMessage ?? 'Gagal sinkronisasi'),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//         actions: [
//           IconButton(
//             onPressed: () {
//               context.read<AuthProvider>().logout();
//             },
//             icon: const Icon(Icons.logout),
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: _syncData,
//         child: Consumer<MaterialProvider>(
//           builder: (context, provider, child) {
//             if (provider.isLoading && provider.materials.isEmpty) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             if (provider.materials.isEmpty) {
//               return const Center(
//                 child: Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Text(
//                     'Tidak ada materi tersedia. Coba tarik ke bawah untuk menyegarkan',
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               );
//             }

//             return GridView.builder(
//               padding: const EdgeInsets.all(16.0),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 childAspectRatio: 1.2,
//               ),
//               itemCount: provider.materials.length,
//               itemBuilder: (context, index) {
//                 final material = provider.materials[index];
//                 return MaterialCard(material: material);
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:learning_app/features/auth/providers/auth_provider.dart';
import 'package:learning_app/features/home/providers/material_provider.dart';
import 'package:learning_app/core/providers/connectivity_provider.dart';

import 'package:learning_app/features/home/widgets/material_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncData();
    });
  }

  Future<void> _syncData() async {
    if (!mounted) return;
    final materialProvider = context.read<MaterialProvider>();
    final isOnline = context.read<ConnectivityProvider>().isOnline;

    final success = await materialProvider.syncMaterials(isOnline: isOnline);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(materialProvider.errorMessage ?? 'Gagal Sinkronisasi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userName =
        context.watch<AuthProvider>().currentUser?.email ?? "Pengguna";

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onSurface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              userName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _syncData,
        child: Consumer<MaterialProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.materials.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.materials.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 80,
                        color: theme.colorScheme.secondary.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada materi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tarik ke bawah untuk mencoba memuat ulang materi yang tersedia',
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

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Pilih Materi Belajar',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: provider.materials.length,
                    itemBuilder: (context, index) {
                      final material = provider.materials[index];
                      return MaterialCard(material: material);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
