import 'dart:convert';
import 'package:bona2/utils/time_series_tools.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show rootBundle;

Future main() async {
  setUpAll(() async {});

  group("Group test TimeStamp class", () {
    test("Test initialization", () {
      DateTime dt = DateTime(2000, 1, 1, 14, 15, 0);
      TimeStamp ts = TimeStamp(dt);
      expect(() => ts, returnsNormally);
      expect(ts.dateTime, equals(dt));
    });
    test("Test add Duration", () {
      DateTime dt = DateTime(2000, 1, 1, 14, 10, 0);
      Duration d = const Duration(hours: 1);
      TimeStamp ts = TimeStamp(dt);
      expect(() => ts.add(d), returnsNormally);
      TimeStamp ts2 = ts.add(d);
      expect(ts.dateTime, equals(dt)); // original timestamp did not change
      expect(ts2.dateTime, equals(DateTime(2000, 1, 1, 15, 10, 0)));
    });
    test("Test equality", () {
      TimeStamp ts1 = TimeStamp(DateTime(2000, 1, 1));
      TimeStamp ts2 = TimeStamp(DateTime(2000, 1, 1));
      expect(ts1, equals(ts2));
    });
    test("Test equality #2", () {
      TimeStamp ts1 = TimeStamp(DateTime(2000, 1, 2));
      TimeStamp ts2 = TimeStamp(DateTime(2000, 1, 1));
      Duration d = const Duration(days: 1);
      ts2 = ts2.add(d);
      expect(ts1, equals(ts2));
    });
  });

  group("Group test TimeSeriesData", () {
    late List<TimeStamp> t;
    late List<num> y;
    setUp(() {
      t = [
        TimeStamp(DateTime(2000, 5, 15)),
        TimeStamp(DateTime(2002, 1, 20)),
        TimeStamp(DateTime(2004, 12, 3))
      ];
      y = [0.7, 0.2, 0.5];
    });
    test("Test initialization runs", () {
      expect(() => TimeSeriesData(t, y), returnsNormally);
    });
    test("Test initialization assigns fields", () {
      TimeSeriesData ts = TimeSeriesData(t, y);
      expect(ts.t, equals(t));
      expect(ts.y, equals(y));
    });
    test("Test sorting, ascending by time", () {
      // Explicitly define the data, independently of setUp() which might change in the future
      t = [
        TimeStamp(DateTime(2002, 5, 15)),
        TimeStamp(DateTime(2000, 1, 20)),
        TimeStamp(DateTime(2004, 12, 3))
      ];
      y = [0.7, 0.2, 0.5];
      List<TimeStamp> tSorted = [
        TimeStamp(DateTime(2000, 1, 20)),
        TimeStamp(DateTime(2004, 12, 3)),
        TimeStamp(DateTime(2002, 5, 15)),
      ];
      List<num> ySorted = [0.2, 0.5, 0.7];
      TimeSeriesData ts = TimeSeriesData(t, y);
      TimeSeriesData tsSorted = ts.sort(byTime: false, ascending: true);
      expect(tsSorted.t, equals(tSorted));
      expect(tsSorted.y, equals(ySorted));
    });
    test("Test sorting, ascending, by amplitude", () {
      // Explicitly define the data, independently of setUp() which might change in the future
      t = [
        TimeStamp(DateTime(2002, 5, 15)),
        TimeStamp(DateTime(2000, 1, 20)),
        TimeStamp(DateTime(2004, 12, 3))
      ];
      y = [0.7, 0.2, 0.5];
      List<TimeStamp> tSorted = [
        TimeStamp(DateTime(2000, 1, 20)),
        TimeStamp(DateTime(2002, 5, 15)),
        TimeStamp(DateTime(2004, 12, 3))
      ];
      List<num> ySorted = [0.2, 0.7, 0.5];
      TimeSeriesData ts = TimeSeriesData(t, y);
      TimeSeriesData tsSorted = ts.sort(byTime: true, ascending: true);
      expect(tsSorted.t, equals(tSorted));
      expect(tsSorted.y, equals(ySorted));
    });
    test("Test resample() when startDate excludes first element of original",
        () {
      List<TimeStamp> ts = [
        TimeStamp(DateTime(2000, 1, 1)),
        TimeStamp(DateTime(2001, 4, 2)),
        TimeStamp(DateTime(2001, 12, 2)),
        TimeStamp(DateTime(2002, 1, 5)),
        TimeStamp(DateTime(2002, 2, 5)),
        TimeStamp(DateTime(2002, 9, 20)),
        TimeStamp(DateTime(2003, 1, 1)),
        TimeStamp(DateTime(2003, 1, 25)),
        TimeStamp(DateTime(2003, 2, 2)),
        TimeStamp(DateTime(2003, 2, 2)),
      ];
      List<num> ys = [
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
      ];
      TimeSeriesData tsd = TimeSeriesData(ts, ys);
      TimeSeriesData resampled = tsd.resample(
          TimeStamp(DateTime(2001, 1, 1)),
          TimeStamp(DateTime(2003, 2, 3)),
          const Duration(days: 365),
          (l) => l.reduce((value, element) => value + element));
      List<TimeStamp> expectedList = [
        TimeStamp(DateTime(2001, 1, 1)),
        TimeStamp(DateTime(2002, 1, 1)),
        TimeStamp(DateTime(2003, 1, 1)),
      ];
      expect(resampled.t.length, equals(resampled.y.length));
      expect(resampled.t, equals(expectedList));
      expect(resampled.y, equals([2.0, 3.0, 4.0]));
    });
    test("Test resample() with no values in any windows", () {
      List<TimeStamp> ts = [
        TimeStamp(DateTime(2000, 1, 1, 23, 59, 59)),
        TimeStamp(DateTime(2000, 1, 2)),
        TimeStamp(DateTime(2000, 1, 2, 0, 1)),
        TimeStamp(DateTime(2000, 1, 2, 15, 20)),
        TimeStamp(DateTime(2000, 1, 3, 16, 20)),
        TimeStamp(DateTime(2000, 1, 3, 17, 20)),
        TimeStamp(DateTime(2000, 1, 4, 8, 10)),
        TimeStamp(DateTime(2000, 1, 4, 12, 19, 59)),
        TimeStamp(DateTime(2000, 1, 4, 12, 20)),
        TimeStamp(DateTime(2000, 1, 4, 12, 21)),
      ];
      List<num> ys = [
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
      ];
      TimeSeriesData tsd = TimeSeriesData(ts, ys);
      TimeSeriesData resampled = tsd.resample(
          TimeStamp(DateTime(2000, 1, 2)),
          TimeStamp(DateTime(2000, 1, 4, 12, 20, 1)),
          const Duration(days: 1), // 2 days + half day = 3 time windows
          (l) => l.reduce((value, element) => value + element),
          nanValue: 0.0);
      expect(resampled.t.length, equals(3));
      expect(resampled.y, equals([3.0, 2.0, 3.0]));
    });
    test("Test open intervals", () {
      List<TimeStamp> ts = [
        // just outside first interval
        TimeStamp(DateTime(2000, 1, 1, 23, 59, 59)),

        // just inside first interval
        TimeStamp(DateTime(2000, 1, 2)),

        // should be just excluded
        TimeStamp(DateTime(2000, 1, 3, 12, 20)),
      ];
      List<num> ys = [1.0, 1.0, 1.0];
      TimeSeriesData tsd = TimeSeriesData(ts, ys);
      TimeSeriesData resampled = tsd.resample(
          TimeStamp(DateTime(2000, 1, 2)),
          TimeStamp(DateTime(2000, 1, 3, 12, 20)),
          const Duration(days: 1), // 1 day + half day = 2 time windows
          (l) => l.reduce((value, element) => value + element),
          nanValue: 0.0);
      expect(resampled.t.length, equals(2));
      expect(resampled.y, equals([1.0, 0.0]));
    });
    test("Test all values within range", () {
      List<TimeStamp> ts = [
        TimeStamp(DateTime(2000, 1, 1, 20)),
        TimeStamp(DateTime(2000, 1, 2)),
        TimeStamp(DateTime(2000, 1, 2, 0, 1)),
        TimeStamp(DateTime(2000, 1, 2, 15, 20)),
        TimeStamp(DateTime(2000, 1, 3, 16, 20)),
        TimeStamp(DateTime(2000, 1, 3, 17, 20)),
        TimeStamp(DateTime(2000, 1, 4, 8, 10)),
        TimeStamp(DateTime(2000, 1, 4, 12, 19, 59)),
        TimeStamp(DateTime(2000, 1, 4, 12, 20)),
        TimeStamp(DateTime(2000, 1, 4, 12, 21)),
      ];
      List<num> ys = [
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
      ];
      TimeSeriesData tsd = TimeSeriesData(ts, ys);
      TimeSeriesData resampled = tsd.resample(
          TimeStamp(DateTime(2000, 1, 1, 15)),
          TimeStamp(DateTime(2000, 1, 4, 14)),
          const Duration(days: 1), // 2 days + 23h = 3 time windows
              (l) => l.reduce((value, element) => value + element),
          nanValue: 0.0);
      expect(resampled.t.length, equals(3));
      expect(resampled.y, equals([3.0, 1.0, 6.0]));

    });
    test("Test resample with range smaller than interval", () {
      TimeSeriesData tds = TimeSeriesData(t, y);
      TimeSeriesData resampled = tds.resample(TimeStamp(DateTime(2003, 1, 1, 12, 50)), TimeStamp(DateTime(2003, 1, 1, 12, 55)), const Duration(hours: 1), (l) => l.reduce((value, element) => value + element), );
      expect(resampled.t.length, equals(1)); // only 1 incomplete
      expect(resampled.y, equals([0.0])); // only 1 incomplete
    });
  });
}
