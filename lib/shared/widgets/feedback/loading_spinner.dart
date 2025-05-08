import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';

/// Size options for the loading spinner
enum LoadingSpinnerSize {
  /// Small spinner for inline use
  small,

  /// Medium spinner for most use cases
  medium,

  /// Large spinner for full-screen loading states
  large,
}

/// A customizable loading spinner component that follows the application theme.
class LoadingSpinner extends StatefulWidget {
  /// The size of the spinner
  final LoadingSpinnerSize size;

  /// The color of the spinner. If null, uses the app's accent color.
  final Color? color;

  /// The animation duration in milliseconds
  final int animationDuration;

  /// Optional text to display below the spinner
  final String? label;

  /// Whether the spinner should grow and shrink as it spins
  final bool pulsing;

  /// Creates a loading spinner with customizable properties.
  const LoadingSpinner({
    Key? key,
    this.size = LoadingSpinnerSize.medium,
    this.color,
    this.animationDuration = 1200,
    this.label,
    this.pulsing = false,
  }) : super(key: key);

  @override
  State<LoadingSpinner> createState() => _LoadingSpinnerState();
}

class _LoadingSpinnerState extends State<LoadingSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.animationDuration),
    );

    if (widget.pulsing) {
      _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );
    } else {
      _animation = const AlwaysStoppedAnimation<double>(1.0);
    }

    _controller.repeat(reverse: widget.pulsing);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spinnerSize = _getSpinnerSize();
    final spinnerColor = widget.color ?? AppColors.active;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _animation,
          child: RotationTransition(
            turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
            child: SizedBox(
              width: spinnerSize,
              height: spinnerSize,
              child: CircularProgressIndicator(
                strokeWidth: _getStrokeWidth(),
                valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
              ),
            ),
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(height: 8.0),
          Text(
            widget.label!,
            style: TextStyle(
              color: spinnerColor,
              fontSize: _getLabelSize(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  double _getSpinnerSize() {
    switch (widget.size) {
      case LoadingSpinnerSize.small:
        return 16.0;
      case LoadingSpinnerSize.medium:
        return 32.0;
      case LoadingSpinnerSize.large:
        return 48.0;
    }
  }

  double _getStrokeWidth() {
    switch (widget.size) {
      case LoadingSpinnerSize.small:
        return 2.0;
      case LoadingSpinnerSize.medium:
        return 3.0;
      case LoadingSpinnerSize.large:
        return 4.0;
    }
  }

  double _getLabelSize() {
    switch (widget.size) {
      case LoadingSpinnerSize.small:
        return 12.0;
      case LoadingSpinnerSize.medium:
        return 14.0;
      case LoadingSpinnerSize.large:
        return 16.0;
    }
  }
} 