import 'package:dolphinsr_dart/dolphinsr_dart.dart';

void main() {
  final reviews = <Review>[];

  final dolphin = DolphinSR();

  dolphin.addMasters(<Master>[
    Master(id: '1', fields: <String>[
      'คน',
      'person'
    ], combinations: <Combination>[
      Combination(front: <int>[0], back: <int>[1]),
      Combination(front: <int>[1], back: <int>[0]),
    ]),
    Master(id: '2', fields: <String>[
      'คบ',
      'To date'
    ], combinations: <Combination>[
      Combination(front: <int>[0], back: <int>[1]),
      Combination(front: <int>[1], back: <int>[0]),
    ])
  ]);
  dolphin.addReviews(reviews);

  var stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 2, overdue: 0 }

  printStats(stats);

  var card = dolphin.nextCard();
  printCard(card);
  var review = Review(
      master: card.master,
      combination: card.combination,
      ts: DateTime.now(),
      rating: Rating.Hard);
  dolphin.addReviews(<Review>[review]);

  card = dolphin.nextCard();
  printCard(card);

  review = Review(
      master: card.master,
      combination: card.combination,
      ts: DateTime.now(),
      rating: Rating.Hard);
  dolphin.addReviews(<Review>[review]);

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  printStats(stats);

  card = dolphin.nextCard();
  printCard(card);
  review = Review(
      master: card.master,
      combination: card.combination,
      ts: DateTime.now(),
      rating: Rating.Hard);
  dolphin.addReviews(<Review>[review]);

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  printStats(stats);

  card = dolphin.nextCard();
  printCard(card);
  review = Review(
      master: card.master,
      combination: card.combination,
      ts: DateTime.now(),
      rating: Rating.Hard);
  dolphin.addReviews(<Review>[review]);

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  printStats(stats);

  card = dolphin.nextCard();
  printCard(card);
  review = Review(
      master: card.master,
      combination: card.combination,
      ts: DateTime.now(),
      rating: Rating.Hard);
  dolphin.addReviews(<Review>[review]);

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  printStats(stats);

  card = dolphin.nextCard();
  printCard(card);
  review = Review(
      master: card.master,
      combination: card.combination,
      ts: DateTime.now(),
      rating: Rating.Hard);
  dolphin.addReviews(<Review>[review]);

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  printStats(stats);

  card = dolphin.nextCard();
  printCard(card);
  review = Review(
      master: card.master,
      combination: card.combination,
      ts: DateTime.now(),
      rating: Rating.Hard);
  dolphin.addReviews(<Review>[review]);

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  printStats(stats);

  card = dolphin.nextCard();
  printCard(card);
  review = Review(
      master: card.master,
      combination: card.combination,
      ts: DateTime.now(),
      rating: Rating.Hard);
  dolphin.addReviews(<Review>[review]);

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  printStats(stats);

  card = dolphin.nextCard();
  printCard(card);
  review = Review(
      master: card.master,
      combination: card.combination,
      ts: DateTime.now(),
      rating: Rating.Hard);
  dolphin.addReviews(<Review>[review]);

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  printStats(stats);
}

void printCard(card) {
  print(
      '${card.back}-${card.front}-${card.combination.back}-${card.combination.front}');
}

void printStats(stats) {
  print('${stats.due}-${stats.later}-${stats.learning}-${stats.overdue}');
}
