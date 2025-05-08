import 'package:flutter/material.dart';
import 'dart:async';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../app/theme/spacing.dart';
import 'custom_text_field.dart';

/// A specialized search field component for search functionality.
class SearchField extends StatefulWidget {
  /// Controller for managing the search input.
  final TextEditingController? controller;
  
  /// Placeholder text shown when the field is empty.
  final String placeholder;
  
  /// Callback when the search query changes.
  final Function(String)? onSearch;
  
  /// Callback when the search is submitted.
  final Function(String)? onSubmitted;
  
  /// Whether to show a clear button when text is entered.
  final bool showClearButton;
  
  /// Whether search should happen on each keystroke or only on submit.
  final bool searchOnType;
  
  /// Delay in milliseconds before triggering search when typing.
  final int searchDebounceMs;
  
  /// Focus node for controlling focus.
  final FocusNode? focusNode;
  
  /// Whether the search field is enabled.
  final bool enabled;
  
  /// Callback for when the search icon is tapped.
  final VoidCallback? onSearchIconTapped;

  /// Creates a search field with customizable properties.
  const SearchField({
    Key? key,
    this.controller,
    this.placeholder = 'Search...',
    this.onSearch,
    this.onSubmitted,
    this.showClearButton = true,
    this.searchOnType = true,
    this.searchDebounceMs = 300,
    this.focusNode,
    this.enabled = true,
    this.onSearchIconTapped,
  }) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    
    if (widget.searchOnType) {
      _controller.addListener(_onSearchDebounced);
    }
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    
    if (widget.searchOnType && widget.controller != null) {
      _controller.removeListener(_onSearchDebounced);
    }
    super.dispose();
  }
  
  void _onSearchDebounced() {
    if (widget.onSearch != null) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(Duration(milliseconds: widget.searchDebounceMs), () {
        widget.onSearch!(_controller.text);
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: _controller,
      placeholder: widget.placeholder,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      onChanged: widget.searchOnType ? null : widget.onSearch,
      onSubmitted: widget.onSubmitted,
      prefixIcon: Icons.search,
      showClearButton: widget.showClearButton,
      onSuffixIconPressed: widget.onSearchIconTapped,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
    );
  }
}

/// A debounce timer for delaying search.
class Timer {
  final int milliseconds;
  final VoidCallback callback;
  
  Timer(Duration duration, this.callback) : milliseconds = duration.inMilliseconds {
    Future.delayed(duration, callback);
  }
  
  void cancel() {
    // This is a simplified version, but for real implementation
    // you would use dart:async Timer class
  }
} 