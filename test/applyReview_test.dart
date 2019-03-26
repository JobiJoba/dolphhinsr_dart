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
    DRState state = DRState.makeEmptyState();
    int id = generateId();
    Combination combination = Combination([], []);
    Review review = Review(id, combination, Dates.today, Rating.Easy);

    expect(() => Utils.applyReview(state, review), throwsA(startsWith("appl")));
  });

  test(
      "should error if adding a review to a state with a lastReviewed later than the review",
      () {
    DRState state = DRState.makeEmptyState();
    int id = generateId();
    Combination combination = Combination([0], [1]);

    CardId cardId = CardId.fromIdAndCombi(id, combination);
    state.cardStates[cardId.uniqueId] =
        CardState.makeInitialCardState(id: id, combination: combination);

    Review reviewLater = Review(id, combination, Dates.laterToday, Rating.Easy);
    Review reviewToday = Review(id, combination, Dates.today, Rating.Easy);

    DRState newState = Utils.applyReview(state, reviewLater);

    Utils.applyReview(state, reviewToday);

    expect(() => Utils.applyReview(newState, reviewToday),
        throwsA(startsWith("Cannot apply review before current lastReviewed")));
  });

  test(
      "should return a new state reflecting the rating when adding a review to a state with the given master and combination",
      () {
    DRState state = DRState.makeEmptyState();
    int id = generateId();
    Combination combination = Combination([0], [1]);

    CardId cardId = CardId.fromIdAndCombi(id, combination);
    state.cardStates[cardId.uniqueId] =
        CardState.makeInitialCardState(id: id, combination: combination);

    Review review = Review(id, combination, Dates.today, Rating.Good);

    DRState newState = Utils.applyReview(state, review);
    LearningCardState learningCardStateAfterApply = LearningCardState(
        master: id,
        combination: combination,
        consecutiveCorrect: 1,
        lastReviewed: Dates.today);
    expect(newState.cardStates[cardId.uniqueId],
        equals(learningCardStateAfterApply));
  });

  test(
      "should accurately navigate through learning, reviewing, and lapsed modes",
      () {
    DRState state = DRState.makeEmptyState();
    int id = generateId();
    Combination combination = Combination([0], [1]);

    CardId cardId = CardId.fromIdAndCombi(id, combination);
    state.cardStates[cardId.uniqueId] =
        CardState.makeInitialCardState(id: id, combination: combination);

    Review review = Review(id, combination, Dates.today, Rating.Good);

    DRState stateB = Utils.applyReview(state, review);

    LearningCardState learningCardStateAfterApply = LearningCardState(
        master: id,
        combination: combination,
        consecutiveCorrect: 1,
        lastReviewed: Dates.today);

    LearningCardState processedCard = stateB.cardStates[cardId.uniqueId];
    expect(processedCard, equals(learningCardStateAfterApply));

    Review reviewC = Review(id, combination, Dates.laterToday, Rating.Easy);

    DRState stateC = Utils.applyReview(stateB, reviewC);

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

    Review reviewD = Review(id, combination, stateCDue, Rating.Easy);
    DRState stateD = Utils.applyReview(stateC, reviewD);
    ReviewingCardState learningCardStateAfterApplyD = ReviewingCardState(
        master: id,
        combination: combination,
        lapses: 0,
        lastReviewed: stateCDue,
        factor: 2650,
        interval: 20);

    expect(stateD.cardStates[cardId.uniqueId],
        equals(learningCardStateAfterApplyD));

    DateTime stateDDue =
        Utils.calculateDueDate(stateD.cardStates[cardId.uniqueId]);

    Review reviewE = Review(id, combination, stateDDue, Rating.Again);
    DRState stateE = Utils.applyReview(stateD, reviewE);

    LapsedCardState learningCardStateAfterApplyE = LapsedCardState(
        master: id,
        combination: combination,
        consecutiveCorrect: 0,
        lapses: 1,
        lastReviewed: stateDDue,
        factor: 2450,
        interval: 20);

    expect(stateE.cardStates[cardId.uniqueId],
        equals(learningCardStateAfterApplyE));

    DateTime reviewDateE = stateDDue.add(Duration(days: 1));
    Review reviewF = Review(id, combination, reviewDateE, Rating.Again);
    DRState stateF = Utils.applyReview(stateE, reviewF);

    LapsedCardState learningCardStateAfterApplyF = LapsedCardState(
        master: id,
        combination: combination,
        consecutiveCorrect: 0,
        lapses: 1,
        lastReviewed: reviewDateE,
        factor: 2450,
        interval: 20);
    expect(stateF.cardStates[cardId.uniqueId],
        equals(learningCardStateAfterApplyF));

    DateTime reviewDateG = stateDDue.add(Duration(days: 1));
    Review reviewG = Review(id, combination, reviewDateG, Rating.Easy);
    DRState stateG = Utils.applyReview(stateF, reviewG);

    ReviewingCardState learningCardStateAfterApplyG = ReviewingCardState(
        master: id,
        combination: combination,
        lapses: 1,
        lastReviewed: reviewDateG,
        factor: 2450,
        interval: 1);
    expect(stateG.cardStates[cardId.uniqueId],
        equals(learningCardStateAfterApplyG));
  });
}
