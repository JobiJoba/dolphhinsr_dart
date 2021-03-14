import 'dart:math' as math;

import 'package:dolphinsr_dart/src/models.dart';
import 'package:dolphinsr_dart/src/utils.dart';
import 'package:test/test.dart';

import 'dates.dart';

final String master = generateId();

String generateId() {
  return math.Random().nextInt(666).toString();
}

Review makeReview(DateTime ts, {Rating rating = Rating.Easy}) {
  return Review(
    master: generateId(),
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
  test('should add a review to an empty list', () {
    var reviewAdded = addReview([], reviews[0]);
    expect(reviewAdded, equals([reviews[0]]));
  });

  test('should add a later review after a earlier review', () {
    var reviewAdded = addReview([reviews[0]], reviews[1]);
    expect(reviewAdded, equals([reviews[0], reviews[1]]));
  });

  test('should add an earlier review before a later review', () {
    var reviewAdded = addReview([reviews[1]], reviews[0]);
    expect(reviewAdded, equals([reviews[0], reviews[1]]));
  });

  test('should add an earlier review before a couple later reviews', () {
    var reviewAdded = addReview(reviews.sublist(1), reviews[0]);
    expect(reviewAdded, equals(reviews));
  });

  test('should add a review in between reviews', () {
    var reviewAdded = addReview(
        [reviews[0], reviews[1], reviews[2], reviews[4], reviews[5]],
        reviews[3]);
    expect(reviewAdded, equals(reviews));
  });

  test('should add an unidentical review with a same timestamp after', () {
    var r = makeReview(today);
    var s = makeReview(today, rating: Rating.Again);

    var reviewAdded = addReview([r], s);

    expect(reviewAdded, equals([r, s]));
    reviewAdded = addReview([s], r);
    expect(reviewAdded, equals([s, r]));

    var newListToAddToReview = <Review>[r];
    newListToAddToReview.addAll(reviews);
    reviewAdded = addReview(newListToAddToReview, s);

    var subListReview = reviews.sublist(1);
    var listToTest = <Review>[r, reviews[0], s];
    listToTest.addAll(subListReview);
    expect(reviewAdded, equals(listToTest));
  });
}
