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
    final materialProvider = context.read<MaterialProvider>();
    final isOnline = context.read<ConnectivityProvider>().isOnline;

    final success = await materialProvider.syncMaterials(isOnline: isOnline);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(materialProvider.errorMessage ?? 'Gagal sinkronisasi'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
            icon: const Icon(Icons.logout),
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
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Tidak ada materi tersedia. Coba tarik ke bawah untuk menyegarkan',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: provider.materials.length,
              itemBuilder: (context, index) {
                final material = provider.materials[index];
                return MaterialCard(material: material);
              },
            );
          },
        ),
      ),
    );
  }
}
