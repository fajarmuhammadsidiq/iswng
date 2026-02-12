import 'dart:math';

class MemoryCard {
  MemoryCard(this.text)
      : isFlipped = false,
        isMatched = false;

  final String text;
  bool isFlipped;
  bool isMatched;
}

class FlipSelectionResult {
  const FlipSelectionResult({
    required this.changed,
    required this.requiresResolution,
  });

  const FlipSelectionResult.ignored()
      : changed = false,
        requiresResolution = false;

  final bool changed;
  final bool requiresResolution;
}

class TurnResolution {
  const TurnResolution({
    required this.isMatch,
    required this.gameOver,
    required this.won,
  });

  final bool isMatch;
  final bool gameOver;
  final bool won;
}

class MemoryGameEngine {
  MemoryGameEngine({
    required List<String> items,
    Random? random,
    this.maxLives = 3,
  })  : _items = List.unmodifiable(items),
        _random = random ?? Random.secure() {
    if (_items.isEmpty) {
      throw ArgumentError.value(items, 'items', 'must not be empty');
    }
    if (maxLives <= 0) {
      throw ArgumentError.value(maxLives, 'maxLives', 'must be > 0');
    }
    reset();
  }

  final List<String> _items;
  final Random _random;
  final int maxLives;

  final List<MemoryCard> cards = <MemoryCard>[];
  final List<int> _flippedIndexes = <int>[];

  int attempts = 0;
  bool isProcessing = false;
  int lives = 0;

  void reset() {
    cards
      ..clear()
      ..addAll(_createDeck(_items));
    cards.shuffle(_random);
    _flippedIndexes.clear();
    attempts = 0;
    isProcessing = false;
    lives = maxLives;
  }

  FlipSelectionResult flipCard(int index) {
    if (index < 0 || index >= cards.length) {
      return const FlipSelectionResult.ignored();
    }
    if (isProcessing) {
      return const FlipSelectionResult.ignored();
    }

    final card = cards[index];
    if (card.isFlipped || card.isMatched) {
      return const FlipSelectionResult.ignored();
    }

    card.isFlipped = true;
    _flippedIndexes.add(index);

    if (_flippedIndexes.length < 2) {
      return const FlipSelectionResult(
        changed: true,
        requiresResolution: false,
      );
    }

    attempts++;
    isProcessing = true;
    return const FlipSelectionResult(
      changed: true,
      requiresResolution: true,
    );
  }

  TurnResolution resolveTurn() {
    if (_flippedIndexes.length != 2) {
      throw StateError('resolveTurn() requires exactly two flipped cards');
    }

    final firstCard = cards[_flippedIndexes[0]];
    final secondCard = cards[_flippedIndexes[1]];
    final isMatch = firstCard.text == secondCard.text;

    if (isMatch) {
      firstCard.isMatched = true;
      secondCard.isMatched = true;
    } else {
      lives--;
      firstCard.isFlipped = false;
      secondCard.isFlipped = false;
    }

    _flippedIndexes.clear();
    isProcessing = false;

    return TurnResolution(
      isMatch: isMatch,
      gameOver: lives <= 0,
      won: cards.every((card) => card.isMatched),
    );
  }

  List<MemoryCard> _createDeck(List<String> items) {
    final deck = <MemoryCard>[];
    for (final item in items) {
      deck
        ..add(MemoryCard(item))
        ..add(MemoryCard(item));
    }
    return deck;
  }
}
