import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/text_styles.dart';

/// Types of progress indicators
enum ProgressIndicatorType {
  /// Linear progress bar
  linear,
  
  /// Circular progress indicator
  circular,
}

/// A customizable progress indicator component.
class ProgressDisplay extends StatelessWidget {
  /// The value of the progress (0.0 to 1.0)
  final double? value;
  
  /// Type of progress indicator to display
  final ProgressIndicatorType type;
  
  /// Optional label to show
  final String? label;
  
  /// Optional percentage to display
  final bool showPercentage;
  
  /// Optional estimated time remaining text
  final String? timeRemaining;
  
  /// Optional description of the operation
  final String? description;
  
  /// Color of the progress indicator. If null, uses the app's accent color.
  final Color? color;
  
  /// Width/height of the progress indicator
  final double size;
  
  /// Stroke width for circular indicators
  final double strokeWidth;
  
  /// Creates a progress indicator with customizable properties.
  const ProgressDisplay({
    Key? key,
    this.value,
    this.type = ProgressIndicatorType.linear,
    this.label,
    this.showPercentage = false,
    this.timeRemaining,
    this.description,
    this.color,
    this.size = 200.0,
    this.strokeWidth = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progressColor = color ?? AppColors.active;
    final bool isDeterminate = value != null;
    final displayPercentage = isDeterminate && showPercentage 
        ? '${(value! * 100).toInt()}%' 
        : null;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label and percentage
        if (label != null || displayPercentage != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              if (displayPercentage != null)
                Text(
                  displayPercentage,
                  style: TextStyle(
                    color: progressColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          const SizedBox(height: Spacing.small),
        ],
        
        // Progress Indicator
        if (type == ProgressIndicatorType.linear) ...[
          LinearProgressIndicator(
            value: value,
            backgroundColor: progressColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 8.0,
          ),
        ] else ...[
          // Circular indicator
          Center(
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // The progress indicator
                  CircularProgressIndicator(
                    value: value,
                    backgroundColor: progressColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    strokeWidth: strokeWidth,
                  ),
                  
                  // Percentage in the center for circular indicators
                  if (displayPercentage != null)
                    Text(
                      displayPercentage,
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.w700,
                        fontSize: size / 5, // Scale text based on indicator size
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        
        // Description text
        if (description != null) ...[
          const SizedBox(height: Spacing.small),
          Text(
            description!,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 13,
            ),
          ),
        ],
        
        // Time remaining
        if (timeRemaining != null) ...[
          const SizedBox(height: Spacing.small),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: AppColors.secondaryText,
              ),
              const SizedBox(width: 4),
              Text(
                timeRemaining!,
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
} 