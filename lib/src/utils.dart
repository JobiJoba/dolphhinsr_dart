import 'dart:math' as math;
import './models.dart';

List<Review> addReview(List<Review> reviews, Review review) {
  if (reviews.isEmpty) {
    return <Review>[review];
  }
  var i = reviews.length - 1;
  for (; i >= 0; i -= 1) {
    if (reviews[i].ts!.isBefore(review.ts!) ||
        reviews[i].ts!.isAtSameMomentAs(review.ts!)) {
      break;
    }
  }

  final newReviews = reviews.sublist(0);
  newReviews.insert(i + 1, review);

  return newReviews;
}

// constants from Anki defaults
const double INITIAL_FACTOR = 2500;
const double INITIAL_DAYS_WITHOUT_JUMP = 4;
const double INITIAL_DAYS_WITH_JUMP = 1;

const int EASY_BONUS = 2;
const int MAX_INTERVAL = 365;
const int MIN_FACTOR = 0;
const int MAX_FACTOR = 2147483647;

CardState? applyToLearningCardState(
    LearningCardState prev, DateTime? ts, Rating? rating) {
  if (rating == Rating.Easy ||
      (rating == Rating.Easy || rating == Rating.Good) &&
          prev.consecutiveCorrect! > 0) {
    final interval = prev.consecutiveCorrect! > 0
        ? INITIAL_DAYS_WITHOUT_JUMP
        : INITIAL_DAYS_WITH_JUMP;
    return ReviewingCardState(
        master: prev.master,
        combination: prev.combination,
        factor: INITIAL_FACTOR,
        lapses: 0,
        interval: interval.toDouble(),
        lastReviewed: ts);
  } else if (rating == Rating.Again || rating == Rating.Hard) {
    return LearningCardState(
        master: prev.master,
        combination: prev.combination,
        consecutiveCorrect: 0,
        lastReviewed: ts);
  } else if ((rating == Rating.Good) && prev.consecutiveCorrect! < 1) {
    return LearningCardState(
        master: prev.master,
        combination: prev.combination,
        consecutiveCorrect: prev.consecutiveCorrect! + 1,
        lastReviewed: ts);
  }

  // TODO(JobiJoba): Should return an error state.
  return null;
}

num constrainWithin(double min, int max, double n) {
  return math.max(math.min(n, max), min);
}

DateTime? calculateDueDate(CardState state) {
  final result = state.lastReviewed;
  if (result == null || state.interval == null) return null;

  const newHour = 3;
  final newDay = result.day + state.interval!.ceil();
  var newResult = result.toLocal();
  newResult = DateTime(result.year, result.month, newDay, newHour,
      result.minute, result.second, result.millisecond, result.microsecond);

  return newResult;
}

String computeScheduleFromCardState(CardState state, DateTime? now) {
  if (state.mode == 'lapsed' || state.mode == 'learning') {
    return 'learning';
  } else if (state.mode == 'reviewing') {
    final diff = dateDiffInDays(calculateDueDate(state)!, now!);
    if (diff < 0) {
      return 'later';
    } else if (diff >= 0 && diff < 1) {
      return 'due';
    } else if (diff >= 1) {
      return 'overdue';
    }
  }

  throw Exception('Issue with mode and calculation of a cardState');
}

CardId? pickMostDue(CardsSchedule? s, DRState? state) {
  final scheduleKey = <String>['learning', 'overdue', 'due'];

  for (var i = 0; i < scheduleKey.length; i++) {
    final key = scheduleKey[i];
    final propertyValue = s!.getPropertyValue(key)!;
    if (propertyValue.isNotEmpty) {
      final first = propertyValue.sublist(0);

      first.sort((CardId a, CardId b) {
        final cardA = state!.cardStates[a.uniqueId]!;
        final cardB = state.cardStates[b.uniqueId];

        final reviewDiff =
            (cardA.lastReviewed == null && cardB!.lastReviewed != null)
                ? 1
                : (cardB!.lastReviewed == null && cardA.lastReviewed != null)
                    ? -1
                    : (cardA.lastReviewed == null && cardB.lastReviewed == null)
                        ? 0
                        : cardB.lastReviewed!.compareTo(cardA.lastReviewed!);

        if (reviewDiff != 0) {
          return -reviewDiff;
        }
        if (a == b) {
          throw Exception('comparing duplicate id: $a');
        }
        return a.id!.compareTo(b.id!) == -1 ? 0 : 1;
      });
      return first[0];
    }
  }
  return null;
}

CardsSchedule computeCardsSchedule(DRState state, DateTime? now) {
  final s = CardsSchedule(
      later: <CardId>[],
      due: <CardId>[],
      overdue: <CardId>[],
      learning: <CardId>[]);

  for (final cardStateKey in state.cardStates.keys) {
    final cardState = state.cardStates[cardStateKey]!;

    final calculatedSchedule = computeScheduleFromCardState(cardState, now);

    s.getPropertyValue(calculatedSchedule)!.add(CardId.fromState(cardState));
  }

  return s;
}

