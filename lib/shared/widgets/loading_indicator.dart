import 'package:flutter/material.dart';

/// Centered loading indicator for async data-fetching states.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}
