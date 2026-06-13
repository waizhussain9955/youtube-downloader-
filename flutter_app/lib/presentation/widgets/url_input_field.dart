import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

class UrlInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  const UrlInputField({
    super.key,
    required this.controller,
    this.hint = 'Paste YouTube URL here...',
    this.onSubmitted,
    this.enabled = true,
  });

  @override
  State<UrlInputField> createState() => _UrlInputFieldState();
}

class _UrlInputFieldState extends State<UrlInputField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      widget.controller.text = data!.text!;
      widget.onSubmitted?.call(data.text!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppTheme.darkCard, AppTheme.darkCardElevated],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppTheme.darkBorder),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        enabled: widget.enabled,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
          filled: false,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: const Icon(Icons.link_rounded, color: AppTheme.primary, size: 20),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_hasText)
                IconButton(
                  icon: const Icon(Icons.clear_rounded, color: AppTheme.textHint, size: 18),
                  onPressed: () {
                    widget.controller.clear();
                    setState(() => _hasText = false);
                  },
                ),
              IconButton(
                icon: const Icon(Icons.content_paste_rounded, color: AppTheme.primary, size: 20),
                tooltip: 'Paste',
                onPressed: _pasteFromClipboard,
              ),
            ],
          ),
        ),
        onSubmitted: widget.onSubmitted,
        textInputAction: TextInputAction.go,
        keyboardType: TextInputType.url,
      ),
    );
  }
}
