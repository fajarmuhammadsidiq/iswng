import 'package:flutter_test/flutter_test.dart';
import 'package:iswng/app/modules/home/views/home_view.dart';

void main() {
  test('every category has at least one card item', () {
    expect(islamicCategories, isNotEmpty);

    for (final entry in islamicCategories.entries) {
      expect(
        entry.value,
        isNotEmpty,
        reason: 'Category "${entry.key}" must contain at least one item',
      );
    }
  });
}
