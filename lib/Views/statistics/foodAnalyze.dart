import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:gzx_dropdown_menu/gzx_dropdown_menu.dart';

class FoodAnalyzeWidgit extends StatefulWidget {
  @override
  _FoodAnalyzeWidgitState createState() => _FoodAnalyzeWidgitState();
}

class _FoodAnalyzeWidgitState extends State<FoodAnalyzeWidgit> {
  GlobalKey _stackKey = GlobalKey();
  GZXDropdownMenuController _dropdownMenuController =
      GZXDropdownMenuController();

  int curSelYear;
  int curSelMonth;

  @override
  void initState() {
    super.initState();
    int days = DateTime.now().day;
    DateTime lastMonth = DateTime.now().subtract(Duration(days: days + 1));
    curSelMonth = lastMonth.month;
    curSelYear = lastMonth.year;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('统计', style: TextStyle(color: Colors.white)),
        brightness: Brightness.dark,
      ),
      body: Stack(
        key: _stackKey,
        children: <Widget>[
          Column(children: <Widget>[
            GZXDropDownHeader(
              items: [
                GZXDropDownHeaderItem('$curSelYear年'),
                GZXDropDownHeaderItem('$curSelMonth月')
              ],
              controller: _dropdownMenuController,
              stackKey: _stackKey,
              onItemTap: (index) {},
            ),
            Expanded(child: AnalyzeChartsWidget())
          ]),
          GZXDropDownMenu(
            controller: _dropdownMenuController,
            animationMilliseconds: 100,
            menus: [
              GZXDropdownMenuBuilder(
                  dropDownHeight: 100,
                  dropDownWidget: Container(child: _getYearList((value) {
                    curSelYear = value;
                    _dropdownMenuController.hide();
                    setState(() {});
                  }))),
              GZXDropdownMenuBuilder(
                  dropDownHeight: 200,
                  dropDownWidget: Container(child: _getMonthList((value) {
                    curSelMonth = value;
                    _dropdownMenuController.hide();
                    setState(() {});
                  }))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getYearList(void itemOnTap(value)) {
    int year = DateTime.now().year;
    return Container(
        child: ListView.separated(
      itemCount: year - 2019 + 1,
      itemBuilder: (context, idx) {
        return GestureDetector(
            onTap: () {
              itemOnTap(idx + 2019);
            },
            child: Container(
              height: 30,
              color: Colors.grey[100],
              child: Center(child: Text('${idx + 2019}年')),
            ));
      },
      separatorBuilder: (context, idx) {
        return Container(
          height: 1,
          color: Colors.grey[300],
        );
      },
    ));
  }

  Widget _getMonthList(void itemOnTap(value)) {
    int year = DateTime.now().year;
    int days = DateTime.now().day;
    DateTime lastMonth = DateTime.now().subtract(Duration(days: days + 1));
    return Container(
        child: ListView.separated(
      itemCount: curSelYear == year ? lastMonth.month : 12,
      itemBuilder: (context, idx) {
        return GestureDetector(
            onTap: () {
              itemOnTap(idx + 1);
            },
            child: Container(
              color: Colors.grey[100],
              height: 30,
              child: Center(child: Text('${idx + 1}月')),
            ));
      },
      separatorBuilder: (context, idx) {
        return Container(
          height: 1,
          color: Colors.grey[300],
        );
      },
    ));
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
        trackballBehavior:
            TrackballBehavior(enable: true, lineDashArray: [10, 10]),
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
              markerSettings: MarkerSettings(
                  isVisible: true, shape: DataMarkerType.diamond),
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
              markerSettings: MarkerSettings(isVisible: true),
              dataLabelSettings: DataLabelSettings(isVisible: true))
        ]);
  }

  Widget _makePieChart() {
    return Container(
        height: 350,
        child: SfCircularChart(
          title: ChartTitle(text: '占比分析'),
          tooltipBehavior: TooltipBehavior(enable: true),
          legend: Legend(isVisible: true),
          series: <DoughnutSeries<PieData, String>>[
            DoughnutSeries<PieData, String>(
                dataSource: <PieData>[
                  PieData('水果', 30, '30%'),
                  PieData('蔬菜', 10, '10%'),
                  PieData('肉', 20, '20%'),
                  PieData('主食', 30, '30%'),
                  PieData('饮品', 10, '10%'),
                  PieData('牛奶', 3, '3%')
                ],
                opacity: 1,
                radius: '65%',
                innerRadius: '40%',
                explode: true,
                xValueMapper: (PieData data, _) => data.name,
                yValueMapper: (PieData data, _) => data.count,
                dataLabelMapper: (PieData data, _) => data.point,
                dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    showCumulativeValues: true,
                    textStyle: ChartTextStyle(fontSize: 13),
                    labelIntersectAction: LabelIntersectAction.none,
                    connectorLineSettings:
                        ConnectorLineSettings(width: 2, length: '15'),
                    labelPosition: ChartDataLabelPosition.outside))
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
  PieData(this.name, this.count, this.point);
}
