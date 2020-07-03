library dolphinsr_dart;

import 'package:dolphinsr_dart/src/models.dart';
import 'package:dolphinsr_dart/src/utils.dart';

export 'package:dolphinsr_dart/src/models.dart';

class DolphinSR {
  DRState _state;
  Map<int, Master> _masters;

  CardsSchedule _cachedCardsSchedule;

  DateTime currentDateGetter;

  DolphinSR({this.currentDateGetter}) {
    _state = DRState.makeEmptyState();
    _masters = new Map();

    if (currentDateGetter == null) {
      currentDateGetter = DateTime.now();
    }
  }

  _addMaster(Master master) {
    if (_masters.isNotEmpty) {
      if (_masters.containsKey(master.id)) {
        throw Exception("Already added masters");
      }
    }
    master.combinations.forEach(
        (Combination combination) => foreachMaster(combination, master));

    _masters[master.id] = master;
  }

  foreachMaster(Combination combination, Master master) {
    CardId cardId = CardId(master: master.id, combination: combination);

    _state.cardStates[cardId.uniqueId] =
        CardState.makeInitialCardState(id: master.id, combination: combination);
  }

  bool cardExistInMaster(int id) {
    return _masters.containsKey(id);
  }

  addMasters(List<Master> masters) {
    masters.forEach((master) => _addMaster(master));
    _cachedCardsSchedule = null;
  }

  addReviews(List<Review> reviews) {
    reviews.forEach((review) => foreachAddReview(review));
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
        Utils.computeCardsSchedule(_state, currentDateGetter);
    return _cachedCardsSchedule;
  }

  CardId _nextCardId() {
    CardsSchedule cardSchedule = _getCardsSchedule();
    return Utils.pickMostDue(cardSchedule, _state);
  }

  DRCard _getCard(CardId cardId) {
    Master master = _masters[cardId.id];
    if (master == null) {
      throw Exception("Master is null; cannot get card");
    }

    List<int> front =
        cardId.frontJoin.split(',').map((elem) => int.parse(elem)).toList();
    List<int> back =
        cardId.backJoin.split(',').map((elem) => int.parse(elem)).toList();

    Combination combination = Combination(front: front, back: back);

    List<String> frontField = front.map((i) => master.fields[i]).toList();
    List<String> backFields = back.map((i) => master.fields[i]).toList();

    DRCard card = DRCard(
        master: master.id,
        combination: combination,
        front: frontField,
        back: backFields);

    return card;
  }

  DRCard nextCard() {
    var nextCardId = this._nextCardId();
    if (nextCardId == null) {
      return null;
    }

    return _getCard(nextCardId);
  }

  SummaryStatics summary() {
    CardsSchedule s = _getCardsSchedule();
    SummaryStatics summary = SummaryStatics(
        later: s.later.length,
        due: s.due.length,
        overdue: s.overdue.length,
        learning: s.learning.length);

    return summary;
  }
}
