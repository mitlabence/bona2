import 'package:collection/collection.dart';

class TimeSeriesData {
  TimeSeriesData(this.t, this.y, {this.xUnit= "NaN", this.yUnit= "NaN"});

  List<TimeStamp> t;
  List<num> y;
  String xUnit;
  String yUnit;

  int get length => y.length;

  TimeSeriesData.empty({this.xUnit="NaN", this.yUnit="Nan"})
      : t = List<TimeStamp>.empty(),
        y = List<num>.empty();

  TimeSeriesData sort({bool byTime = true, bool ascending = true}) {
    /// Returns a sorted TimeSeriesData. if [byTime] is true, the sorting takes
    /// place by the time stamps, otherwise by the amplitudes. If [ascending] is true,
    /// sort in ascending order, else descending.
    List listToSort = byTime ? t : y;
    List<int> indices = List<int>.generate(t.length, (index) => index);
    List<int> sortedIndices = indices.toList()
      ..sort((a, b) => listToSort[a].compareTo(listToSort[b]));
    if (!ascending) sortedIndices = sortedIndices.reversed.toList();
    List<TimeStamp> tSorted = sortedIndices.map((index) => t[index]).toList();
    List<num> ySorted = sortedIndices.map((index) => y[index]).toList();
    return TimeSeriesData(tSorted, ySorted, xUnit: xUnit, yUnit: yUnit);
  }

  TimeSeriesData resample(TimeStamp startDate, TimeStamp endDate,
      Duration interval, num Function(List<num>) aggregateFunction,
      {num nanValue = 0.0}) {
    /// Given [startDate] and [endDate], resample the entries such that the new time stamps
    /// are [startDate], [startDate]+[interval], ..., [startDate]+n*[interval], where
    /// [startDate]+n*[interval] <= [endDate], but [startDate]+(n+1)*[interval] > [endDate].
    /// The corresponding y are aggregates of bins bounded by the new time stamps as an [exclusive, inclusive) range.
    /// The last bin is [[startDate]+n*[interval], endDate)
    /// Example: 2024.01.01. 12:50 until 2024.01.01. 15:50 with 1 hour steps:
    /// returns 2024.01.01. 12:50, 13:50, 14:50, 15:50, with corresponding y aggregated from
    /// [12:50, 13:50), [13:50, 14:50), [14:50, 15:50), [15:50, 15:50), i.e. last entry is 0. (nanValue).
    /// Note: if [endDate] <= [startDate], an empty TimeSeriesData is returned.
    if (endDate <= startDate) {
      return TimeSeriesData.empty(xUnit: xUnit, yUnit: yUnit);
    }
    if (interval.inHours <= 0) {
      throw Exception(
          "Interval must be positive, non-zero."); // TODO: it is a ValueError. Make it more specific
    }
    List<TimeStamp> tResampled = [];
    TimeStamp currentTimeStamp = startDate;
    while (currentTimeStamp <= endDate) {
      tResampled.add(currentTimeStamp);
      currentTimeStamp = currentTimeStamp.add(interval);
    }
    return _resample(tResampled, endDate, aggregateFunction,
        nanValue: nanValue);
  }

  TimeSeriesData resampleMonths(TimeStamp startDate, TimeStamp endDate,
      num Function(List<num>) aggregateFunction,
      {num nanValue = 0.0}) {
    /// Given [startDate] and [endDate], resample the entries such that the new time stamps
    /// start with the month of [startDate] and end with the month of [endDate], both inclusive.
    /// Example: 2024.01.10 and 2024.03.30: the returned bins will be 2024.01, 2024.02, 2024.03.
    /// The corresponding y values are aggregates of 2024.01.10 to 2024.01.31, 2024.02.1. to 2024.02.29, 2024.03.01. to 2024.03.29., all inclusive.
    /// That is, endDate specifies an exclusive upper limit to data used.
    if (endDate <= startDate) {
      return TimeSeriesData.empty(xUnit: xUnit, yUnit: yUnit);
    }
    List<TimeStamp> tResampled = [];
    TimeStamp currentTimeStamp = TimeStamp(DateTime(startDate.dateTime.year,
        startDate.dateTime.month, 1)); // start with first day of the month
    int dMonth = 0; // the time step
    while (currentTimeStamp <= endDate) {
      tResampled.add(currentTimeStamp);
      dMonth++;
      currentTimeStamp = TimeStamp(DateTime(
          startDate.dateTime.year, startDate.dateTime.month + dMonth, 1));
    }
    return _resample(tResampled, endDate, aggregateFunction,
        nanValue: nanValue); //, endTimeStamp, (p0) => null)
  }

