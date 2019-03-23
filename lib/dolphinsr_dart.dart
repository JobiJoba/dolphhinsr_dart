library dolphinsr_dart;

import 'package:dolphinsr_dart/models.dart';
import 'package:dolphinsr_dart/utils.dart';

class DolphinSR {
  State _state;
  Map<int, Master> _masters;
  List<Review> _reviews;

  CardsSchedule _cachedCardsSchedule;

  DateTime _currentDateGetter;

  DolphinSR() {
    _state = State.makeEmptyState();
    _masters = new Map();
    _reviews = [];
    _currentDateGetter = DateTime.now();
  }

  _addMaster(Master master) {
    if (_masters.length > 0) {
      if (_masters.containsKey(master.id)) {
        throw Exception("Already added masters");
      }
    }

    master.combinations.forEach(
        (Combination combination) => foreachMaster(combination, master));

    _masters[master.id] = master;
  }

  foreachMaster(Combination combination, Master master) {
    CardId cardId = CardId.fromIdAndCombi(master.id, combination);

    _state.cardStates[cardId.id] =
        CardState.makeInitialCardState(id: master.id, combination: combination);
  }

  addMasters(List<Master> masters) {
    masters.forEach((master) => _addMaster(master));
    _cachedCardsSchedule = null;
  }

  addReview(List<Review> reviews) {
    _reviews.forEach((review) => foreachAddReview(review));
    _cachedCardsSchedule = null;
  }

  foreachAddReview(Review review) {
    _state = Utils.applyReview(_state, review);
  }

  CardsSchedule _getCardsSchedule() {
    if (_cachedCardsSchedule != null) {
      return _cachedCardsSchedule;
    }

    _cachedCardsSchedule =
        Utils.computeCardsSchedule(_state, _currentDateGetter);
    return _cachedCardsSchedule;
  }

  CardId _nextCardId() {
    CardsSchedule cardSchedule = _getCardsSchedule();
    return Utils.pickMostDue(cardSchedule, _state);
  }

  Card _getCard(CardId cardId) {
    Master master = _masters[cardId.id];
    if (master == null) {
      throw Exception("Master is null; cannot get card");
    }

    List<int> front =
        cardId.frontJoin.split(',').map((elem) => int.parse(elem)).toList();
    List<int> back =
        cardId.backJoin.split(',').map((elem) => int.parse(elem)).toList();

    Combination combination = Combination(front, back);

    List<String> frontField = front.map((i) => master.fields[i]).toList();
    List<String> backFields = back.map((i) => master.fields[i]).toList();

    Card card = Card(master.id, combination, frontField, backFields);

    return card;
  }

  Card nextCard() {
    var nextCardId = this._nextCardId();
    if (nextCardId == null) {
      return null;
    }

    return _getCard(nextCardId);
  }

  SummaryStatics summary() {
    CardsSchedule s = _getCardsSchedule();
    SummaryStatics summary = SummaryStatics(
        s.later.length, s.due.length, s.overdue.length, s.learning.length);

    return summary;
  }
}
