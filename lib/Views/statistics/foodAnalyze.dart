import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class FoodAnalyzeWidgit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 50,
            child: Container(color: Colors.grey),
          ),
          Expanded(
            child: AnalyzeChartsWidget(),
          )
        ],
      ),
    );
  }
}

class AnalyzeChartsWidget extends StatefulWidget {
  @override
  _AnalyzeChartsWidgetState createState() => _AnalyzeChartsWidgetState();
}

class _AnalyzeChartsWidgetState extends State<AnalyzeChartsWidget> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.all(20.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                _makeLineChart(),
                _makePieChart(),
              ],
            ),
          ),
        )
      ],
    );
  }

  SfCartesianChart _makeLineChart() {
    return SfCartesianChart(
        plotAreaBorderWidth: 0,
        // Initialize category axis
        primaryXAxis: CategoryAxis(
            majorGridLines: MajorGridLines(width: 0),
            labelPlacement: LabelPlacement.onTicks,
            tickPosition: TickPosition.outside),
        primaryYAxis: NumericAxis(majorGridLines: MajorGridLines(width: 0)),
        title: ChartTitle(text: '存取物品次数', alignment: ChartAlignment.near),
        legend: Legend(
            isVisible: true,
            position: LegendPosition.top,
            alignment: ChartAlignment.far,
            orientation: LegendItemOrientation.vertical),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <LineSeries<SalesData, String>>[
          LineSeries<SalesData, String>(
              // Bind data source
              name: '存',
              color: Colors.red,
              dataSource: <SalesData>[
                SalesData('Jan', 35),
                SalesData('Feb', 28),
                SalesData('Mar', 34),
                SalesData('Apr', 32),
                SalesData('May', 40)
              ],
              xValueMapper: (SalesData sales, _) => sales.month,
              yValueMapper: (SalesData sales, _) => sales.sales,
              dataLabelSettings: DataLabelSettings(isVisible: true)),
          LineSeries<SalesData, String>(
              // Bind data source
              name: '取',
              color: Colors.blue,
              dataSource: <SalesData>[
                SalesData('Jan', 15),
                SalesData('Feb', 38),
                SalesData('Mar', 24),
                SalesData('Apr', 32),
                SalesData('May', 10)
              ],
              xValueMapper: (SalesData sales, _) => sales.month,
              yValueMapper: (SalesData sales, _) => sales.sales,
              dataLabelSettings: DataLabelSettings(isVisible: true))
        ]);
  }

  Widget _makePieChart() {
    return Container(
        height: 300,
        width: 300,
        child: SfCircularChart(
          tooltipBehavior: TooltipBehavior(enable: true),
          legend: Legend(isVisible: true),
          series: <DoughnutSeries<PieData, String>>[
            DoughnutSeries<PieData, String>(
                dataSource: <PieData>[
                  PieData('水果', 5,'0.3'),
                  PieData('蔬菜', 11,'0.5'),
                  PieData('肉', 15,'0.2'),
                  PieData('主食', 9,'0.1'),
                  PieData('饮品', 3,'0.3')
                ],
                opacity: 1,
              
                xValueMapper: (PieData data, _) => data.name,
                yValueMapper: (PieData data, _) => data.count,
                //pointRadiusMapper: (PieData data, _) => data.point,
                sortFieldValueMapper: (PieData data, _) => data.point,
                dataLabelMapper: (PieData data, _) => data.name,
                dataLabelSettings: DataLabelSettings(isVisible: true))
          ],
        ));
  }
}

class SalesData {
  SalesData(this.month, this.sales);
  final String month;
  final double sales;
}

class PieData {
  final String name;
  final int count;
  final String point;
  PieData(this.name, this.count,this.point);
}
