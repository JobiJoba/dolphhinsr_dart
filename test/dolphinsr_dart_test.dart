import 'package:dolphinsr_dart/dolphinsr_dart.dart';
import 'package:dolphinsr_dart/src/models.dart';
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
  test("should start out empty", () {
    DolphinSR d = DolphinSR();
    expect(d.nextCard(), isNull);

    SummaryStatics s = SummaryStatics(0, 0, 0, 0);
    expect(d.summary(), equals(s));
  });

  test("should add a new masters to the learning", () {
    DolphinSR d = DolphinSR();
    int id = generateId();
    Master master = Master(id, [
      'Hello',
      "world"
    ], [
      Combination([0], [1, 0])
    ]);

    d.addMasters([master]);

    DRCard nextCard = d.nextCard();
    DRCard expectedCard = DRCard(
        master: id,
        combination: Combination([0], [1, 0]),
        front: ["Hello"],
        back: ["world", "Hello"]);
    expect(nextCard, equals(expectedCard));
  });

  test("should add multiple new masters to the learning category", () {
    DolphinSR d = DolphinSR();
    int id = generateId();
    Master master = Master(id, [
      'Hello',
      "world"
    ], [
      Combination([0], [1, 0])
    ]);
    int id2 = generateId();

    Master master2 = Master(id2, [
      'Hello',
      "world"
    ], [
      Combination([0], [1, 0])
    ]);

    d.addMasters([master, master2]);

    SummaryStatics s = SummaryStatics(0, 0, 0, 2);
    expect(d.summary(), equals(s));

    int id3 = generateId();

    Master master3 = Master(id3, [
      'Hello',
      "world"
    ], [
      Combination([0], [1, 0])
    ]);

    d.addMasters([master3]);
    s = SummaryStatics(0, 0, 0, 3);
    expect(d.summary(), equals(s));
  });

  test("should add reviews", () {
    DolphinSR d = DolphinSR(currentDateGetter: Dates.today);
    int id = generateId();
    Combination combination = Combination([0], [1, 0]);
    Master master = Master(id, ['Hello', "world"], [combination]);

    d.addMasters([master]);

    DRCard nextCard = d.nextCard();
    DRCard expectedCard = DRCard(
        master: id,
        combination: Combination([0], [1, 0]),
        front: ["Hello"],
        back: ["world", "Hello"]);
    expect(nextCard, equals(expectedCard));
    expect(d.summary().learning, equals(1));

    Review review = Review(id, combination, Dates.today, Rating.Easy);
    d.addReviews([review]);

    expect(d.summary().later, equals(1));
    expect(d.nextCard(), isNull);

    Master secondMaster =
        Master(generateId(), ['Hello', "world"], [combination]);
    d.addMasters([secondMaster]);
    expect(d.summary().learning, equals(1));
    expect(d.summary().later, equals(1));
    d.addReviews([
      Review(secondMaster.id, secondMaster.combinations[0], Dates.today,
          Rating.Easy)
    ]);
    expect(d.summary().later, equals(2));
    expect(d.nextCard(), isNull);
  });

  /* test("Will it works ? ", () {
    DolphinSR d = DolphinSR(currentDateGetter: Dates.today);
    int id = generateId();
    Combination combination = Combination([0], [1, 0]);
    Master master = Master(id, ['Hello', "world"], [combination]);

    d.addMasters([master]);

    Card nextCard = d.nextCard();
    Card expectedCard = Card(
        master: id,
        combination: Combination([0], [1, 0]),
        front: ["Hello"],
        back: ["world", "Hello"]);
    expect(nextCard, equals(expectedCard));
    expect(d.summary().learning, equals(1));

    Review review = Review(id, combination, Dates.laterTmrw, Rating.Easy);
    d.addReviews([review]);
    d.currentDateGetter = Dates.laterTmrw;
    review.ts = Dates.today;
    d.addReviews([review]);

    expect(d.summary().later, equals(1));
  }); */
}
