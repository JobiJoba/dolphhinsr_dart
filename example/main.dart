import 'package:dolphinsr_dart/dolphinsr_dart.dart';

void main() {
  List<Review> reviews = [];

  DolphinSR dolphin = new DolphinSR();

  dolphin.addMasters([
    Master(id: 1, fields: [
      'คน',
      'person'
    ], combinations: [
      Combination(front: [0], back: [1]),
      Combination(front: [1], back: [0]),
    ]),
    Master(id: 2, fields: [
      'คบ',
      'To date'
    ], combinations: [
      Combination(front: [0], back: [1]),
      Combination(front: [1], back: [0]),
    ])
  ]);
  dolphin.addReviews(reviews);

  var stats =
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
  dolphin.addReviews([review]);

  card = dolphin.nextCard();
  print(
      "${card.back}-${card.front}-${card.combination.back}-${card.combination.front}");

  review = Review(
      master: card.master,
      combination: card.combination,
      ts: DateTime.now(),
      rating: Rating.Hard);
  dolphin.addReviews([review]);

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
  dolphin.addReviews([review]);

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
  dolphin.addReviews([review]);

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
  dolphin.addReviews([review]);

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
  dolphin.addReviews([review]);

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
  dolphin.addReviews([review]);

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
  dolphin.addReviews([review]);

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
  dolphin.addReviews([review]);

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  print("${stats.due}-${stats.later}-${stats.learning}-${stats.overdue}");
}
