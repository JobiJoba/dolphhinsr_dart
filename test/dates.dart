DateTime addToDate(DateTime date, int days) {
  date.add(Duration(days: days));
  return date;
}

final DateTime today = DateTime(1970, 1, 1);

final DateTime todayAt3AM = DateTime(1970, 1, 1, 3);

final DateTime laterToday = DateTime(1970, 1, 1, 10);

final DateTime laterTmrw = DateTime(1970, 1, 2, 0);

final DateTime laterInTwoDays = DateTime(1970, 1, 3, 10);

final DateTime laterInFourDays = DateTime(1970, 1, 5, 10);
