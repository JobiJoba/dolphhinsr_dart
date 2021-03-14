import 'package:equatable/equatable.dart';

class CardId extends Equatable {
  CardId({this.id, this.frontJoin, this.backJoin, this.time, this.uniqueId});

  factory CardId.fromCombination(
      {String? master, required Combination combination}) {
    final id = master;
    final frontJoin = combination.front!.join(',');
    final backJoin = combination.back!.join(',');
    return CardId(
        id: id,
        frontJoin: frontJoin,
        backJoin: backJoin,
        time: null,
        uniqueId: '$id#$frontJoin@$backJoin');
  }

  factory CardId.fromState(CardState state) {
    final id = state.master;
    final frontJoin = state.combination!.front!.join(',');
    final backJoin = state.combination!.back!.join(',');
    return CardId(
        id: id,
        frontJoin: frontJoin,
        backJoin: backJoin,
        time: state.lastReviewed,
        uniqueId: '$id#$frontJoin@$backJoin');
  }

  factory CardId.fromReview(Review review) {
    final id = review.master;
    final frontJoin = review.combination!.front!.join(',');
    final backJoin = review.combination!.back!.join(',');
    return CardId(
        id: id,
        frontJoin: frontJoin,
        backJoin: backJoin,
        time: review.ts,
        uniqueId: '$id#$frontJoin@$backJoin');
  }

  final String? id;
  final String? frontJoin;
  final String? backJoin;
  final DateTime? time;
  final String? uniqueId;

  @override
  String toString() {
    return 'CardId(${uniqueId})';
  }

  @override
  List<Object?> get props => <Object?>[uniqueId];
}

class Combination extends Equatable {
  const Combination({this.front, this.back});

  final List<int>? front;
  final List<int>? back;

  @override
  String toString() {
    return 'Combination($front-$back)';
  }

  @override
  List<Object?> get props => <Object?>[front, back];
}

class Master extends Equatable {
  const Master({this.id, this.fields, this.combinations});

  final String? id;
  final List<String>? fields;
  final List<Combination>? combinations;

  @override
  String toString() {
    return 'Master($id-$fields-$combinations)';
  }

  @override
  List<Object?> get props => <Object?>[id];
}

enum Rating { Easy, Good, Hard, Again }

class Review extends Equatable {
  const Review({this.master, this.combination, this.ts, this.rating});

  final String? master;
  final Combination? combination;
  final DateTime? ts;
  final Rating? rating;

  @override
  List<Object?> get props => <Object?>[master, rating];
}

class DRCard extends Equatable {
  const DRCard(
      {this.master,
      this.combination,
      this.front,
      this.back,
      this.lastReviewed,
      this.dueDate});

  final String? master;
  final Combination? combination;
  final List<String>? front;
  final List<String>? back;
  final DateTime? lastReviewed;
  final DateTime? dueDate;

  @override
  List<Object?> get props => <Object?>[master, front, back];
}

abstract class CardState extends Equatable {
  const CardState(this.master, this.combination, this.mode, this.lastReviewed,
      this.interval);
  final String? master;
  final Combination? combination;

  final String mode;
  final DateTime? lastReviewed;
  final double? interval;

  @override
  String toString() {
    return 'CardState($master-$combination-$mode-$lastReviewed-$interval)';
  }

  @override
  List<Object?> get props => <Object?>[master, lastReviewed];
}

class LearningCardState extends CardState {
  const LearningCardState(
      {String? master,
      Combination? combination,
      this.consecutiveCorrect,
      DateTime? lastReviewed,
      double? interval})
      : super(master, combination, 'learning', lastReviewed, interval);

  final int? consecutiveCorrect;
}

class ReviewingCardState extends CardState {
  const ReviewingCardState({
    String? master,
    Combination? combination,
    this.factor,
    this.lapses,
    double? interval,
    DateTime? lastReviewed,
  }) : super(master, combination, 'reviewing', lastReviewed, interval);

  final double? factor;
  final int? lapses;
}

class LapsedCardState extends CardState {
  const LapsedCardState(
      {String? master,
      Combination? combination,
      this.consecutiveCorrect,
      this.factor,
      this.lapses,
      double? interval,
      DateTime? lastReviewed})
      : super(master, combination, 'lapsed', lastReviewed, interval);

  final double? factor;
  final int? lapses;
  final int? consecutiveCorrect;
}

class DRState extends Equatable {
  const DRState(this.cardStates);

  final Map<String?, CardState?> cardStates;

  @override
  List<Object> get props => [cardStates];
}

abstract class BaseScheduleAndStat extends Equatable {
  const BaseScheduleAndStat(this.later, this.due, this.overdue, this.learning);

  final int? later;
  final int? due;
  final int? overdue;
  final int? learning;

  @override
  List<Object?> get props => <Object?>[later, due, overdue, learning];
}

class SummaryStatics extends BaseScheduleAndStat {
  const SummaryStatics({int? later, int? due, int? overdue, int? learning})
      : super(later, due, overdue, learning);
}

class CardsSchedule extends Equatable {
  const CardsSchedule({this.later, this.due, this.overdue, this.learning});

  final List<CardId>? later;
  final List<CardId>? due;
  final List<CardId>? overdue;
  final List<CardId>? learning;

  List<CardId>? getPropertyValue(String name) {
    if (name == 'later') {
      return later;
    } else if (name == 'due') {
      return due;
    } else if (name == 'overdue') {
      return overdue;
    } else if (name == 'learning') {
      return learning;
    }

    // TODO(JobiJoba): create an error state
    return later;
  }

  @override
  List<Object?> get props => <Object?>[later, due, overdue, learning];
}
