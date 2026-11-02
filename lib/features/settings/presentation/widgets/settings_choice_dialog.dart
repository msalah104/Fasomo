import 'package:flutter/material.dart';

/// Shows a dialog listing [options] with [selected] ticked, and returns the
/// option the user picked, or `null` when dismissed.
Future<T?> showSettingsChoice<T>({
  required BuildContext context,
  required String title,
  required List<T> options,
  required T selected,
  required String Function(T option) labelOf,
}) => showDialog<T>(
  context: context,
  builder: (context) => SimpleDialog(
    title: Text(title),
    children: [
      for (final option in options)
        _ChoiceOption(
          label: labelOf(option),
          isSelected: option == selected,
          onTap: () => Navigator.of(context).pop(option),
        ),
    ],
  ),
);

class _ChoiceOption extends StatelessWidget {
  const new({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // The tick, not only the highlight colour, marks the current choice.
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
      title: Text(label),
      selected: isSelected,
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: onTap,
    );
  }
}
