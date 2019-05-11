import 'package:dolphinsr_dart/src/models.dart';
import 'package:dolphinsr_dart/src/utils.dart';
import "package:test/test.dart";

import 'dart:math' as math;
import "dates.dart";

final master = generateId();

generateId() {
  return math.Random().nextInt(666);
}

Review makeReview(DateTime ts) {
  return Review(
    master: math.Random().nextInt(666),
    combination: Combination(front: [0], back: [1]),
    ts: ts,
    rating: Rating.Easy,
  );
}

final List<Review> reviews = [
  Dates.today,
  Dates.todayAt3AM,
  Dates.laterToday,
  Dates.laterTmrw,
  Dates.laterInTwoDays,
  Dates.laterInFourDays,
].map(makeReview).toList();

void main() {
  test("should add a review to an empty list", () {
    var reviewAdded = Utils.addReview([], reviews[0]);
    expect(reviewAdded, equals([reviews[0]]));
  });

  test("should add a later review after a earlier review", () {
    var reviewAdded = Utils.addReview([reviews[0]], reviews[1]);
    expect(reviewAdded, equals([reviews[0], reviews[1]]));
  });

  test("should add an earlier review before a later review", () {
    var reviewAdded = Utils.addReview([reviews[1]], reviews[0]);
    expect(reviewAdded, equals([reviews[0], reviews[1]]));
  });

  test("should add an earlier review before a couple later reviews", () {
    var reviewAdded = Utils.addReview(reviews.sublist(1), reviews[0]);
    expect(reviewAdded, equals(reviews));
  });

  test("should add a review in between reviews", () {
    var reviewAdded = Utils.addReview(
        [reviews[0], reviews[1], reviews[2], reviews[4], reviews[5]],
        reviews[3]);
    expect(reviewAdded, equals(reviews));
  });

  test("should add an unidentical review with a same timestamp after", () {
    Review r = makeReview(Dates.today);
    Review s = makeReview(Dates.today);
    s.rating = Rating.Again;

    var reviewAdded = Utils.addReview([r], s);

    expect(reviewAdded, equals([r, s]));
    reviewAdded = Utils.addReview([s], r);
    expect(reviewAdded, equals([s, r]));

    List<Review> newListToAddToReview = [r];
    newListToAddToReview.addAll(reviews);
    reviewAdded = Utils.addReview(newListToAddToReview, s);

    List<Review> subListReview = reviews.sublist(1);
    List<Review> listToTest = [r, reviews[0], s];
    listToTest.addAll(subListReview);
    expect(reviewAdded, equals(listToTest));
  });
}
