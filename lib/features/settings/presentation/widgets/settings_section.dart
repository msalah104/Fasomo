import 'package:flutter/material.dart';

/// A titled group of settings tiles.
///
/// Public so the app shell can compose sections from other features into the
/// settings page without the settings feature depending on them.
class SettingsSection extends StatelessWidget {
  const new({required this.title, required this.children, super.key});

  final String title;

  /// Usually [ListTile]s.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 8),
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
