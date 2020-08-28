library dolphinsr_dart;

import './src/models.dart';
import './src/utils.dart';
export './src/models.dart';

class DolphinSR {
  DolphinSR({this.currentDateGetter}) {
    _state = makeEmptyState();
    _masters = <String, Master>{};
    currentDateGetter ??= DateTime.now();
  }

  DRState _state;
  Map<String, Master> _masters;
  CardsSchedule _cachedCardsSchedule;
  DateTime currentDateGetter;

  void _addMaster(Master master) {
    if (_masters.isNotEmpty) {
      if (_masters.containsKey(master.id)) {
        throw Exception('Already added masters');
      }
    }

    for (final combination in master.combinations) {
      final cardId = CardId(combination: combination, master: master.id);

      _state.cardStates[cardId.uniqueId] =
          makeInitialCardState(id: master.id, combination: combination);
    }

    _masters[master.id] = master;
  }

  bool cardExistInMaster(int id) {
    return _masters.containsKey(id);
  }

  void addMasters(List<Master> masters) {
    for (var i = 0; i < masters.length; i++) {
      final master = masters[i];
      _addMaster(master);
    }
    _cachedCardsSchedule = null;
  }

  void addReviews(List<Review> reviews) {
    for (final review in reviews) {
      _state = applyReview(_state, review);
    }
    _cachedCardsSchedule = null;
  }

  CardsSchedule _getCardsSchedule() {
    if (_cachedCardsSchedule != null) {
      return _cachedCardsSchedule;
    }

    _cachedCardsSchedule = computeCardsSchedule(_state, currentDateGetter);
    return _cachedCardsSchedule;
  }

  CardId _nextCardId() {
    final cardSchedule = _getCardsSchedule();
    return pickMostDue(cardSchedule, _state);
  }

  DRCard _getCard(CardId cardId) {
    final master = _masters[cardId.id];

    final cardState = _state.cardStates[cardId.uniqueId];

    if (master == null) {
      throw Exception('Master is null; cannot get card');
    }

    final frontField =
        cardState.combination.front.map((int i) => master.fields[i]).toList();
    final backFields =
        cardState.combination.back.map((int i) => master.fields[i]).toList();

    final dueDate = calculateDueDate(cardState);
    final card = DRCard(
        master: cardState.master,
        combination: cardState.combination,
        front: frontField,
        back: backFields,
        lastReviewed: cardState.lastReviewed,
        dueDate: dueDate);

    return card;
  }

  List<DRCard> getAllCardState() {
    return _state.cardStates.values.map((cardState) {
      final frontField = cardState.combination.front
          .map((int i) => _masters[cardState.master].fields[i])
          .toList();
      final backFields = cardState.combination.back
          .map((int i) => _masters[cardState.master].fields[i])
          .toList();

      final dueDate = calculateDueDate(cardState);
      final card = DRCard(
          master: cardState.master,
          combination: cardState.combination,
          front: frontField,
          back: backFields,
          lastReviewed: cardState.lastReviewed,
          dueDate: dueDate);

      return card;
    }).toList();
  }

  DRCard nextCard() {
    final nextCardId = _nextCardId();
    if (nextCardId == null) {
      return null;
    }
    return _getCard(nextCardId);
  }

  SummaryStatics summary() {
    final s = _getCardsSchedule();
    final summary = SummaryStatics(
        later: s.later.length,
        due: s.due.length,
        overdue: s.overdue.length,
        learning: s.learning.length);

    return summary;
  }

  int cardReviewedTodayLength() {
    return cardReviewedAtDateLength(DateTime.now());
  }

  int cardReviewedAtDateLength(DateTime date) {
    return _state.cardStates.values
        .where((st) =>
            st.lastReviewed.year == date.year &&
            st.lastReviewed.month == date.month &&
            st.lastReviewed.day == date.day)
        .length;
  }

  int cardsLength() {
    return _state.cardStates.length;
  }
}
