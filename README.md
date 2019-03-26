[![Build Status](https://travis-ci.org/JobiJoba/dolphhinsr_dart.svg?branch=master)](https://travis-ci.org/valgene/valgene-cli#)


# DolphinSR_Dart

This projet is a copy of the DolphinSR algorithm from Yodaiken which was written in Javascript.
I need something like that in DART ... so I'm translating it. [Link to original library](https://github.com/yodaiken/dolphinsr)

(Following is from the original module)

DolphinSR implements [spaced repetition](https://en.wikipedia.org/wiki/Spaced_repetition) in
Dart. Specifically, it uses [Anki's modifications](https://apps.ankiweb.net/docs/manual.html#what-algorithm)
to the SM2 algorithm including:

- an initial mode for learning new cards
- a mode for re-learning cards after forgetting them
- reducing the number of self-assigned ratings from 6 to 4
- factoring lateness into card scheduling
- Anki's default configuration options

While DolphinSR is intentionally very similar to Anki's algorithm, it does deviate in a few ways:

- improved support for adding reviews out of order (for example, due to network latency)
- very different internal data structures (DolphinSR is largely written in a functional style to
  make testing and debugging easier, and does not rely on storing computed data or any SQL database)
- only one kind of card

## Installation

Add that to your pubspec.yaml

```yaml
dependencies:
 dolphinsr_dart: "^1.0.0"
```

## Quick Start

See [example/main.dart](https://github.com/JobiJoba/dolphhinsr_dart/blob/master/example/main.dart)

```dart
List<Combination> thaiCombination = [
    Combination([0], [1]),
    Combination([1], [0]),
  ];
  List<Master> masters = [];
  masters.add(Master(1, ['คน', 'person'], thaiCombination));
  masters.add(Master(2, ['คบ', 'To date'], thaiCombination));

  List<Review> reviews = [];

  DolphinSR dolphin = new DolphinSR();

  dolphin.addMasters(masters);
  dolphin.addReviews(reviews);

  var stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 2, overdue: 0 }
  print("${stats.due}-${stats.later}-${stats.learning}-${stats.overdue}");

  Card card = dolphin.nextCard();
  print(
      "${card.back}-${card.front}-${card.combination.back}-${card.combination.front}");
  Review review =
      Review(card.master, card.combination, DateTime.now(), Rating.Easy);
  dolphin.addReviews([review]);

  card = dolphin.nextCard();

```


