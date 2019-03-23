import 'package:dolphinsr_dart/dolphinsr_dart.dart';
import 'package:dolphinsr_dart/models.dart';

void main() {
  List<Combination> chineseCombinations = [
    Combination([0], [1, 2]),
    Combination([1], [0, 2]),
    Combination([2], [0, 3]),
  ];
  List<Master> masters = [];
  masters.add(Master(1, ['你好', 'nǐ hǎo', 'hello'], chineseCombinations));
  masters.add(Master(2, ['世界', 'shìjiè', 'world'], chineseCombinations));

  List<Review> reviews = [];

  DolphinSR dolphin = new DolphinSR();

  dolphin.addMasters(masters);
  dolphin.addReviews(reviews);

  var stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  print("${stats.due}-${stats.later}-${stats.learning}-${stats.overdue}");

  Card card = dolphin.nextCard();
  print(
      "${card.back}-${card.front}-${card.combination.back}-${card.combination.front}");
  /* 

  card = dolphin.nextCard();

  print(
      "${card.back}-${card.front}-${card.combination.back}-${card.combination.front}");

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  print("${stats.due}-${stats.later}-${stats.learning}-${stats.overdue}");

  Review review = Review(dolphin.nextCard().master,
      dolphin.nextCard().combination, DateTime.now(), Rating.Easy);
  reviews.add(review);
  dolphin.addReview(reviews);

  stats =
      dolphin.summary(); // => { due: 0, later: 0, learning: 10, overdue: 0 }
  print("${stats.due}-${stats.later}-${stats.learning}-${stats.overdue}"); */
}
