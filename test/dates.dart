class Dates {
  static DateTime addToDate(DateTime date, int days) {
    date.add(Duration(days: days));
    return date;
  }

  static final today = DateTime(1970, 1, 1);

  static final todayAt3AM = DateTime(1970, 1, 1, 3);

  static final laterToday = DateTime(1970, 1, 1, 10);

  static final laterTmrw = DateTime(1970, 1, 2, 0);

  static final laterInTwoDays = DateTime(1970, 1, 3, 10);

  static final laterInFourDays = DateTime(1970, 1, 5, 10);
}
