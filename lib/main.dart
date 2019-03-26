import 'package:dolphinsr_dart/dolphinsr_dart.dart';
import 'package:dolphinsr_dart/models.dart';

void main() {
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
  print(
      "${card.back}-${card.front}-${card.combination.back}-${card.combination.front}");

  review = Review(card.master, card.combination, DateTime.now(), Rating.Easy);
  dolphin.addReviews([review]);

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  print("${stats.due}-${stats.later}-${stats.learning}-${stats.overdue}");

  card = dolphin.nextCard();
  print(
      "${card.back}-${card.front}-${card.combination.back}-${card.combination.front}");
  review = Review(card.master, card.combination, DateTime.now(), Rating.Easy);
  dolphin.addReviews([review]);

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  print("${stats.due}-${stats.later}-${stats.learning}-${stats.overdue}");

  card = dolphin.nextCard();
  print(
      "${card.back}-${card.front}-${card.combination.back}-${card.combination.front}");
  review = Review(card.master, card.combination, DateTime.now(), Rating.Easy);
  dolphin.addReviews([review]);

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  print("${stats.due}-${stats.later}-${stats.learning}-${stats.overdue}");
}
