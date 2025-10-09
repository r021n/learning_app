// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:learning_app/core/models/material_model.dart' as mt;

// class MaterialCard extends StatelessWidget {
//   final mt.Material material;

//   const MaterialCard({required this.material, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         onTap: () {
//           context.go('/quiz/${material.id}');
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 material.title,
//                 style: Theme.of(context).textTheme.titleLarge,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const Spacer(),
//               Row(
//                 children: [
//                   const Icon(Icons.timer_outlined, size: 16.0),
//                   const SizedBox(width: 4),
//                   Text('${material.durationInMinutes} Menit'),
//                   const Spacer(),
//                   const Icon(Icons.arrow_forward_ios, size: 16.0),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_app/core/models/material_model.dart' as mt;

class MaterialCard extends StatelessWidget {
  final mt.Material material;

  const MaterialCard({required this.material, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final cardColor = [
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
    ];

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 4,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
      child: InkWell(
        onTap: () {
          context.push('/quiz/${material.id}');
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: cardColor,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.science_outlined,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      material.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: colorScheme.onPrimaryContainer.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${material.durationInMinutes} Menit',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
