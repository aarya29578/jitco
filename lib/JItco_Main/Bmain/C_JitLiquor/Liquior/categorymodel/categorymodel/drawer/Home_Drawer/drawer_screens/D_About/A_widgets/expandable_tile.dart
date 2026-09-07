import 'package:flutter/material.dart';

class ExpandableTile extends StatelessWidget {
  final String title;
  final String description;
  final String keys;
  final List<String> features;
  final bool isExpanded; // <-- external control
  final VoidCallback onTap; // <-- notify parent

  const ExpandableTile({
    super.key,
    required this.title,
    required this.description,
    required this.keys,
    required this.features,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[700],
                    ),
                  ),
                ),

                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
              ],
            ),
          ),

          if (isExpanded) ...[
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 18),
            Text(
              keys,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                features.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    "${i + 1}) ${features[i]}",
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
