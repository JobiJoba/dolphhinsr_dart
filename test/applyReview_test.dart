import 'dart:math' as math;
import 'package:dolphinsr_dart/src/models.dart';
import 'package:dolphinsr_dart/src/utils.dart';
import 'package:test/test.dart';
import 'dates.dart';

final master = generateId();

String generateId() {
  return math.Random().nextInt(666).toString();
}

Review makeReview(DateTime ts) {
  return Review(
    master: generateId(),
    combination: Combination(front: [0], back: [1]),
    ts: ts,
    rating: Rating.Easy,
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
    DRState state = makeEmptyState();
    String id = generateId();
    Combination combination = Combination(front: [], back: []);
    Review review = Review(
        master: id, combination: combination, ts: today, rating: Rating.Easy);

    expect(() => applyReview(state, review), throwsA(startsWith("appl")));
  });

  test(
      "should error if adding a review to a state with a lastReviewed later than the review",
      () {
    DRState state = makeEmptyState();
    String id = generateId();
    Combination combination = Combination(front: [0], back: [1]);

    CardId cardId = CardId(master: id, combination: combination);
    state.cardStates[cardId.uniqueId] =
        makeInitialCardState(id: id, combination: combination);

    Review reviewLater = Review(
        master: id,
        combination: combination,
        ts: laterToday,
        rating: Rating.Easy);
    Review reviewToday = Review(
        master: id, combination: combination, ts: today, rating: Rating.Easy);

    DRState newState = applyReview(state, reviewLater);

    applyReview(state, reviewToday);

    expect(() => applyReview(newState, reviewToday),
        throwsA(startsWith("Cannot apply review before current lastReviewed")));
  });

  test(
      "should return a new state reflecting the rating when adding a review to a state with the given master and combination",
      () {
    DRState state = makeEmptyState();
    String id = generateId();
    Combination combination = Combination(front: [0], back: [1]);

    CardId cardId = CardId(master: id, combination: combination);
    state.cardStates[cardId.uniqueId] =
        makeInitialCardState(id: id, combination: combination);

    Review review = Review(
        master: id, combination: combination, ts: today, rating: Rating.Good);

    DRState newState = applyReview(state, review);
    LearningCardState learningCardStateAfterApply = LearningCardState(
        master: id,
        combination: combination,
        consecutiveCorrect: 1,
        lastReviewed: today);
    expect(newState.cardStates[cardId.uniqueId],
        equals(learningCardStateAfterApply));
  });

  test(
      "should accurately navigate through learning, reviewing, and lapsed modes",
      () {
    DRState state = makeEmptyState();
    String id = generateId();
    Combination combination = Combination(front: [0], back: [1]);

    CardId cardId = CardId(master: id, combination: combination);
    state.cardStates[cardId.uniqueId] =
        makeInitialCardState(id: id, combination: combination);

    Review review = Review(
        master: id, combination: combination, ts: today, rating: Rating.Good);

    DRState stateB = applyReview(state, review);

    LearningCardState learningCardStateAfterApply = LearningCardState(
        master: id,
        combination: combination,
        consecutiveCorrect: 1,
        lastReviewed: today);

    LearningCardState processedCard = stateB.cardStates[cardId.uniqueId];
    expect(processedCard, equals(learningCardStateAfterApply));

    Review reviewC = Review(
        master: id,
        combination: combination,
        ts: laterToday,
        rating: Rating.Easy);

    DRState stateC = applyReview(stateB, reviewC);

    ReviewingCardState processedCardC = stateC.cardStates[cardId.uniqueId];

    ReviewingCardState learningCardStateAfterApplyC = ReviewingCardState(
        master: id,
        combination: combination,
        lapses: 0,
        lastReviewed: laterToday,
        factor: 2500,
        interval: 4);

    expect(processedCardC, equals(learningCardStateAfterApplyC));

    DateTime stateCDue = calculateDueDate(stateC.cardStates[cardId.uniqueId]);

    DateTime datePlusFour = todayAt3AM;
    datePlusFour = datePlusFour.add(Duration(days: 4));
    expect(stateCDue, equals(datePlusFour));

    Review reviewD = Review(
        master: id,
        combination: combination,
        ts: stateCDue,
        rating: Rating.Easy);
    DRState stateD = applyReview(stateC, reviewD);
    ReviewingCardState learningCardStateAfterApplyD = ReviewingCardState(
        master: id,
        combination: combination,
        lapses: 0,
        lastReviewed: stateCDue,
        factor: 2650,
        interval: 20);

    expect(stateD.cardStates[cardId.uniqueId],
        equals(learningCardStateAfterApplyD));

    DateTime stateDDue = calculateDueDate(stateD.cardStates[cardId.uniqueId]);

    Review reviewE = Review(
        master: id,
        combination: combination,
        ts: stateDDue,
        rating: Rating.Again);
    DRState stateE = applyReview(stateD, reviewE);

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
    Review reviewF = Review(
        master: id,
        combination: combination,
        ts: reviewDateE,
        rating: Rating.Again);
    DRState stateF = applyReview(stateE, reviewF);

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
    Review reviewG = Review(
        master: id,
        combination: combination,
        ts: reviewDateG,
        rating: Rating.Easy);
    DRState stateG = applyReview(stateF, reviewG);

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
