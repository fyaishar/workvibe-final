import 'package:flutter/material.dart';
import 'component_showcase.dart';

/// Entry point screen for the UI component showcase.
/// This allows us to integrate the showcase into the main app navigation.
class ShowcaseScreen extends StatelessWidget {
  const ShowcaseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ComponentShowcase();
  }
} 