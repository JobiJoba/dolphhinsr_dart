class CardId {
  int id;
  String frontJoin;
  String backJoin;
  DateTime time;

  CardId(CardState state) {
    id = state.master;
    frontJoin = state.combination.front.join(',');
    backJoin = state.combination.front.join(',');
    time = state.lastReviewed;
  }

  CardId.fromIdAndCombi(int master, Combination combination) {
    id = master;
    frontJoin = combination.front.join(',');
    backJoin = combination.front.join(',');
  }
  CardId.fromReview(Review review) {
    id = review.master;
    frontJoin = review.combination.front.join(',');
    backJoin = review.combination.front.join(',');
    time = review.ts;
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
  int consecutiveCorrect;
  DateTime lastReviewed;
  double interval;

  CardState(this.master, this.combination, this.mode, this.consecutiveCorrect,
      this.lastReviewed, this.interval);

  static makeInitialCardState({id, combination}) {
    return LearningCardState(
        master: id,
        combination: combination,
        consecutiveCorrect: 0,
        lastReviewed: null);
  }
}

class LearningCardState extends CardState {
  @override
  String mode = "learning";

  LearningCardState(
      {int master,
      Combination combination,
      String mode,
      int consecutiveCorrect,
      DateTime lastReviewed,
      double interval})
      : super(master, combination, mode, consecutiveCorrect, lastReviewed,
            interval);
}

class ReviewingCardState extends CardState {
  @override
  String mode = "reviewing";

  int factor;
  int lapses;

  ReviewingCardState({
    int master,
    Combination combination,
    int consecutiveCorrect,
    int factor,
    int lapses,
    double interval,
    DateTime lastReviewed,
  }) : super(master, combination, "reviewing", consecutiveCorrect, lastReviewed,
            interval);
}

class LapsedCardState extends CardState {
  @override
  String mode = "lapsed";

  int factor;
  int lapses;

  LapsedCardState(
      {int master,
      Combination combination,
      int consecutiveCorrect,
      int factor,
      int lapses,
      double interval,
      DateTime lastReviewed})
      : super(master, combination, "lapsed", consecutiveCorrect, lastReviewed,
            interval);
}

class State {
  Map<int, CardState> cardStates;
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
      return due;
    } else if (name == "learning") {
      return due;
    }
  }
}
