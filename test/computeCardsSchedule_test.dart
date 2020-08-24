import 'dart:math' as math;
import 'package:dolphinsr_dart/src/models.dart';
import 'package:dolphinsr_dart/src/utils.dart';
import "package:test/test.dart";

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
  today,
  todayAt3AM,
  laterToday,
  laterTmrw,
  laterInTwoDays,
  laterInFourDays,
].map(makeReview).toList();

void main() {
  test("should add a rounded interval to the lastReviewed, set at 3am", () {
    int id = generateId();
    Combination combination = Combination(front: [0], back: [1]);
    ReviewingCardState stateCard = ReviewingCardState(
        master: id,
        combination: combination,
        lapses: 0,
        lastReviewed: today,
        factor: 1000,
        interval: 13.3);

    DateTime due = calculateDueDate(stateCard);

    DateTime expectedDate = todayAt3AM.add(Duration(days: 14));
    expect(due, equals(expectedDate));
  });
  test("should return later for cards that are reviewing and not yet due", () {
    int id = generateId();
    Combination combination = Combination(front: [0], back: [1]);

    ReviewingCardState stateCard = ReviewingCardState(
        master: id,
        combination: combination,
        lapses: 0,
        lastReviewed: today,
        factor: 1000,
        interval: 13.3);

    String computeSchedule = computeScheduleFromCardState(stateCard, laterTmrw);

    expect(computeSchedule, equals("later"));
  });

  test("should return due for cards that are reviewing and due within the day",
      () {
    int id = generateId();
    Combination combination = Combination(front: [0], back: [1]);

    ReviewingCardState stateCard = ReviewingCardState(
        master: id,
        combination: combination,
        lapses: 0,
        lastReviewed: today,
        factor: 1000,
        interval: 13.3);

    String computeSchedule = computeScheduleFromCardState(
        stateCard, todayAt3AM.add(Duration(days: 14)));

    expect(computeSchedule, equals("due"));

    computeSchedule = computeScheduleFromCardState(
        stateCard, laterToday.add(Duration(days: 14)));
    expect(computeSchedule, equals("due"));
  });

  test("should return overdue for cards that reviewing and due before the day",
      () {
    int id = generateId();
    Combination combination = Combination(front: [0], back: [1]);

    ReviewingCardState stateCard = ReviewingCardState(
        master: id,
        combination: combination,
        lapses: 0,
        lastReviewed: today,
        factor: 1000,
        interval: 13.3);

    String computeSchedule = computeScheduleFromCardState(
        stateCard, todayAt3AM.add(Duration(days: 15)));

    expect(computeSchedule, equals("overdue"));

    computeSchedule = computeScheduleFromCardState(
        stateCard, laterToday.add(Duration(days: 15)));
    expect(computeSchedule, equals("overdue"));
  });

  test("should return an empty schedule when passed an empty state", () {
    DRState emptyState = makeEmptyState();

    expect(computeCardsSchedule(emptyState, today).learning.length, equals(0));
    expect(computeCardsSchedule(emptyState, today).later.length, equals(0));
    expect(computeCardsSchedule(emptyState, today).due.length, equals(0));
    expect(computeCardsSchedule(emptyState, today).overdue.length, equals(0));
  });

  test("should a sorted list of cards when passed cards in multiple states",
      () {
    DRState emptyState = makeEmptyState();

    int id = generateId();
    Combination combination = Combination(front: [0], back: [1]);

    ReviewingCardState dueLater = ReviewingCardState(
        master: id,
        combination: combination,
        lapses: 0,
        lastReviewed: laterTmrw,
        factor: 1000,
        interval: 13.3);
    ReviewingCardState dueNow = ReviewingCardState(
        master: id,
        combination: Combination(front: [0, 1], back: [1]),
        lapses: 0,
        lastReviewed: laterTmrw,
        factor: 1000,
        interval: 0);

    ReviewingCardState overDue = ReviewingCardState(
        master: id,
        combination: Combination(front: [1], back: [0]),
        lapses: 0,
        lastReviewed: today,
        factor: 1000,
        interval: 0);

    LearningCardState learning = LearningCardState(
      master: id,
      combination: Combination(front: [1, 0], back: [0]),
      lastReviewed: today,
      consecutiveCorrect: 0,
    );

    LapsedCardState lapsed = LapsedCardState(
        master: id,
        combination: Combination(front: [1, 0], back: [0, 1]),
        lastReviewed: today,
        consecutiveCorrect: 0,
        factor: 1000,
        interval: 0,
        lapses: 1);

    [dueLater, dueNow, overDue, learning, lapsed].forEach((cardState) {
      emptyState.cardStates[getCardIdFromCardState(cardState)] = cardState;
    });

    CardsSchedule s = computeCardsSchedule(emptyState, laterTmrw);

    expect(s.learning.length, equals(2));
    expect(s.learning[1].uniqueId, equals(getCardIdFromCardState(lapsed)));
    expect(s.learning[0].uniqueId, equals(getCardIdFromCardState(learning)));
    expect(s.later[0].uniqueId, equals(getCardIdFromCardState(dueLater)));
    expect(s.due[0].uniqueId, equals(getCardIdFromCardState(dueNow)));
    expect(s.overdue[0].uniqueId, equals(getCardIdFromCardState(overDue)));
  });

  test("PickMostDue should return null when passed an empty schedule and state",
      () {
    DRState emptyState = makeEmptyState();
    CardsSchedule s = computeCardsSchedule(emptyState, today);
    final pick = pickMostDue(s, emptyState);
    expect(pick, isNull);
  });

  test(
      "PickMostDue should return the learning card reviewed most recently if two learning cards are in the deck",
      () {
    DRState emptyState = makeEmptyState();

    int id = generateId();
    Combination combination = Combination(front: [0], back: [1]);

    ReviewingCardState dueLater = ReviewingCardState(
        master: id,
        combination: combination,
        lapses: 0,
        lastReviewed: laterTmrw,
        factor: 1000,
        interval: 13.3);
    ReviewingCardState dueNow = ReviewingCardState(
        master: id,
        combination: Combination(front: [0, 1], back: [1]),
        lapses: 0,
        lastReviewed: laterTmrw,
        factor: 1000,
        interval: 0);

    ReviewingCardState overDue = ReviewingCardState(
        master: id,
        combination: Combination(front: [1], back: [0]),
        lapses: 0,
        lastReviewed: today,
        factor: 1000,
        interval: 0);

    LearningCardState learning = LearningCardState(
      master: id,
      combination: Combination(front: [1, 0], back: [0]),
      lastReviewed: today,
      consecutiveCorrect: 0,
    );

    LapsedCardState lapsed = LapsedCardState(
        master: id,
        combination: Combination(front: [1, 0], back: [0, 1]),
        lastReviewed: laterTmrw,
        consecutiveCorrect: 0,
        factor: 1000,
        interval: 0,
        lapses: 1);

    [dueLater, dueNow, overDue, learning, lapsed].forEach((cardState) {
      emptyState.cardStates[getCardIdFromCardState(cardState)] = cardState;
    });

    CardsSchedule s = computeCardsSchedule(emptyState, laterTmrw);
    CardId pick = pickMostDue(s, emptyState);
    expect(pick.uniqueId, equals(getCardIdFromCardState(learning)));
  });
}
