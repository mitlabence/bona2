import 'package:bona2/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class VisualizationView extends ConsumerWidget {
  const VisualizationView({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testAsyncValue = ref.watch(testProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Visualization")),
        body: Center(
      child: testAsyncValue.when(
        data: (dataPoints) => SfCartesianChart(
            primaryXAxis: DateTimeAxis(),
            // Chart title
            title: ChartTitle(text: 'Spendings'),
            // Enable legend
            legend: Legend(isVisible: false),
            // Enable tooltip
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <ChartSeries<_TotalPriceData, DateTime>>[
              FastLineSeries<_TotalPriceData, DateTime>(
                  dataSource: List.generate(dataPoints.length, (index) => _TotalPriceData(dataPoints[index]["datetime"], dataPoints[index]["totalprice"])),
                  xValueMapper: (_TotalPriceData totalPriceData, _) => totalPriceData.dateTime,
                  yValueMapper: (_TotalPriceData totalPriceData, _) => totalPriceData.totalPrice,
                  name: 'Spent9i',
                  // Enable data label
                  dataLabelSettings: DataLabelSettings(isVisible: true))
            ],
          zoomPanBehavior: ZoomPanBehavior(enablePinching: true, enablePanning: true,),
        ),
        error: (_, __) => const Center(
          child: Text("Error"),
        ),
        loading: () => const Text("Loading"),
      ),
    )
    );
  }
}

/*



 */

final testProvider = FutureProvider<List<dynamic>>((ref) async {
  DataBaseHelper dbh = DataBaseHelper.instance;
  final DateTime now = DateTime.now();
  final DateTime startTime = now.subtract(Duration(days: 3*30));

  return dbh.getReceiptsDateTimeTotalPriceBetween(DateTime.fromMillisecondsSinceEpoch(0), now);
});

class _TotalPriceData {
  _TotalPriceData(this.dateTime, this.totalPrice);

  final DateTime dateTime;
  final double totalPrice;
}
