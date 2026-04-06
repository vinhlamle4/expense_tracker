import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Search query text — updated by SearchBarWidget.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Date range filter — null means no filter.
final dateRangeFilterProvider = StateProvider<DateTimeRange?>((ref) => null);

/// Category id filter list — empty means no filter.
final categoryFilterProvider = StateProvider<List<String>>((ref) => const []);

