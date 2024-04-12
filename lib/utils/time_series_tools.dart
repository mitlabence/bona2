class TimeSeriesData {
  TimeSeriesData(this.t, this.y);

  List<TimeStamp> t;
  List<num> y;

  TimeSeriesData.empty()
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
    return TimeSeriesData(tSorted, ySorted);
  }

  TimeSeriesData resample(TimeStamp startDate, TimeStamp endDate,
      Duration interval, num Function(List<num>) aggregateFunction,
      {num nanValue = 0.0}) {
    /// Given [startDate] and [endDate], resample the entries such that the new time stamps
    /// are [startDate], [startDate]+[interval], ..., [startDate]+n*[interval], where
    /// [startDate]+n*[interval] <= [endDate], but [startDate]+(n+1)*[interval] > [endDate].
    /// Note: if [endDate] < [startDate], an empty TimeSeriesData is returned.
    /// If [startDate] = [endDate], a TimeSeriesData containing a single entry is returned.
    if (endDate < startDate) {
      return TimeSeriesData.empty();
    }
    if (interval.inHours <= 0) {
      throw Exception(
          "Interval must be positive, non-zero."); // TODO: it is a ValueError. Make it more specific
    }
    int n_bins = endDate.difference(startDate).inHours ~/ interval.inHours;
    List<TimeStamp> tResampled = [];
    TimeStamp currentTimeStamp = startDate;
    while (currentTimeStamp <= endDate) {
      tResampled.add(currentTimeStamp);
      currentTimeStamp = currentTimeStamp.add(interval);
    }
    //assert(tResampled.length == n_bins);
    // apply aggregate function to each subset of amplitudes
    List<num> yResampled = [];

    // First, define the beginning and end indices of each interval.
    List<int> iBeginList = [];
    // For each currentTimeStamp, find the beginning of corresponding interval:
    // the index of the first time stamp >= currentTimeStamp
    // For each interval but the last, the end frame will then be the next beginning frame - 1
    int iBegin = 0;
    for (currentTimeStamp in tResampled) {
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
    while (iEnd < t.length && t[iEnd] < endDate) {
      iEnd++;
    }
    List<num> subList = y.sublist(iBeginList[iBeginList.length - 1], iEnd);
    yResampled.add(subList.isNotEmpty ? aggregateFunction(subList) : nanValue);
    return TimeSeriesData(tResampled, yResampled);
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
