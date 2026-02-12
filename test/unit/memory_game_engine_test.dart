import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:iswng/app/modules/home/domain/memory_game_engine.dart';

void main() {
  group('MemoryGameEngine', () {
    test('initializes deck with pairs and default state', () {
      final engine = MemoryGameEngine(
        items: const ['A', 'B', 'C'],
        random: Random(1),
      );

      expect(engine.cards.length, 6);
      expect(engine.attempts, 0);
      expect(engine.isProcessing, isFalse);
      expect(engine.lives, 3);

      final counts = <String, int>{};
      for (final card in engine.cards) {
        counts.update(card.text, (value) => value + 1, ifAbsent: () => 1);
        expect(card.isFlipped, isFalse);
        expect(card.isMatched, isFalse);
      }

      expect(counts['A'], 2);
      expect(counts['B'], 2);
      expect(counts['C'], 2);
    });

    test('first flip changes state without requiring resolution', () {
      final engine = MemoryGameEngine(
        items: const ['A', 'B'],
        random: Random(2),
      );

      final selection = engine.flipCard(0);

      expect(selection.changed, isTrue);
      expect(selection.requiresResolution, isFalse);
      expect(engine.cards[0].isFlipped, isTrue);
      expect(engine.attempts, 0);
      expect(engine.isProcessing, isFalse);
    });

    test('second flip requires resolution and blocks extra flips', () {
      final engine = MemoryGameEngine(
        items: const ['A', 'B'],
        random: Random(3),
      );

      engine.flipCard(0);
      final secondFlip = engine.flipCard(1);
      final thirdFlip = engine.flipCard(2);

      expect(secondFlip.changed, isTrue);
      expect(secondFlip.requiresResolution, isTrue);
      expect(engine.attempts, 1);
      expect(engine.isProcessing, isTrue);
      expect(thirdFlip.changed, isFalse);
    });

    test('resolveTurn marks matched cards and detects win', () {
      final engine = MemoryGameEngine(
        items: const ['A'],
        random: Random(4),
      );

      engine.flipCard(0);
      engine.flipCard(1);
      final resolution = engine.resolveTurn();

      expect(resolution.isMatch, isTrue);
      expect(resolution.won, isTrue);
      expect(resolution.gameOver, isFalse);
      expect(engine.cards.every((card) => card.isMatched), isTrue);
      expect(engine.lives, 3);
      expect(engine.isProcessing, isFalse);
    });

    test('resolveTurn for mismatch decreases lives and flips cards back', () {
      final engine = MemoryGameEngine(
        items: const ['A', 'B'],
        random: Random(5),
      );

      final pair = _findMismatchPair(engine);

      engine.flipCard(pair.$1);
      engine.flipCard(pair.$2);
      final resolution = engine.resolveTurn();

      expect(resolution.isMatch, isFalse);
      expect(resolution.won, isFalse);
      expect(resolution.gameOver, isFalse);
      expect(engine.lives, 2);
      expect(engine.cards[pair.$1].isFlipped, isFalse);
      expect(engine.cards[pair.$2].isFlipped, isFalse);
      expect(engine.cards[pair.$1].isMatched, isFalse);
      expect(engine.cards[pair.$2].isMatched, isFalse);
    });

    test('returns game over when lives are depleted', () {
      final engine = MemoryGameEngine(
        items: const ['A', 'B'],
        random: Random(6),
      );

      final pair = _findMismatchPair(engine);

      for (var attempt = 1; attempt <= 3; attempt++) {
        engine.flipCard(pair.$1);
        engine.flipCard(pair.$2);
        final resolution = engine.resolveTurn();

        if (attempt < 3) {
          expect(resolution.gameOver, isFalse);
        } else {
          expect(resolution.gameOver, isTrue);
        }
      }

      expect(engine.lives, 0);
    });

    test('reset restores deck state, lives, and attempts', () {
      final engine = MemoryGameEngine(
        items: const ['A', 'B'],
        random: Random(7),
      );

      final pair = _findMismatchPair(engine);

      engine.flipCard(pair.$1);
      engine.flipCard(pair.$2);
      engine.resolveTurn();

      expect(engine.attempts, 1);
      expect(engine.lives, 2);

      engine.reset();

      expect(engine.attempts, 0);
      expect(engine.lives, 3);
      expect(engine.isProcessing, isFalse);
      expect(engine.cards.every((card) => !card.isFlipped && !card.isMatched),
          isTrue);
    });
  });
}

(int, int) _findMismatchPair(MemoryGameEngine engine) {
  for (var i = 0; i < engine.cards.length; i++) {
    for (var j = i + 1; j < engine.cards.length; j++) {
      if (engine.cards[i].text != engine.cards[j].text) {
        return (i, j);
      }
    }
  }
  throw StateError('Mismatch pair not found');
}
