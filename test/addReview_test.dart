import 'dart:math' as math;

import 'package:dolphinsr_dart/src/models.dart';
import 'package:dolphinsr_dart/src/utils.dart';
import "package:test/test.dart";

import "dates.dart";

final int master = generateId();

int generateId() {
  return math.Random().nextInt(666);
}

Review makeReview(DateTime ts, {Rating rating = Rating.Easy}) {
  return Review(
    master: math.Random().nextInt(666),
    combination: Combination(front: [0], back: [1]),
    ts: ts,
    rating: rating,
  );
}

final List<Review> reviews = [
  today,
  todayAt3AM,
  laterToday,
  laterTmrw,
  laterInTwoDays,
  laterInFourDays,
].map(makeReview).toList();

void main() {
  test("should add a review to an empty list", () {
    var reviewAdded = addReview([], reviews[0]);
    expect(reviewAdded, equals([reviews[0]]));
  });

  test("should add a later review after a earlier review", () {
    var reviewAdded = addReview([reviews[0]], reviews[1]);
    expect(reviewAdded, equals([reviews[0], reviews[1]]));
  });

  test("should add an earlier review before a later review", () {
    var reviewAdded = addReview([reviews[1]], reviews[0]);
    expect(reviewAdded, equals([reviews[0], reviews[1]]));
  });

  test("should add an earlier review before a couple later reviews", () {
    var reviewAdded = addReview(reviews.sublist(1), reviews[0]);
    expect(reviewAdded, equals(reviews));
  });

  test("should add a review in between reviews", () {
    var reviewAdded = addReview(
        [reviews[0], reviews[1], reviews[2], reviews[4], reviews[5]],
        reviews[3]);
    expect(reviewAdded, equals(reviews));
  });

  test("should add an unidentical review with a same timestamp after", () {
    Review r = makeReview(today);
    Review s = makeReview(today, rating: Rating.Again);

    var reviewAdded = addReview([r], s);

    expect(reviewAdded, equals([r, s]));
    reviewAdded = addReview([s], r);
    expect(reviewAdded, equals([s, r]));

    List<Review> newListToAddToReview = [r];
    newListToAddToReview.addAll(reviews);
    reviewAdded = addReview(newListToAddToReview, s);

    List<Review> subListReview = reviews.sublist(1);
    List<Review> listToTest = [r, reviews[0], s];
    listToTest.addAll(subListReview);
    expect(reviewAdded, equals(listToTest));
  });
}
