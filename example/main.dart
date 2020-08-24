import 'package:dolphinsr_dart/dolphinsr_dart.dart';

void main() {
  final List<Review> reviews = <Review>[];

  final DolphinSR dolphin = DolphinSR();

  dolphin.addMasters(<Master>[
    Master(id: 1, fields: <String>[
      'คน',
      'person'
    ], combinations: <Combination>[
      Combination(front: <int>[0], back: <int>[1]),
      Combination(front: <int>[1], back: <int>[0]),
    ]),
    Master(id: 2, fields: <String>[
      'คบ',
      'To date'
    ], combinations: <Combination>[
      Combination(front: <int>[0], back: <int>[1]),
      Combination(front: <int>[1], back: <int>[0]),
    ])
  ]);
  dolphin.addReviews(reviews);

  SummaryStatics stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 2, overdue: 0 }

  print("${stats.due}-${stats.later}-${stats.learning}-${stats.overdue}");

  DRCard card = dolphin.nextCard();
  print(
      "${card.back}-${card.front}-${card.combination.back}-${card.combination.front}");
  Review review = Review(
      master: card.master,
      combination: card.combination,
      ts: DateTime.now(),
      rating: Rating.Hard);
  dolphin.addReviews(<Review>[review]);

  card = dolphin.nextCard();
  print(
      "${card.back}-${card.front}-${card.combination.back}-${card.combination.front}");

  review = Review(
      master: card.master,
      combination: card.combination,
      ts: DateTime.now(),
      rating: Rating.Hard);
  dolphin.addReviews(<Review>[review]);

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  print("${stats.due}-${stats.later}-${stats.learning}-${stats.overdue}");

  card = dolphin.nextCard();
  print(
      "${card.back}-${card.front}-${card.combination.back}-${card.combination.front}");
  review = Review(
      master: card.master,
      combination: card.combination,
      ts: DateTime.now(),
      rating: Rating.Hard);
  dolphin.addReviews(<Review>[review]);

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  print("${stats.due}-${stats.later}-${stats.learning}-${stats.overdue}");

  card = dolphin.nextCard();
  print(
      "${card.back}-${card.front}-${card.combination.back}-${card.combination.front}");
  review = Review(
      master: card.master,
      combination: card.combination,
      ts: DateTime.now(),
      rating: Rating.Hard);
  dolphin.addReviews(<Review>[review]);

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  print("${stats.due}-${stats.later}-${stats.learning}-${stats.overdue}");

  card = dolphin.nextCard();
  print(
      "${card.back}-${card.front}-${card.combination.back}-${card.combination.front}");
  review = Review(
      master: card.master,
      combination: card.combination,
      ts: DateTime.now(),
      rating: Rating.Hard);
  dolphin.addReviews(<Review>[review]);

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  print("${stats.due}-${stats.later}-${stats.learning}-${stats.overdue}");

  card = dolphin.nextCard();
  print(
      "${card.back}-${card.front}-${card.combination.back}-${card.combination.front}");
  review = Review(
      master: card.master,
      combination: card.combination,
      ts: DateTime.now(),
      rating: Rating.Hard);
  dolphin.addReviews(<Review>[review]);

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  print("${stats.due}-${stats.later}-${stats.learning}-${stats.overdue}");

  card = dolphin.nextCard();
  print(
      "${card.back}-${card.front}-${card.combination.back}-${card.combination.front}");
  review = Review(
      master: card.master,
      combination: card.combination,
      ts: DateTime.now(),
      rating: Rating.Hard);
  dolphin.addReviews(<Review>[review]);

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  print("${stats.due}-${stats.later}-${stats.learning}-${stats.overdue}");

  card = dolphin.nextCard();
  print(
      "${card.back}-${card.front}-${card.combination.back}-${card.combination.front}");
  review = Review(
      master: card.master,
      combination: card.combination,
      ts: DateTime.now(),
      rating: Rating.Hard);
  dolphin.addReviews(<Review>[review]);

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  print("${stats.due}-${stats.later}-${stats.learning}-${stats.overdue}");

  card = dolphin.nextCard();
  print(
      "${card.back}-${card.front}-${card.combination.back}-${card.combination.front}");
  review = Review(
      master: card.master,
      combination: card.combination,
      ts: DateTime.now(),
      rating: Rating.Hard);
  dolphin.addReviews(<Review>[review]);

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  print("${stats.due}-${stats.later}-${stats.learning}-${stats.overdue}");
}
