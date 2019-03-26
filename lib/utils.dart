import 'package:dolphinsr_dart/models.dart';
import 'dart:math' as math;

class Utils {
  static List<Review> addReview(List<Review> reviews, Review review) {
    if (reviews.length == 0) {
      return [review];
    }
    var i = reviews.length - 1;
    for (; i >= 0; i -= 1) {
      if (reviews[i].ts.isBefore(review.ts) ||
          reviews[i].ts.isAtSameMomentAs(review.ts)) {
        break;
      }
    }

    List<Review> newReviews = reviews.sublist(0);
    newReviews.insert(i + 1, review);

    return newReviews;
  }

// constants from Anki defaults
// TODO(April 1, 2017) investigate rationales, consider changing them
  static final double INITIAL_FACTOR = 2500;
  static final double INITIAL_DAYS_WITHOUT_JUMP = 4;
  static final double INITIAL_DAYS_WITH_JUMP = 1;

  static applyToLearningCardState(
      LearningCardState prev, DateTime ts, Rating rating) {
    if (rating == Rating.Easy ||
        (rating == Rating.Easy || rating == Rating.Good) &&
            prev.consecutiveCorrect > 0) {
      var interval = prev.consecutiveCorrect > 0
          ? INITIAL_DAYS_WITHOUT_JUMP
          : INITIAL_DAYS_WITH_JUMP;

      return ReviewingCardState(
          master: prev.master,
          combination: prev.combination,
          factor: INITIAL_FACTOR,
          lapses: 0,
          interval: interval.toDouble(),
          lastReviewed: ts);
    } else if (rating == Rating.Again) {
      return LearningCardState(
          master: prev.master,
          combination: prev.combination,
          consecutiveCorrect: 0,
          lastReviewed: ts);
    } else if ((rating == Rating.Good || rating == Rating.Hard) &&
        prev.consecutiveCorrect < 1) {
      return LearningCardState(
          master: prev.master,
          combination: prev.combination,
          consecutiveCorrect: prev.consecutiveCorrect + 1,
          lastReviewed: ts);
    }
  }

  static final int EASY_BONUS = 2;
  static final int MAX_INTERVAL = 365;
  static final int MIN_FACTOR = 0; // TODO
  static final int MAX_FACTOR = 2147483647;
  static constrainWithin(double min, int max, double n) {
    return math.max(math.min(n, max), min);
  }

  static DateTime calculateDueDate(CardState state) {
    DateTime result = state.lastReviewed;

    var newHour = 3;
    var newDay = result.day + state.interval.ceil();
    DateTime newResult = result.toLocal();
    newResult = DateTime(result.year, result.month, newDay, newHour,
        result.minute, result.second, result.millisecond, result.microsecond);

    return newResult;
  }

  static computeScheduleFromCardState(CardState state, DateTime now) {
    if (state.mode == "lapsed" || state.mode == "learning") {
      return "learning";
    } else if (state.mode == "reviewing") {
      var diff = dateDiffInDays(calculateDueDate(state), now);
      if (diff < 0) {
        return "later";
      } else if (diff >= 0 && diff < 1) {
        return "due";
      } else if (diff >= 1) {
        return "overdue";
      }
    }

    throw Exception("Issue with mode and calculation of a cardState");
  }

  static pickMostDue(CardsSchedule s, State state) {
    List<String> scheduleKey = ["learning", "overdue", "due"];
    for (int i = 0; i < scheduleKey.length; i++) {
      String key = scheduleKey[i];
      List<CardId> propertyValue = s.getPropertyValue(key);
      if (propertyValue.length > 0) {
        List<CardId> first = propertyValue.sublist(0);

        first.sort((CardId a, CardId b) {
          CardState cardA = state.cardStates[a.id];
          CardState cardB = state.cardStates[b.id];

          var reviewDiff = (cardA.lastReviewed == null &&
                  cardB.lastReviewed != null)
              ? 1
              : (cardB.lastReviewed == null && cardA.lastReviewed != null)
                  ? -1
                  : (cardA.lastReviewed == null && cardB.lastReviewed == null)
                      ? 0
                      : (cardB.lastReviewed).compareTo(cardA.lastReviewed);

          if (reviewDiff != 0) {
            return -reviewDiff;
          }
          if (a == b) {
            throw Exception("comparing duplicate id: $a");
          }
          //TODO CHECK THAT
          return a.id > b.id ? 0 : 1;
        });
        return first[0];
      }
    }
  }

