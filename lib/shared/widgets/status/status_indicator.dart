import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';

/// Type of status indicator displayed.
enum StatusIndicatorType {
  /// Red indicator for active users
  active,
  
  /// Gray indicator for users on break
  break_,
  
  /// Darker gray for idle users
  idle,
  
  /// Green for successful operations
  success,
  
  /// Yellow for warnings or pending operations
  warning,
  
  /// Red for errors or failed operations
  error,
}

/// Status indicator sizes.
enum StatusIndicatorSize {
  /// Small indicator (8px)
  small,
  
  /// Regular indicator (10px)
  regular,
  
  /// Large indicator (12px)
  large,
}

/// A circular indicator to show status visually.
class StatusIndicator extends StatelessWidget {
  /// The type of status to display.
  final StatusIndicatorType type;
  
  /// The size of the indicator.
  final StatusIndicatorSize size;
  
  /// Whether to pulse/animate the indicator.
  final bool pulsing;
  
  /// Optional label to display next to the indicator.
  final String? label;
  
  /// Text style for the label.
  final TextStyle? labelStyle;

  const StatusIndicator({
    Key? key,
    required this.type,
    this.size = StatusIndicatorSize.regular,
    this.pulsing = false,
    this.label,
    this.labelStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        pulsing 
            ? _buildPulsingIndicator() 
            : _buildStaticIndicator(),
        if (label != null) ...[
          const SizedBox(width: Spacing.small),
          Text(
            label!,
            style: _getLabelStyle(),
          ),
        ],
      ],
    );
  }
  
  /// Gets the appropriate color for the indicator based on type.
  Color _getColor() {
    switch (type) {
      case StatusIndicatorType.active:
        return AppColors.active;
      case StatusIndicatorType.break_:
        return AppColors.break_;
      case StatusIndicatorType.idle:
        return AppColors.idle;
      case StatusIndicatorType.success:
        return AppColors.success;
      case StatusIndicatorType.warning:
        return AppColors.warning;
      case StatusIndicatorType.error:
        return AppColors.error;
    }
  }
  
  /// Gets the appropriate text style for the label based on type.
  TextStyle _getLabelStyle() {
    if (labelStyle != null) return labelStyle!;
    
    switch (type) {
      case StatusIndicatorType.active:
        return const TextStyle(color: AppColors.activeText);
      case StatusIndicatorType.break_:
        return const TextStyle(color: AppColors.breakText);
      case StatusIndicatorType.idle:
        return const TextStyle(color: AppColors.idleText);
      case StatusIndicatorType.success:
        return const TextStyle(color: AppColors.success);
      case StatusIndicatorType.warning:
        return const TextStyle(color: AppColors.warning);
      case StatusIndicatorType.error:
        return const TextStyle(color: AppColors.error);
    }
  }
  
  /// Gets the appropriate size in pixels for the indicator.
  double _getSize() {
    switch (size) {
      case StatusIndicatorSize.small:
        return Spacing.statusIndicatorSmall;
      case StatusIndicatorSize.regular:
        return Spacing.statusIndicatorSize;
      case StatusIndicatorSize.large:
        return Spacing.statusIndicatorLarge;
    }
  }
  
  /// Builds a static (non-animated) indicator.
  Widget _buildStaticIndicator() {
    return Container(
      width: _getSize(),
      height: _getSize(),
      decoration: BoxDecoration(
        color: _getColor(),
        shape: BoxShape.circle,
      ),
    );
  }
  
  /// Builds a pulsing animated indicator.
  Widget _buildPulsingIndicator() {
    return SizedBox(
      width: _getSize(),
      height: _getSize(),
      child: _PulsingIndicator(
        color: _getColor(),
      ),
    );
  }
}

/// A widget that displays a pulsing animation for status indicators.
class _PulsingIndicator extends StatefulWidget {
  final Color color;

  const _PulsingIndicator({
    Key? key,
    required this.color,
  }) : super(key: key);

  @override
  _PulsingIndicatorState createState() => _PulsingIndicatorState();
}

class _PulsingIndicatorState extends State<_PulsingIndicator> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(_animation.value),
          ),
        );
      },
    );
  }
} 