import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_app/core/models/material_model.dart' as mt;

class MaterialCard extends StatelessWidget {
  final mt.Material material;

  const MaterialCard({required this.material, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.go('/quiz/${material.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                material.title,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16.0),
                  const SizedBox(width: 4),
                  Text('${material.durationInMinutes} Menit'),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 16.0),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