  static computeCardsSchedule(State state, DateTime now) {
    CardsSchedule s = CardsSchedule([], [], [], []);

    state.cardStates
        .forEach((id, value) => forEachCalculSchedule(value, now, s));

    return s;
  }

  static forEachCalculSchedule(
      CardState cardState, DateTime now, CardsSchedule s) {
    String calculatedSchedule = computeScheduleFromCardState(cardState, now);

    List<CardId> rightSchedule = s.getPropertyValue(calculatedSchedule);

    rightSchedule.add(CardId(cardState));
  }

  static double dateDiffInDays(DateTime a, DateTime b) {
    // adapted from http://stackoverflow.com/a/15289883/251162
    const MS_PER_DAY = 1000 * 60 * 60 * 24;

    // Disstate the time and time-zone information.

    var utc1 = DateTime.utc(a.year, a.month, a.day);

    var utc2 = DateTime.utc(b.year, b.month, b.day);

    return (utc2.difference(utc1)).inMilliseconds / MS_PER_DAY;
  }

  static calculateDaysLate(ReviewingCardState state, DateTime actual) {
    DateTime excpected = calculateDueDate(state);

    double daysLate = dateDiffInDays(actual, excpected);

    return daysLate;
  }

  static applyToReviewingCardState(
      ReviewingCardState prev, DateTime ts, Rating rating) {
    if (rating == Rating.Again) {
      return LapsedCardState(
          master: prev.master,
          combination: prev.combination,
          consecutiveCorrect: 0,
          factor: constrainWithin(
              MIN_FACTOR.toDouble(), MAX_FACTOR, prev.factor.toDouble() - 200),
          lapses: prev.lapses + 1,
          interval: prev.interval,
          lastReviewed: ts);
    }

    double factorAdj = (rating == Rating.Hard
        ? -150
        : rating == Rating.Good ? 0 : rating == Rating.Easy ? 150 : double.nan);

    double daysLate = calculateDaysLate(prev, ts);

    double fact = rating == Rating.Hard
        ? (prev.interval + (daysLate / 4)) * 1.2
        : rating == Rating.Good
            ? ((prev.interval + (daysLate / 2)) * prev.factor) / 1000
            : rating == Rating.Easy
                ? (((prev.interval + daysLate) * prev.factor) / 1000) *
                    EASY_BONUS
                : double.nan;
    double ival = constrainWithin(prev.interval + 1, MAX_INTERVAL, fact);

    return ReviewingCardState(
        master: prev.master,
        combination: prev.combination,
        factor: constrainWithin(
            MIN_FACTOR.toDouble(), MAX_FACTOR, prev.factor + factorAdj),
        lapses: prev.lapses,
        interval: ival,
        lastReviewed: ts);
  }

  static applyToLapsedCardState(
      LapsedCardState prev, DateTime ts, Rating rating) {
    if (rating == Rating.Easy ||
        ((rating == Rating.Easy || rating == Rating.Good) &&
            prev.consecutiveCorrect > 0)) {
      return ReviewingCardState(
        master: prev.master,
        combination: prev.combination,
        factor: prev.factor,
        lapses: prev.lapses,
        interval: prev.consecutiveCorrect > 0
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
            rating == Rating.Again ? 0 : prev.consecutiveCorrect + 1);
  }

  static applyToCardState(CardState prev, DateTime ts, Rating rating) {
    if (prev.lastReviewed != null && prev.lastReviewed.isAfter(ts)) {
      throw ("Cannot apply review before current lastReviewed");
    }

    if (prev.mode == "learning") {
      return applyToLearningCardState(prev, ts, rating);
    } else if (prev.mode == "reviewing") {
      return applyToReviewingCardState(prev, ts, rating);
    } else if (prev.mode == "lapsed") {
      return applyToLapsedCardState(prev, ts, rating);
    }

    throw Exception("Card mode is incorrect");
  }

  static State applyReview(State prev, Review review) {
    CardId cardId = CardId.fromReview(review);

    CardState cardState = prev.cardStates[cardId.uniqueId];
    if (cardState == null) {
      throw ("applying review to missing card: ${review.master}");
    }
    State newState = State(Map<String, CardState>.from(prev.cardStates));

    newState.cardStates[cardId.uniqueId] =
        applyToCardState(cardState, review.ts, review.rating);

    return newState;
  }
}
