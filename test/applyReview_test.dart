import 'package:dolphinsr_dart/models.dart';
import 'package:dolphinsr_dart/utils.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dart:math' as math;
import "dates.dart";

final master = generateId();

generateId() {
  return math.Random().nextInt(666);
}

Review makeReview(DateTime ts) {
  return Review(
    math.Random().nextInt(666),
    Combination([0], [1]),
    ts,
    Rating.Easy,
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
    State state = State.makeEmptyState();
    int id = generateId();
    Combination combination = Combination([], []);
    Review review = Review(id, combination, Dates.today, Rating.Easy);

    expect(() => Utils.applyReview(state, review), throwsA(startsWith("appl")));
  });

  test(
      "should error if adding a review to a state with a lastReviewed later than the review",
      () {
    State state = State.makeEmptyState();
    int id = generateId();
    Combination combination = Combination([0], [1]);

    CardId cardId = CardId.fromIdAndCombi(id, combination);
    state.cardStates[cardId.uniqueId] =
        CardState.makeInitialCardState(id: id, combination: combination);

    Review reviewLater = Review(id, combination, Dates.laterToday, Rating.Easy);
    Review reviewToday = Review(id, combination, Dates.today, Rating.Easy);

    State newState = Utils.applyReview(state, reviewLater);

    Utils.applyReview(state, reviewToday);

    expect(() => Utils.applyReview(newState, reviewToday),
        throwsA(startsWith("Cannot apply review before current lastReviewed")));
  });

  test(
      "should return a new state reflecting the rating when adding a review to a state with the given master and combination",
      () {
    State state = State.makeEmptyState();
    int id = generateId();
    Combination combination = Combination([0], [1]);

    CardId cardId = CardId.fromIdAndCombi(id, combination);
    state.cardStates[cardId.uniqueId] =
        CardState.makeInitialCardState(id: id, combination: combination);

    Review review = Review(id, combination, Dates.today, Rating.Good);

    State newState = Utils.applyReview(state, review);

    expect(newState.cardStates[cardId.uniqueId].consecutiveCorrect, equals(1));
  });

  test(
      "should accurately navigate through learning, reviewing, and lapsed modes",
      () {
    State state = State.makeEmptyState();
    int id = generateId();
    Combination combination = Combination([0], [1]);

    CardId cardId = CardId.fromIdAndCombi(id, combination);
    state.cardStates[cardId.uniqueId] =
        CardState.makeInitialCardState(id: id, combination: combination);

    Review review = Review(id, combination, Dates.today, Rating.Good);

    State stateB = Utils.applyReview(state, review);

    LearningCardState learningCardStateAfterApply = LearningCardState(
        master: id,
        combination: combination,
        consecutiveCorrect: 1,
        lastReviewed: Dates.today);

    LearningCardState processedCard = stateB.cardStates[cardId.uniqueId];
    expect(processedCard, equals(learningCardStateAfterApply));

    Review reviewC = Review(id, combination, Dates.laterToday, Rating.Easy);

    State stateC = Utils.applyReview(stateB, reviewC);

    ReviewingCardState processedCardC = stateC.cardStates[cardId.uniqueId];

    ReviewingCardState learningCardStateAfterApplyC = ReviewingCardState(
        master: id,
        combination: combination,
        lapses: 0,
        lastReviewed: Dates.laterToday,
        factor: 2500,
        interval: 4);

    expect(processedCardC, equals(learningCardStateAfterApplyC));

    DateTime stateCDue =
        Utils.calculateDueDate(stateC.cardStates[cardId.uniqueId]);

    DateTime datePlusFour = Dates.todayAt3AM;
    datePlusFour = datePlusFour.add(Duration(days: 4));
    expect(stateCDue, equals(datePlusFour));
  });
}
