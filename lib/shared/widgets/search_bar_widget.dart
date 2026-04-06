import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../providers/filter_providers.dart';

class TransactionSearchBar extends HookConsumerWidget {
  const TransactionSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final debounce = useRef<Timer?>(null);

    return SearchBar(
      controller: controller,
      hintText: 'Search transactions…',
      leading: const Icon(Icons.search),
      trailing: [
        ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, value, child) => value.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                )
              : const SizedBox.shrink(),
        ),
      ],
      onChanged: (v) {
        debounce.value?.cancel();
        debounce.value = Timer(const Duration(milliseconds: 300), () {
          ref.read(searchQueryProvider.notifier).state = v;
        });
      },
    );
  }
}

