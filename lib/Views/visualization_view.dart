import 'package:bona2/database_helper.dart';
import 'package:bona2/utils/time_series_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class VisualizationView extends ConsumerWidget {
  const VisualizationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testAsyncValue = ref.watch(testProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Text("Receipts and Items"),
          centerTitle: true,
          actions: [
            PopupMenuButton(
                itemBuilder: (context) => [
                      PopupMenuItem<int>(
                          onTap: () {
                            print("pressed button in visualizatioin");
                          },
                          child: const Text("sample button"))
                    ])
          ],
        ),
        body: Center(
          child: testAsyncValue.when(
            data: (dataPoints) {
              // Generate TimeSeriesData with daily intervals, and sum of total price per day
              List<TimeStamp> ts = List.generate(dataPoints.length,
                  (index) => TimeStamp(dataPoints[index]["datetime"]));
              List<num> ys = List.generate(dataPoints.length,
                  (index) => dataPoints[index]["totalprice"]);
              //String currency = dataPoints.isNotEmpty ? dataPoints[0]["currency"] : "NaN";
              final TimeSeriesData timeSeriesData =
                  TimeSeriesData(ts, ys, yUnit: "EUR").resampleMonths(
                      TimeStamp(DateTime(2021, 01, 01)),
                      TimeStamp(DateTime.now()),
                      (l) => l.reduce((value, element) => value + element));
              return SfCartesianChart(
                primaryXAxis: DateTimeAxis(),
                // Chart title
                title: ChartTitle(text: 'Spendings'),
                // Enable legend
                legend: const Legend(isVisible: false),
                // Enable tooltip
                tooltipBehavior: TooltipBehavior(
                    enable: true,
                    builder: (dynamic data, dynamic point, dynamic series,
                        int pointIndex, int seriesIndex) {
                      return Container(
                        height: 50,
                        width: 100,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        // FIXME currency not working
                        child: Text(
                            '${data.dateTime.year}.${data.dateTime.month}. - ${data.totalPrice.toStringAsFixed(2)} ${data.currency}'),
                      );
                    }),
                series: <ChartSeries<_TotalPriceData, DateTime>>[
                  FastLineSeries<_TotalPriceData, DateTime>(
                    dataSource: List.generate(
                        timeSeriesData.length,
                        (index) => _TotalPriceData(
                            timeSeriesData.t[index].dateTime,
                            timeSeriesData.y[index].toDouble(),
                            timeSeriesData.yUnit)),
                    xValueMapper: (_TotalPriceData totalPriceData, _) =>
                        totalPriceData.dateTime,
                    yValueMapper: (_TotalPriceData totalPriceData, _) =>
                        totalPriceData.totalPrice,
                    name: 'Spent',
                    // TODO: show instead time frame! Remake TotalPriceData into DataPoint that uses TimeStamp, or better yet, TimeSeriesData
                    // Enable data label
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
                zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true,
                  enablePanning: true,
                ),
              );
            },
            error: (_, __) => const Center(
              child: Text("Error"),
            ),
            loading: () => const Text("Loading"),
          ),
        ));
  }
}

/*



 */

final testProvider = FutureProvider<List<dynamic>>((ref) async {
  DataBaseHelper dbh = DataBaseHelper.instance;
  final DateTime now = DateTime.now();
  return dbh.getReceiptsDateTimeTotalPriceCurrencyBetween(
      DateTime.fromMillisecondsSinceEpoch(0), now);
});

class _TotalPriceData {
  _TotalPriceData(this.dateTime, this.totalPrice, this.currency);

  final DateTime dateTime;
  final double totalPrice;
  final String currency;
}
