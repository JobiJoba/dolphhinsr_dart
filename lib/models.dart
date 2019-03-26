class CardId {
  int id;
  String frontJoin;
  String backJoin;
  DateTime time;

  String uniqueId;

  CardId(CardState state) {
    id = state.master;
    frontJoin = state.combination.front.join(',');
    backJoin = state.combination.back.join(',');
    time = state.lastReviewed;

    uniqueId = "$id#$frontJoin@$backJoin";
  }

  CardId.fromIdAndCombi(int master, Combination combination) {
    id = master;
    frontJoin = combination.front.join(',');
    backJoin = combination.back.join(',');
    uniqueId = "$id#$frontJoin@$backJoin";
  }
  CardId.fromReview(Review review) {
    id = review.master;
    frontJoin = review.combination.front.join(',');
    backJoin = review.combination.back.join(',');
    time = review.ts;
    uniqueId = "$id#$frontJoin@$backJoin";
  }
}

class Combination {
  List<int> front;
  List<int> back;

  Combination(this.front, this.back);
}

class Master {
  int id;
  List<String> fields;
  List<Combination> combinations;

  Master(this.id, this.fields, this.combinations);
}

enum Rating { Easy, Good, Hard, Again }

class Review {
  int master;
  Combination combination;
  DateTime ts;
  Rating rating;

  Review(this.master, this.combination, this.ts, this.rating);
}

class Card {
  int master;
  Combination combination;
  List<String> front;
  List<String> back;

  Card(this.master, this.combination, this.front, this.back);
}

abstract class CardState {
  int master;
  Combination combination;

  String mode;
  DateTime lastReviewed;
  double interval;

  CardState(this.master, this.combination, this.mode, this.lastReviewed,
      this.interval);

  int get hashCode => master.hashCode ^ interval.hashCode;

  bool operator ==(o) => o is CardState && master == o.master;

  static makeInitialCardState({int id, Combination combination}) {
    return LearningCardState(
        master: id,
        combination: combination,
        lastReviewed: null,
        consecutiveCorrect: 0);
  }
}

class LearningCardState extends CardState {
  int consecutiveCorrect;
  LearningCardState(
      {int master,
      Combination combination,
      this.consecutiveCorrect,
      DateTime lastReviewed,
      double interval})
      : super(master, combination, "learning", lastReviewed, interval);
}

class ReviewingCardState extends CardState {
  double factor;
  int lapses;

  ReviewingCardState({
    int master,
    Combination combination,
    this.factor,
    this.lapses,
    double interval,
    DateTime lastReviewed,
  }) : super(master, combination, "reviewing", lastReviewed, interval);
}

class LapsedCardState extends CardState {
  double factor;
  int lapses;
  int consecutiveCorrect;
  LapsedCardState(
      {int master,
      Combination combination,
      this.consecutiveCorrect,
      this.factor,
      this.lapses,
      double interval,
      DateTime lastReviewed})
      : super(master, combination, "lapsed", lastReviewed, interval);
}

class State {
  Map<String, CardState> cardStates;
  static makeEmptyState() {
    return State(new Map());
  }

  State(this.cardStates);
}

abstract class BaseScheduleAndStat {
  int later;
  int due;
  int overdue;
  int learning;
  BaseScheduleAndStat(this.later, this.due, this.overdue, this.learning);
}

class Schedule extends BaseScheduleAndStat {
  Schedule(int later, int due, int overdue, int learning)
      : super(later, due, overdue, learning);
}

class SummaryStatics extends BaseScheduleAndStat {
  SummaryStatics(int later, int due, int overdue, int learning)
      : super(later, due, overdue, learning);
}

class CardsSchedule {
  List<CardId> later;
  List<CardId> due;
  List<CardId> overdue;
  List<CardId> learning;

  CardsSchedule(this.later, this.due, this.overdue, this.learning);

  getPropertyValue(String name) {
    if (name == "later") {
      return later;
    } else if (name == "due") {
      return due;
    } else if (name == "overdue") {
      return overdue;
    } else if (name == "learning") {
      return learning;
    }
  }
}
