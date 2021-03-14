import 'dart:math' as math;
import 'package:dolphinsr_dart/dolphinsr_dart.dart';
import 'package:dolphinsr_dart/src/models.dart';
import 'package:test/test.dart';
import 'dates.dart';

final String master = generateId();

String generateId() {
  return math.Random().nextInt(666).toString();
}

Review makeReview(DateTime ts) {
  return Review(
    master: generateId(),
    combination: const Combination(front: <int>[0], back: <int>[1]),
    ts: ts,
    rating: Rating.Easy,
  );
}

final List<Review> reviews = <DateTime>[
  today,
  todayAt3AM,
  laterToday,
  laterTmrw,
  laterInTwoDays,
  laterInFourDays,
].map(makeReview).toList();

void main() {
  test('should start out empty', () {
    final d = DolphinSR();
    expect(d.nextCard(), isNull);

    var s =
        const SummaryStatics(later: 0, due: 0, overdue: 0, learning: 0);
    expect(d.summary(), equals(s));
  });

  test('should add a new masters to the learning', () {
    var d = DolphinSR();
    var id = generateId();
    var master = Master(id: id, fields: [
      'Hello',
      'world'
    ], combinations: [
      Combination(front: [0], back: [1, 0])
    ]);

    d.addMasters([master]);

    var nextCard = d.nextCard();
    var expectedCard = DRCard(
        master: id,
        combination: Combination(front: [0], back: [1, 0]),
        front: ['Hello'],
        back: ['world', 'Hello']);
    expect(nextCard, equals(expectedCard));
  });

  test('should add multiple new masters to the learning category', () {
    var d = DolphinSR();
    var id = generateId();
    var master = Master(id: id, fields: [
      'Hello',
      'world'
    ], combinations: [
      Combination(front: [0], back: [1, 0])
    ]);
    var id2 = generateId();

    var master2 = Master(id: id2, fields: [
      'Hello',
      'world'
    ], combinations: [
      Combination(front: [0], back: [1, 0])
    ]);

    d.addMasters([master, master2]);

    var s =
        SummaryStatics(later: 0, due: 0, overdue: 0, learning: 2);
    expect(d.summary(), equals(s));

    var id3 = generateId();

    var master3 = Master(id: id3, fields: [
      'Hello',
      'world'
    ], combinations: [
      Combination(front: [0], back: [1, 0])
    ]);

    d.addMasters([master3]);
    s = SummaryStatics(later: 0, due: 0, overdue: 0, learning: 3);
    expect(d.summary(), equals(s));
  });

  test('should add reviews', () {
    var d = DolphinSR(currentDateGetter: today);
    var id = generateId();
    var combination = Combination(front: [0], back: [1, 0]);
    var master =
        Master(id: id, fields: ['Hello', 'world'], combinations: [combination]);

    d.addMasters([master]);

    var nextCard = d.nextCard();
    var expectedCard = DRCard(
        master: id,
        combination: Combination(front: [0], back: [1, 0]),
        front: ['Hello'],
        back: ['world', 'Hello']);
    expect(nextCard, equals(expectedCard));
    expect(d.summary().learning, equals(1));

    var review = Review(
        master: id, combination: combination, ts: today, rating: Rating.Easy);
    d.addReviews([review]);

    expect(d.summary().later, equals(1));
    expect(d.nextCard(), isNull);

    var secondMaster = Master(
        id: generateId(),
        fields: ['Hello', 'world'],
        combinations: [combination]);
    d.addMasters([secondMaster]);
    expect(d.summary().learning, equals(1));
    expect(d.summary().later, equals(1));
    d.addReviews([
      Review(
          master: secondMaster.id,
          combination: secondMaster.combinations![0],
          ts: today,
          rating: Rating.Easy)
    ]);
    expect(d.summary().later, equals(2));
    expect(d.nextCard(), isNull);
  });

  /* test("Will it works ? ", () {
    DolphinSR d = DolphinSR(currentDateGetter: Dates.today);
    String id = generateId();
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
