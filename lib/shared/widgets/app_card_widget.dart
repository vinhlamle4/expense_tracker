import 'package:flutter/material.dart';

/// Standardised M3 card wrapper.
/// Padding and shape come from [CardThemeData] — no magic numbers in widgets.
class AppCardWidget extends StatelessWidget {
  const AppCardWidget({
    super.key,
    required this.child,
    this.onTap,
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(onTap: onTap, child: _body(context))
          : _body(context),
    );
  }

  Widget _body(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      );
}

