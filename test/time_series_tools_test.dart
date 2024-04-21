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
    test("Test invalid datetime rollover", () {
      TimeStamp ts =
          TimeStamp(DateTime(2000, 6, 31)); // Should roll over to 07.01.
      TimeStamp tsCorrect = TimeStamp(DateTime(2000, 7, 1));
      expect(ts, equals(tsCorrect));
    });
  });

  group("Group test TimeSeriesData", () {
    late List<TimeStamp> t;
    late List<num> y;
    late String xUnit;
    late String yUnit;
    setUp(() {
      t = [
        TimeStamp(DateTime(2000, 5, 15)),
        TimeStamp(DateTime(2002, 1, 20)),
        TimeStamp(DateTime(2004, 12, 3))
      ];
      y = [0.7, 0.2, 0.5];
      xUnit = "xUnit";
      yUnit = "yUnit";
    });
    test("Test initialization runs", () {
      expect(() => TimeSeriesData(t, y, xUnit: xUnit, yUnit: yUnit),
          returnsNormally);
    });
    test("Test initialization assigns fields", () {
      TimeSeriesData ts = TimeSeriesData(t, y, xUnit: xUnit, yUnit: yUnit);
      expect(ts.t, equals(t));
      expect(ts.y, equals(y));
      expect(ts.xUnit, equals(xUnit));
      expect(ts.yUnit, equals(yUnit));
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
      TimeSeriesData ts = TimeSeriesData(t, y, xUnit: xUnit, yUnit: yUnit);
      TimeSeriesData tsSorted = ts.sort(byTime: true, ascending: true);
      expect(tsSorted.t, equals(tSorted));
      expect(tsSorted.y, equals(ySorted));
      expect(tsSorted.xUnit, equals(xUnit));
      expect(tsSorted.yUnit, equals(yUnit));
    });
    test("Test isEqualTo with empty self", () {
      TimeSeriesData tsd1 = TimeSeriesData.empty();
      expect(tsd1.isEqualTo(tsd1), true);
    });
    test("Test isEqualTo with non-empty self", () {
      TimeSeriesData tsd1 = TimeSeriesData(
        [
          TimeStamp(DateTime(2001, 1)),
          TimeStamp(DateTime(2001, 5, 3)),
          TimeStamp(DateTime(2001, 3, 1, 12, 50, 23, 123))
        ],
        [0.1, 0.3, 0.2],
      );
      expect(tsd1.isEqualTo(tsd1), true);
    });
    test("Test isEqualTo with equal objects with sorted time stamps", () {
      TimeSeriesData tsd1 = TimeSeriesData(
        [
          TimeStamp(DateTime(2001, 1, 1)),
          TimeStamp(DateTime(2001, 5)),
          TimeStamp(DateTime(2002, 12, 3, 12, 59, 59, 100))
        ],
        [0.1, 0.2, 0.3],
      );
      TimeSeriesData tsd2 = TimeSeriesData(
        [
          TimeStamp(DateTime(2001, 1, 1)),
          TimeStamp(DateTime(2001, 5)),
          TimeStamp(DateTime(2002, 12, 3, 12, 59, 59, 100))
        ],
        [0.1, 0.2, 0.3],
      );
      expect(tsd1.isEqualTo(tsd2), true);
      expect(tsd2.isEqualTo(tsd1), true);
    });

    test("Test isEqualTo with equal objects with unsorted time stamps", () {
      TimeSeriesData tsd1 = TimeSeriesData(
        [
          TimeStamp(DateTime(2001, 1, 1)),
          TimeStamp(DateTime(2002, 12, 3, 12, 59, 59, 100)),
          TimeStamp(DateTime(2001, 5, 2))
        ],
        [0.1, 0.3, 0.2],
      );
      TimeSeriesData tsd2 = TimeSeriesData(
        [
          TimeStamp(DateTime(2001, 1, 1)),
          TimeStamp(DateTime(2002, 12, 3, 12, 59, 59, 100)),
          TimeStamp(DateTime(2001, 5, 2))
        ],
        [0.1, 0.3, 0.2],
      );
      expect(tsd1.isEqualTo(tsd2), true);
      expect(tsd2.isEqualTo(tsd1), true);
    });
    test("Test isEqualTo for TimeSeriesData with differing y", () {
      TimeSeriesData tsd1 = TimeSeriesData(
        [
          TimeStamp(DateTime(2001, 1)),
          TimeStamp(DateTime(2003, 5, 1, 12, 34, 14, 443)),
          TimeStamp(DateTime(2002, 12, 25))
        ],
        [0.1, 0.25, 0.31],
      );
      TimeSeriesData tsd2 = TimeSeriesData(
        [
          TimeStamp(DateTime(2001, 1)),
          TimeStamp(DateTime(2003, 5, 1, 12, 34, 14, 443)),
          TimeStamp(DateTime(2002, 12, 25))
        ],
        [0.1, 0.25, 0.3],
      );
    });
    test("Test isEqualTo for TimeSeriesData with differing y and same t", () {
      TimeSeriesData tsd1 = TimeSeriesData(
        [
          TimeStamp(DateTime(2001, 1)),
          TimeStamp(DateTime(2003, 5, 1, 12, 34, 14, 443)),
          TimeStamp(DateTime(2002, 12, 25))
        ],
        [0.1, 0.25, 0.31],
      );
      TimeSeriesData tsd2 = TimeSeriesData(
        [
          TimeStamp(DateTime(2001, 1)),
          TimeStamp(DateTime(2003, 5, 1, 12, 34, 14, 443)),
          TimeStamp(DateTime(2002, 12, 25))
        ],
        [0.1, 0.25, 0.3],
      );
    });
    test("Test isEqualTo for TimeSeriesData with differing t and same y", () {
      TimeSeriesData tsd1 = TimeSeriesData(
        [
          TimeStamp(DateTime(2001, 1)),
          TimeStamp(DateTime(2003, 5, 1, 12, 34, 14, 443)),
          TimeStamp(DateTime(2002, 12, 25))
        ],
        [0.1, 0.25, 0.31],
      );
      TimeSeriesData tsd2 = TimeSeriesData(
        [
          TimeStamp(DateTime(2001, 1)),
          TimeStamp(DateTime(2003, 5, 1, 12, 34, 14, 413)),
          TimeStamp(DateTime(2002, 12, 25))
        ],
        [0.1, 0.25, 0.31],
      );
      expect(tsd1.isEqualTo(tsd2), false);
      expect(tsd2.isEqualTo(tsd1), false);
      expect(tsd1.isEqualTo(tsd1), true);
      expect(tsd2.isEqualTo(tsd2), true);
    });
    test("Test isEqualTo for TimeSeriesData with differing t and differing y",
        () {
      TimeSeriesData tsd1 = TimeSeriesData(
        [
          TimeStamp(DateTime(2001, 1)),
          TimeStamp(DateTime(2003, 5, 1, 12, 34, 13, 443)),
          TimeStamp(DateTime(2002, 12, 25))
        ],
        [0.1, 0.25, 0.31],
      );
      TimeSeriesData tsd2 = TimeSeriesData(
        [
          TimeStamp(DateTime(2001, 1)),
          TimeStamp(DateTime(2003, 5, 1, 12, 34, 14, 443)),
          TimeStamp(DateTime(2002, 12, 25))
        ],
        [0.1, 0.254, 0.31],
      );
      expect(tsd1.isEqualTo(tsd2), false);
      expect(tsd2.isEqualTo(tsd1), false);
      expect(tsd1.isEqualTo(tsd1), true);
      expect(tsd2.isEqualTo(tsd2), true);
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
      TimeSeriesData tsd = TimeSeriesData(ts, ys, xUnit: xUnit, yUnit: yUnit);
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
      expect(resampled.xUnit, equals(xUnit));
      expect(resampled.yUnit, equals(yUnit));
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
      TimeSeriesData tsd = TimeSeriesData(ts, ys, xUnit: xUnit, yUnit: yUnit);
      TimeSeriesData resampled = tsd.resample(
          TimeStamp(DateTime(2000, 1, 2)),
          TimeStamp(DateTime(2000, 1, 4, 12, 20, 1)),
          const Duration(days: 1), // 2 days + half day = 3 time windows
          (l) => l.reduce((value, element) => value + element),
          nanValue: 0.0);
      expect(resampled.t.length, equals(3));
      expect(resampled.y, equals([3.0, 2.0, 3.0]));
      expect(resampled.xUnit, equals(xUnit));
      expect(resampled.yUnit, equals(yUnit));
    });
    test("Test resample with beginDate > endDate", () {
      TimeSeriesData tsd = TimeSeriesData(t, y, xUnit: xUnit, yUnit: yUnit);
      TimeSeriesData resampled = tsd.resample(
          TimeStamp(DateTime(2000, 1, 3)),
          TimeStamp(DateTime(2000, 1, 1)), // endDate earlier than beginDate
          const Duration(days: 1), // 2 days + half day = 3 time windows
          (l) => l.reduce((value, element) => value + element),
          nanValue: 0.0);
      expect(tsd.xUnit, equals(xUnit));
      expect(tsd.yUnit, equals(yUnit));
      expect(resampled.isEmpty, true);
      expect(resampled.xUnit, equals(xUnit));
      expect(resampled.yUnit, equals(yUnit));
    });
    test("Test resample with beginDate = endDate and duration=1 day", () {
      TimeSeriesData tsd = TimeSeriesData(t, y, xUnit: xUnit, yUnit: yUnit);
      TimeSeriesData resampled = tsd.resample(
          TimeStamp(DateTime(2000, 1, 1)),
          TimeStamp(DateTime(
            2000,
            1,
            1,
          )), // endDate earlier than beginDate
          const Duration(days: 1), // 2 days + half day = 3 time windows
          (l) => l.reduce((value, element) => value + element),
          nanValue: 0.0);
      expect(resampled.isEmpty, true);
      expect(resampled.xUnit, equals(xUnit));
      expect(resampled.yUnit, equals(yUnit));
    });
    test("Test resample with beginDate = endDate and duration=1 minute", () {
      TimeSeriesData tsd = TimeSeriesData(t, y, xUnit: xUnit, yUnit: yUnit);
      TimeSeriesData resampled = tsd.resample(
          TimeStamp(DateTime(2000, 1, 1)),
          TimeStamp(DateTime(
            2000,
            1,
            1,
          )), // endDate earlier than beginDate
          const Duration(minutes: 1), // 2 days + half day = 3 time windows
          (l) => l.reduce((value, element) => value + element),
          nanValue: 0.0);
      expect(resampled.isEmpty, true);
      expect(resampled.xUnit, equals(xUnit));
      expect(resampled.yUnit, equals(yUnit));
    });
    test("Test resample with beginDate = endDate and duration=1 second", () {
      TimeSeriesData tsd = TimeSeriesData(t, y, xUnit: xUnit, yUnit: yUnit);
      TimeSeriesData resampled = tsd.resample(
          TimeStamp(DateTime(2000, 1, 1)),
          TimeStamp(DateTime(
            2000,
            1,
            1,
          )), // endDate earlier than beginDate
          const Duration(seconds: 1), // 2 days + half day = 3 time windows
          (l) => l.reduce((value, element) => value + element),
          nanValue: 0.0);
      expect(resampled.isEmpty, true);
      expect(resampled.xUnit, equals(xUnit));
      expect(resampled.yUnit, equals(yUnit));
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
      TimeSeriesData tsd = TimeSeriesData(ts, ys, xUnit: xUnit, yUnit: yUnit);
      TimeSeriesData resampled = tsd.resample(
          TimeStamp(DateTime(2000, 1, 2)),
          TimeStamp(DateTime(2000, 1, 3, 12, 20)),
          const Duration(days: 1), // 1 day + half day = 2 time windows
          (l) => l.reduce((value, element) => value + element),
          nanValue: 0.0);
      expect(resampled.t.length, equals(2));
      expect(resampled.y, equals([1.0, 0.0]));
      expect(resampled.xUnit, equals(xUnit));
      expect(resampled.yUnit, equals(yUnit));
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
      TimeSeriesData tsd = TimeSeriesData(ts, ys, xUnit: xUnit, yUnit: yUnit);
      TimeSeriesData resampled = tsd.resample(
          TimeStamp(DateTime(2000, 1, 1, 15)),
          TimeStamp(DateTime(2000, 1, 4, 14)),
          const Duration(days: 1), // 2 days + 23h = 3 time windows
          (l) => l.reduce((value, element) => value + element),
          nanValue: 0.0);
      expect(resampled.t.length, equals(3));
      expect(resampled.y, equals([3.0, 1.0, 6.0]));
      expect(resampled.xUnit, equals(xUnit));
      expect(resampled.yUnit, equals(yUnit));
    });
    test("Test resample with range smaller than interval", () {
      TimeSeriesData tds = TimeSeriesData(t, y, xUnit: xUnit, yUnit: yUnit);
      TimeSeriesData resampled = tds.resample(
        TimeStamp(DateTime(2003, 1, 1, 12, 50)),
        TimeStamp(DateTime(2003, 1, 1, 12, 55)),
        const Duration(hours: 1),
        (l) => l.reduce((value, element) => value + element),
      );
      expect(resampled.t.length, equals(1)); // only 1 incomplete
      expect(resampled.y, equals([0.0])); // only 1 incomplete
      expect(resampled.xUnit, equals(xUnit));
      expect(resampled.yUnit, equals(yUnit));
    });
    test("Test resample with last TimeStamp coinciding with endDate", () {
      List<TimeStamp> ts = [
        TimeStamp(DateTime(2024, 1, 1, 11, 50)), // outside range
        TimeStamp(DateTime(2024, 1, 1, 12, 50)), // just inside first bin
        TimeStamp(DateTime(2024, 1, 1, 12, 55)), // inside first bin
        TimeStamp(DateTime(2024, 1, 1, 13, 49, 59)), // just inside first bin
        TimeStamp(DateTime(2024, 1, 1, 13, 50, 0, 0)), // just inside second bin
        TimeStamp(DateTime(2024, 1, 1, 15, 51)), // inside fourth bin
        TimeStamp(DateTime(2024, 1, 1, 15, 52)), // inside fourth bin
        TimeStamp(DateTime(2024, 1, 1, 16, 53)), // outside range
        TimeStamp(DateTime(2024, 1, 1, 17, 50)), // outside range
      ];
      List<num> ys = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0];
      TimeSeriesData tds = TimeSeriesData(ts, ys, xUnit: xUnit, yUnit: yUnit);
      TimeSeriesData tdsResampled = tds.resample(
          TimeStamp(DateTime(2024, 1, 1, 12, 50)),
          TimeStamp(DateTime(2024, 1, 1, 16, 50)),
          // Should give 5 timestamps: 12:50 to 16:50 inclusive, every hour
          const Duration(hours: 1),
          (l) => l.reduce((value, element) => value + element));
      TimeSeriesData expected = TimeSeriesData([
        TimeStamp(DateTime(2024, 1, 1, 12, 50)),
        TimeStamp(DateTime(2024, 1, 1, 13, 50)),
        TimeStamp(DateTime(2024, 1, 1, 14, 50)),
        TimeStamp(DateTime(2024, 1, 1, 15, 50)),
        TimeStamp(DateTime(2024, 1, 1, 16, 50)),
      ], [
        3.0,
        1.0,
        0.0,
        2.0,
        0.0
      ], xUnit: xUnit, yUnit: yUnit);
      expect(tdsResampled.isEqualTo(expected), true);
    });
  });
  group("Group test resampleMonths()", () {
    late List<TimeStamp> t;
    late List<num> y;
    late String xUnit;
    late String yUnit;
    setUp(() {
      t = [
        TimeStamp(DateTime(2000, 5, 15)),
        TimeStamp(DateTime(2000, 5, 22)),
        TimeStamp(DateTime(2000, 6, 30)),
        // add an invalid timestamp, should be rolled over to 2000.07.01. by DateTime
        TimeStamp(DateTime(2000, 6, 31)),
        TimeStamp(DateTime(2001, 1, 3)),
      ];
      y = [1.0, 1.0, 1.0, 1.0, 1.0];
      xUnit = "xUnit";
      yUnit = "yUnit";
    });
    test("Test resampleMonths with beginDate > endDate", () {
      TimeSeriesData tds = TimeSeriesData(t, y, xUnit: xUnit, yUnit: yUnit);
      TimeSeriesData resampled = tds.resampleMonths(
        TimeStamp(DateTime(2000, 8, 29)),
        TimeStamp(DateTime(2000, 1, 1)), // earlier than beginDate
        (l) => l.reduce((value, element) => value + element),
      );
      expect(resampled.isEmpty, true);
    });
    test("Test resampleMonth with beginDate = endDate", () {
      TimeSeriesData tds = TimeSeriesData(t, y, xUnit: xUnit, yUnit: yUnit);
      TimeSeriesData resampled = tds.resampleMonths(
        TimeStamp(DateTime(2000, 5, 22)),
        // there is an entry with this date in tds
        TimeStamp(DateTime(2000, 5, 22)),
        (l) => l.reduce((value, element) => value + element),
      );
      expect(resampled.isEmpty, true);
      expect(resampled.xUnit, equals(xUnit));
      expect(resampled.yUnit, equals(yUnit));
    });
    test("Test resampleMonth with all data in range", () {
      TimeSeriesData tds = TimeSeriesData(t, y, xUnit: xUnit, yUnit: yUnit);
      TimeSeriesData resampled = tds.resampleMonths(
        TimeStamp(DateTime(2000, 5, 1)),
        // there is an entry with this date in tds
        TimeStamp(DateTime(2001, 1, 31)),
        (l) => l.reduce((value, element) => value + element),
      );
      TimeSeriesData tdsExpected = TimeSeriesData([
        TimeStamp(DateTime(2000, 5, 1)),
        TimeStamp(DateTime(2000, 6, 1)),
        TimeStamp(DateTime(2000, 7, 1)),
        TimeStamp(DateTime(2000, 8, 1)),
        TimeStamp(DateTime(2000, 9, 1)),
        TimeStamp(DateTime(2000, 10, 1)),
        TimeStamp(DateTime(2000, 11, 1)),
        TimeStamp(DateTime(2000, 12, 1)),
        TimeStamp(DateTime(2001, 1, 1)),
      ], [
        2,
        1,
        1,
        0,
        0,
        0,
        0,
        0,
        1
      ], xUnit: xUnit, yUnit: yUnit);
      expect(resampled.isEqualTo(tdsExpected), true);
      expect(tdsExpected.isEqualTo(resampled), true);
      expect(resampled.xUnit, equals(xUnit));
      expect(resampled.yUnit, equals(yUnit));
    });
  });
}
