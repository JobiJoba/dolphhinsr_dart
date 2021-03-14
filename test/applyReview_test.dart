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
  test('should add a review to an empty list', () {
    var state = makeEmptyState();
    var id = generateId();
    var combination = Combination(front: [], back: []);
    var review = Review(
        master: id, combination: combination, ts: today, rating: Rating.Easy);

    expect(() => applyReview(state, review), throwsA(startsWith('appl')));
  });

  test(
      'should error if adding a review to a state with a lastReviewed later than the review',
      () {
    var state = makeEmptyState();
    var id = generateId();
    var combination = Combination(front: [0], back: [1]);

    var cardId = CardId.fromCombination(master: id, combination: combination);
    state.cardStates[cardId.uniqueId] =
        makeInitialCardState(id: id, combination: combination);

    var reviewLater = Review(
        master: id,
        combination: combination,
        ts: laterToday,
        rating: Rating.Easy);
    var reviewToday = Review(
        master: id, combination: combination, ts: today, rating: Rating.Easy);

    var newState = applyReview(state, reviewLater);

    applyReview(state, reviewToday);

    expect(() => applyReview(newState, reviewToday),
        throwsA(startsWith('Cannot apply review before current lastReviewed')));
  });

  test(
      'should return a new state reflecting the rating when adding a review to a state with the given master and combination',
      () {
    var state = makeEmptyState();
    var id = generateId();
    var combination = Combination(front: [0], back: [1]);

    var cardId = CardId.fromCombination(master: id, combination: combination);
    state.cardStates[cardId.uniqueId] =
        makeInitialCardState(id: id, combination: combination);

    var review = Review(
        master: id, combination: combination, ts: today, rating: Rating.Good);

    var newState = applyReview(state, review);
    var learningCardStateAfterApply = LearningCardState(
        master: id,
        combination: combination,
        consecutiveCorrect: 1,
        lastReviewed: today);
    expect(newState.cardStates[cardId.uniqueId],
        equals(learningCardStateAfterApply));
  });

  test(
      'should accurately navigate through learning, reviewing, and lapsed modes',
      () {
    var state = makeEmptyState();
    var id = generateId();
    var combination = Combination(front: [0], back: [1]);

    var cardId = CardId.fromCombination(master: id, combination: combination);
    state.cardStates[cardId.uniqueId] =
        makeInitialCardState(id: id, combination: combination);

    var review = Review(
        master: id, combination: combination, ts: today, rating: Rating.Good);

    var stateB = applyReview(state, review);

    var learningCardStateAfterApply = LearningCardState(
        master: id,
        combination: combination,
        consecutiveCorrect: 1,
        lastReviewed: today);

    var processedCard =
        stateB.cardStates[cardId.uniqueId] as LearningCardState?;
    expect(processedCard, equals(learningCardStateAfterApply));

    var reviewC = Review(
        master: id,
        combination: combination,
        ts: laterToday,
        rating: Rating.Easy);

    var stateC = applyReview(stateB, reviewC);

    var processedCardC =
        stateC.cardStates[cardId.uniqueId] as ReviewingCardState?;

    var learningCardStateAfterApplyC = ReviewingCardState(
        master: id,
        combination: combination,
        lapses: 0,
        lastReviewed: laterToday,
        factor: 2500,
        interval: 4);

    expect(processedCardC, equals(learningCardStateAfterApplyC));

    var stateCDue = calculateDueDate(stateC.cardStates[cardId.uniqueId]!);

    var datePlusFour = todayAt3AM;
    datePlusFour = datePlusFour.add(Duration(days: 4));
    expect(stateCDue, equals(datePlusFour));

    var reviewD = Review(
        master: id,
        combination: combination,
        ts: stateCDue,
        rating: Rating.Easy);
    var stateD = applyReview(stateC, reviewD);
    var learningCardStateAfterApplyD = ReviewingCardState(
        master: id,
        combination: combination,
        lapses: 0,
        lastReviewed: stateCDue,
        factor: 2650,
        interval: 20);

    expect(stateD.cardStates[cardId.uniqueId],
        equals(learningCardStateAfterApplyD));

    var stateDDue = calculateDueDate(stateD.cardStates[cardId.uniqueId]!)!;

    var reviewE = Review(
        master: id,
        combination: combination,
        ts: stateDDue,
        rating: Rating.Again);
    var stateE = applyReview(stateD, reviewE);

    var learningCardStateAfterApplyE = LapsedCardState(
        master: id,
        combination: combination,
        consecutiveCorrect: 0,
        lapses: 1,
        lastReviewed: stateDDue,
        factor: 2450,
        interval: 20);

    expect(stateE.cardStates[cardId.uniqueId],
        equals(learningCardStateAfterApplyE));

    var reviewDateE = stateDDue.add(Duration(days: 1));
    var reviewF = Review(
        master: id,
        combination: combination,
        ts: reviewDateE,
        rating: Rating.Again);
    var stateF = applyReview(stateE, reviewF);

    var learningCardStateAfterApplyF = LapsedCardState(
        master: id,
        combination: combination,
        consecutiveCorrect: 0,
        lapses: 1,
        lastReviewed: reviewDateE,
        factor: 2450,
        interval: 20);
    expect(stateF.cardStates[cardId.uniqueId],
        equals(learningCardStateAfterApplyF));

    var reviewDateG = stateDDue.add(Duration(days: 1));
    var reviewG = Review(
        master: id,
        combination: combination,
        ts: reviewDateG,
        rating: Rating.Easy);
    var stateG = applyReview(stateF, reviewG);

    var learningCardStateAfterApplyG = ReviewingCardState(
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