  TimeSeriesData _resample(List<TimeStamp> tResampled, TimeStamp endTimeStamp,
      num Function(List<num>) aggregateFunction,
      {num nanValue = 0.0}) {
    /// Given resampled time stamps [tResampled], return the aggregate of y for each bin
    /// defined by two successive elements of [tResampled] in [inclusive, exclusive) range.
    /// The last bin is either the last two elements of [tResampled] (if [endTimeStamp] == [endTimeStamp]),
    /// or the last element of [tResampled] to [endTimeStamp].
    List<num> yResampled = [];

    // First, define the beginning and end indices of each interval.
    List<int> iBeginList = [];
    // For each currentTimeStamp, find the beginning of corresponding interval:
    // the index of the first time stamp >= currentTimeStamp
    // For each interval but the last, the end frame will then be the next beginning frame - 1
    int iBegin = 0;
    for (TimeStamp currentTimeStamp in tResampled) {
      while (iBegin < t.length && t[iBegin] < currentTimeStamp) {
        iBegin++;
      }
      iBeginList.add(iBegin);
    }
    // All intervals except the last must end one index before the the next
    for (int i = 0; i < iBeginList.length - 1; i++) {
      List<num> subList = y.sublist(iBeginList[i], iBeginList[i + 1]);
      // calcualte aggregate value or use NaN value if empty interval
      yResampled
          .add(subList.isNotEmpty ? aggregateFunction(subList) : nanValue);
    }
    // For last interval, need to find end index
    int iEnd = iBeginList[iBeginList.length - 1];
    while (iEnd < t.length && t[iEnd] < endTimeStamp) {
      iEnd++;
    }
    List<num> subList = y.sublist(iBeginList[iBeginList.length - 1], iEnd);
    yResampled.add(subList.isNotEmpty ? aggregateFunction(subList) : nanValue);
    return TimeSeriesData(tResampled, yResampled, xUnit: xUnit, yUnit: yUnit);
  }

  bool get isEmpty =>
      t.isEmpty; // TODO: need to make sure t and y have same length!
  bool get isNotEmpty => t.isNotEmpty;

  bool isEqualTo(TimeSeriesData other) {
    /// Do a shallow equality check
    return const ListEquality().equals(y, other.y) && const ListEquality().equals(t, other.t) && xUnit == other.xUnit && yUnit == other.yUnit;
  }
  bool isDeepEqualTo(TimeSeriesData other) {
    /// Do a deep equality check
    //TODO: write tests!
    return const DeepCollectionEquality().equals(y, other.y) && const DeepCollectionEquality().equals(t, other.t) && xUnit == other.xUnit && yUnit == other.yUnit;
  }
}

// I want a plot that shows my spendings for each month.
// Given a time data and a corresponding numeric data,
// return a resample at an interval of 1 month, starting at a specific datetime

class TimeStamp {
  DateTime dateTime;

  TimeStamp(this.dateTime);

  TimeStamp.now() : dateTime = DateTime.now();

  Duration difference(TimeStamp t) {
    return t.dateTime.difference(dateTime);
  }

  bool operator <(TimeStamp other) {
    return dateTime.isBefore(other.dateTime);
  }

  bool operator >(TimeStamp other) {
    return other.dateTime.isBefore(dateTime);
  }

  bool operator <=(TimeStamp other) {
    return (dateTime.isBefore(other.dateTime) ||
        dateTime.isAtSameMomentAs(other.dateTime));
  }

  TimeStamp add(Duration d) {
    /// Add a duration [d] to the TimeStamp.
    return TimeStamp(dateTime.add(d));
  }

  TimeStamp operator +(TimeStamp other) {
    /// Adding two timestamps returns the later one.
    return dateTime.millisecondsSinceEpoch >
            other.dateTime.millisecondsSinceEpoch
        ? this
        : other;
  }

  int compareTo(TimeStamp other) {
    /// Compares [this] to [other]. Returns a negative number if [this] is less than [other],
    /// zero if they are equal, and a positive number if [this] is greater than [other].
    num thisTime = dateTime.millisecondsSinceEpoch;
    num otherTime = other.dateTime.millisecondsSinceEpoch;
    return thisTime.compareTo(otherTime);
  }

  bool isEqualTo(TimeStamp other) {
    return dateTime.isAtSameMomentAs(other.dateTime);
  }

  @override
  int get hashCode {
    return dateTime.hashCode;
  }

  @override
  bool operator ==(Object other) {
    /// Compare the type, and if same type, compare dateTime field.
    if (other is TimeStamp) {
      return dateTime == other.dateTime;
    } else {
      return false;
    }
  }
}
