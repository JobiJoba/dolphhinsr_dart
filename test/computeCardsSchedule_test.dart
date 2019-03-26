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
  test("should add a rounded interval to the lastReviewed, set at 3am", () {
    int id = generateId();
    Combination combination = Combination([0], [1]);
    ReviewingCardState stateCard = ReviewingCardState(
        master: id,
        combination: combination,
        lapses: 0,
        lastReviewed: Dates.today,
        factor: 1000,
        interval: 13.3);

    DateTime due = Utils.calculateDueDate(stateCard);

    DateTime expectedDate = Dates.todayAt3AM.add(Duration(days: 14));
    expect(due, equals(expectedDate));
  });
  test("should return later for cards that are reviewing and not yet due", () {
    int id = generateId();
    Combination combination = Combination([0], [1]);

    ReviewingCardState stateCard = ReviewingCardState(
        master: id,
        combination: combination,
        lapses: 0,
        lastReviewed: Dates.today,
        factor: 1000,
        interval: 13.3);

    String computeSchedule =
        Utils.computeScheduleFromCardState(stateCard, Dates.laterTmrw);

    expect(computeSchedule, equals("later"));
  });

  test("should return due for cards that are reviewing and due within the day",
      () {
    int id = generateId();
    Combination combination = Combination([0], [1]);

    ReviewingCardState stateCard = ReviewingCardState(
        master: id,
        combination: combination,
        lapses: 0,
        lastReviewed: Dates.today,
        factor: 1000,
        interval: 13.3);

    String computeSchedule = Utils.computeScheduleFromCardState(
        stateCard, Dates.todayAt3AM.add(Duration(days: 14)));

    expect(computeSchedule, equals("due"));

    computeSchedule = Utils.computeScheduleFromCardState(
        stateCard, Dates.laterToday.add(Duration(days: 14)));
    expect(computeSchedule, equals("due"));
  });

  test("should return overdue for cards that reviewing and due before the day",
      () {
    int id = generateId();
    Combination combination = Combination([0], [1]);

    ReviewingCardState stateCard = ReviewingCardState(
        master: id,
        combination: combination,
        lapses: 0,
        lastReviewed: Dates.today,
        factor: 1000,
        interval: 13.3);

    String computeSchedule = Utils.computeScheduleFromCardState(
        stateCard, Dates.todayAt3AM.add(Duration(days: 15)));

    expect(computeSchedule, equals("overdue"));

    computeSchedule = Utils.computeScheduleFromCardState(
        stateCard, Dates.laterToday.add(Duration(days: 15)));
    expect(computeSchedule, equals("overdue"));
  });

  test("should return an empty schedule when passed an empty state", () {
    State emptyState = State.makeEmptyState();

    expect(Utils.computeCardsSchedule(emptyState, Dates.today).learning.length,
        equals(0));
    expect(Utils.computeCardsSchedule(emptyState, Dates.today).later.length,
        equals(0));
    expect(Utils.computeCardsSchedule(emptyState, Dates.today).due.length,
        equals(0));
    expect(Utils.computeCardsSchedule(emptyState, Dates.today).overdue.length,
        equals(0));
  });

  test("should a sorted list of cards when passed cards in multiple states",
      () {
    State emptyState = State.makeEmptyState();

    int id = generateId();
    Combination combination = Combination([0], [1]);

    ReviewingCardState dueLater = ReviewingCardState(
        master: id,
        combination: combination,
        lapses: 0,
        lastReviewed: Dates.laterTmrw,
        factor: 1000,
        interval: 13.3);
    ReviewingCardState dueNow = ReviewingCardState(
        master: id,
        combination: Combination([0, 1], [1]),
        lapses: 0,
        lastReviewed: Dates.laterTmrw,
        factor: 1000,
        interval: 0);

    ReviewingCardState overDue = ReviewingCardState(
        master: id,
        combination: Combination([1], [0]),
        lapses: 0,
        lastReviewed: Dates.today,
        factor: 1000,
        interval: 0);

    LearningCardState learning = LearningCardState(
      master: id,
      combination: Combination([1, 0], [0]),
      lastReviewed: Dates.today,
      consecutiveCorrect: 0,
    );

    LapsedCardState lapsed = LapsedCardState(
        master: id,
        combination: Combination([1, 0], [0, 1]),
        lastReviewed: Dates.today,
        consecutiveCorrect: 0,
        factor: 1000,
        interval: 0,
        lapses: 1);

    [dueLater, dueNow, overDue, learning, lapsed].forEach((cardState) {
      emptyState.cardStates[Utils.getCardIdFromCardState(cardState)] =
          cardState;
    });

    CardsSchedule s = Utils.computeCardsSchedule(emptyState, Dates.laterTmrw);

    expect(s.learning.length, equals(2));
    expect(
        s.learning[1].uniqueId, equals(Utils.getCardIdFromCardState(lapsed)));
    expect(
        s.learning[0].uniqueId, equals(Utils.getCardIdFromCardState(learning)));
    expect(s.later[0].uniqueId, equals(Utils.getCardIdFromCardState(dueLater)));
    expect(s.due[0].uniqueId, equals(Utils.getCardIdFromCardState(dueNow)));
    expect(
        s.overdue[0].uniqueId, equals(Utils.getCardIdFromCardState(overDue)));
  });

  test("PickMostDue should return null when passed an empty schedule and state",
      () {
    State emptyState = State.makeEmptyState();
    CardsSchedule s = Utils.computeCardsSchedule(emptyState, Dates.today);
    var pickMostDue = Utils.pickMostDue(s, emptyState);
    expect(pickMostDue, isNull);
  });

  test(
      "PickMostDue should return the learning card reviewed most recently if two learning cards are in the deck",
      () {
    State emptyState = State.makeEmptyState();

    int id = generateId();
    Combination combination = Combination([0], [1]);

    ReviewingCardState dueLater = ReviewingCardState(
        master: id,
        combination: combination,
        lapses: 0,
        lastReviewed: Dates.laterTmrw,
        factor: 1000,
        interval: 13.3);
    ReviewingCardState dueNow = ReviewingCardState(
        master: id,
        combination: Combination([0, 1], [1]),
        lapses: 0,
        lastReviewed: Dates.laterTmrw,
        factor: 1000,
        interval: 0);

    ReviewingCardState overDue = ReviewingCardState(
        master: id,
        combination: Combination([1], [0]),
        lapses: 0,
        lastReviewed: Dates.today,
        factor: 1000,
        interval: 0);

    LearningCardState learning = LearningCardState(
      master: id,
      combination: Combination([1, 0], [0]),
      lastReviewed: Dates.today,
      consecutiveCorrect: 0,
    );

    LapsedCardState lapsed = LapsedCardState(
        master: id,
        combination: Combination([1, 0], [0, 1]),
        lastReviewed: Dates.laterTmrw,
        consecutiveCorrect: 0,
        factor: 1000,
        interval: 0,
        lapses: 1);

    [dueLater, dueNow, overDue, learning, lapsed].forEach((cardState) {
      emptyState.cardStates[Utils.getCardIdFromCardState(cardState)] =
          cardState;
    });

    CardsSchedule s = Utils.computeCardsSchedule(emptyState, Dates.laterTmrw);
    CardId pickMostDue = Utils.pickMostDue(s, emptyState);
    expect(
        pickMostDue.uniqueId, equals(Utils.getCardIdFromCardState(learning)));
  });
}