double dateDiffInDays(DateTime a, DateTime b) {
  // adapted from http://stackoverflow.com/a/15289883/251162
  const MS_PER_DAY = 1000 * 60 * 60 * 24;

  // Disstate the time and time-zone information.

  final utc1 = DateTime.utc(a.year, a.month, a.day);

  final utc2 = DateTime.utc(b.year, b.month, b.day);

  return (utc2.difference(utc1)).inMilliseconds / MS_PER_DAY;
}

double calculateDaysLate(ReviewingCardState state, DateTime actual) {
  final excpected = calculateDueDate(state)!;

  final daysLate = dateDiffInDays(actual, excpected);

  return daysLate;
}

CardState applyToReviewingCardState(
    ReviewingCardState prev, DateTime? ts, Rating? rating) {
  if (rating == Rating.Again) {
    return LapsedCardState(
        master: prev.master,
        combination: prev.combination,
        consecutiveCorrect: 0,
        factor: constrainWithin(
            MIN_FACTOR.toDouble(), MAX_FACTOR, prev.factor!.toDouble() - 200) as double?,
        lapses: prev.lapses! + 1,
        interval: prev.interval,
        lastReviewed: ts);
  }

  final factorAdj = rating == Rating.Hard
      ? -150
      : rating == Rating.Good
          ? 0
          : rating == Rating.Easy
              ? 150
              : double.nan;

  final daysLate = calculateDaysLate(prev, ts!);

  final fact = rating == Rating.Hard
      ? (prev.interval! + (daysLate / 4)) * 1.2
      : rating == Rating.Good
          ? ((prev.interval! + (daysLate / 2)) * prev.factor!) / 1000
          : rating == Rating.Easy
              ? (((prev.interval! + daysLate) * prev.factor!) / 1000) * EASY_BONUS
              : double.nan;
  final ival = constrainWithin(prev.interval! + 1, MAX_INTERVAL, fact);

  return ReviewingCardState(
      master: prev.master,
      combination: prev.combination,
      factor: constrainWithin(
          MIN_FACTOR.toDouble(), MAX_FACTOR, prev.factor! + factorAdj) as double?,
      lapses: prev.lapses,
      interval: ival as double?,
      lastReviewed: ts);
}

CardState applyToLapsedCardState(
    LapsedCardState prev, DateTime? ts, Rating? rating) {
  if (rating == Rating.Easy ||
      ((rating == Rating.Easy || rating == Rating.Good) &&
          prev.consecutiveCorrect! > 0)) {
    return ReviewingCardState(
      master: prev.master,
      combination: prev.combination,
      factor: prev.factor,
      lapses: prev.lapses,
      interval: prev.consecutiveCorrect! > 0
          ? INITIAL_DAYS_WITHOUT_JUMP
          : INITIAL_DAYS_WITH_JUMP,
      lastReviewed: ts,
    );
  }

  return LapsedCardState(
      master: prev.master,
      combination: prev.combination,
      factor: prev.factor,
      lapses: prev.lapses,
      interval: prev.interval,
      lastReviewed: ts,
      consecutiveCorrect:
          rating == Rating.Again ? 0 : prev.consecutiveCorrect! + 1);
}

CardState? applyToCardState(CardState prev, DateTime? ts, Rating? rating) {
  if (prev.lastReviewed != null && prev.lastReviewed!.isAfter(ts!)) {
    throw 'Cannot apply review before current lastReviewed';
  }

  if (prev.mode == 'learning') {
    return applyToLearningCardState(prev as LearningCardState, ts, rating);
  } else if (prev.mode == 'reviewing') {
    return applyToReviewingCardState(prev as ReviewingCardState, ts, rating);
  } else if (prev.mode == 'lapsed') {
    return applyToLapsedCardState(prev as LapsedCardState, ts, rating);
  }

  throw Exception('Card mode is incorrect');
}

DRState applyReview(DRState prev, Review review) {
  final cardId = CardId.fromReview(review);

  final cardState = prev.cardStates[cardId.uniqueId];

  if (cardState == null) {
    throw '''applying review to missing card: ${review.master}''';
  }
  final newState = DRState(Map<String, CardState>.from(prev.cardStates));

  newState.cardStates[cardId.uniqueId] =
      applyToCardState(cardState, review.ts, review.rating);

  return newState;
}

String getCardIdFromCardState(CardState cardState) {
  final id = cardState.master;
  final frontJoin = cardState.combination!.front!.join(',');
  final backJoin = cardState.combination!.back!.join(',');
  return '$id#$frontJoin@$backJoin';
}

DRState makeEmptyState() {
  return DRState(<String, CardState>{});
}

LearningCardState makeInitialCardState({String? id, Combination? combination}) {
  return LearningCardState(
      master: id,
      combination: combination,
      lastReviewed: null,
      consecutiveCorrect: 0);
}
