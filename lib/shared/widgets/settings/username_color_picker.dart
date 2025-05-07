import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to hold the current username color
final usernameColorProvider = StateProvider<Color>((ref) => UsernameColors.white);

class UsernameColorPicker extends ConsumerWidget {
  const UsernameColorPicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentColor = ref.watch(usernameColorProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text('Choose Username Color', 
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: UsernameColors.getAllColors().entries.map((entry) {
            final isSelected = currentColor == entry.value;
            return GestureDetector(
              onTap: () {
                // Update the provider state
                ref.read(usernameColorProvider.notifier).state = entry.value;
                // Update the static color in UsernameColors
                UsernameColors.setColor(entry.value);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: entry.value,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ] : null,
                ),
                child: isSelected 
                  ? const Icon(Icons.check, color: Colors.black54, size: 20)
                  : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
} 