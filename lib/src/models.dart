import 'package:equatable/equatable.dart';

class CardId extends Equatable {
  CardId({int master, Combination combination}) {
    id = master;
    frontJoin = combination.front.join(',');
    backJoin = combination.back.join(',');
    uniqueId = "$id#$frontJoin@$backJoin";
  }

  CardId.fromAllParameters(
      {this.id, this.frontJoin, this.backJoin, this.time, this.uniqueId});

  CardId.fromState(CardState state) {
    id = state.master;
    frontJoin = state.combination.front.join(',');
    backJoin = state.combination.back.join(',');
    time = state.lastReviewed;

    uniqueId = "$id#$frontJoin@$backJoin";
  }

  CardId.fromReview(Review review) {
    id = review.master;
    frontJoin = review.combination.front.join(',');
    backJoin = review.combination.back.join(',');
    time = review.ts;
    uniqueId = "$id#$frontJoin@$backJoin";
  }

  int id;
  String frontJoin;
  String backJoin;
  DateTime time;
  String uniqueId;

  @override
  List<Object> get props => <Object>[uniqueId];
}

class Combination extends Equatable {
  const Combination({this.front, this.back});

  final List<int> front;
  final List<int> back;

  @override
  List<Object> get props => <Object>[front, back];
}

class Master extends Equatable {
  const Master({this.id, this.fields, this.combinations});

  final int id;
  final List<String> fields;
  final List<Combination> combinations;

  @override
  List<Object> get props => <Object>[id];
}

enum Rating { Easy, Good, Hard, Again }

class Review extends Equatable {
  const Review({this.master, this.combination, this.ts, this.rating});

  final int master;
  final Combination combination;
  final DateTime ts;
  final Rating rating;

  @override
  List<Object> get props => <Object>[master, rating];
}

class DRCard extends Equatable {
  const DRCard({this.master, this.combination, this.front, this.back});

  final int master;
  final Combination combination;
  final List<String> front;
  final List<String> back;

  @override
  List<Object> get props => <Object>[master, front, back];
}

abstract class CardState extends Equatable {
  const CardState(this.master, this.combination, this.mode, this.lastReviewed,
      this.interval);
  final int master;
  final Combination combination;

  final String mode;
  final DateTime lastReviewed;
  final double interval;

  @override
  List<Object> get props => <Object>[master, lastReviewed];
}

class LearningCardState extends CardState {
  const LearningCardState(
      {int master,
      Combination combination,
      this.consecutiveCorrect,
      DateTime lastReviewed,
      double interval})
      : super(master, combination, "learning", lastReviewed, interval);

  final int consecutiveCorrect;
}

class ReviewingCardState extends CardState {
  const ReviewingCardState({
    int master,
    Combination combination,
    this.factor,
    this.lapses,
    double interval,
    DateTime lastReviewed,
  }) : super(master, combination, "reviewing", lastReviewed, interval);

  final double factor;
  final int lapses;
}

class LapsedCardState extends CardState {
  const LapsedCardState(
      {int master,
      Combination combination,
      this.consecutiveCorrect,
      this.factor,
      this.lapses,
      double interval,
      DateTime lastReviewed})
      : super(master, combination, "lapsed", lastReviewed, interval);

  final double factor;
  final int lapses;
  final int consecutiveCorrect;
}

class DRState extends Equatable {
  const DRState(this.cardStates);

  final Map<String, CardState> cardStates;

  @override
  List<Object> get props => [cardStates];
}

abstract class BaseScheduleAndStat extends Equatable {
  const BaseScheduleAndStat(this.later, this.due, this.overdue, this.learning);

  final int later;
  final int due;
  final int overdue;
  final int learning;

  @override
  List<Object> get props => <Object>[later, due, overdue, learning];
}

class Schedule extends BaseScheduleAndStat {
  const Schedule({int later, int due, int overdue, int learning})
      : super(later, due, overdue, learning);
}

class SummaryStatics extends BaseScheduleAndStat {
  const SummaryStatics({int later, int due, int overdue, int learning})
      : super(later, due, overdue, learning);
}

class CardsSchedule extends Equatable {
  const CardsSchedule({this.later, this.due, this.overdue, this.learning});

  final List<CardId> later;
  final List<CardId> due;
  final List<CardId> overdue;
  final List<CardId> learning;

  List<CardId> getPropertyValue(String name) {
    if (name == "later") {
      return later;
    } else if (name == "due") {
      return due;
    } else if (name == "overdue") {
      return overdue;
    } else if (name == "learning") {
      return learning;
    }

    // TODO(JobiJoba): create an error state, https://github.com/NoIssueYet
    return later;
  }

  @override
  List<Object> get props => <Object>[later, due, overdue, learning];
}
