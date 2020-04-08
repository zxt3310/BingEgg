import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sirilike_flutter/model/network.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class FoodStatistics extends StatefulWidget {
  @override
  _FoodStatisticsState createState() => _FoodStatisticsState();
}

class _FoodStatisticsState extends State<FoodStatistics> {
  Future dataFutre;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('统计', style: TextStyle(color: Colors.white)),
          brightness: Brightness.dark,
        ),
        body: _makePieChart());
  }

  Widget _makePieChart() {
    return FutureBuilder(
        future: dataFutre,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Response res = snapshot.data;
            if(res.data['err'] !=0){
              return Container(child: Center(child: Text('网络出错')));
            }
            var piedata = res.data['data']['current_inventory_chart'] ;
            double total = _getTotal(piedata);
            
            return Container(
                height: 350,
                child: SfCircularChart(
                  title: ChartTitle(text: '食物占比分析'),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  legend: Legend(isVisible: true),
                  series: <DoughnutSeries<PieData, String>>[
                    DoughnutSeries<PieData, String>(
                        dataSource: _getDataList(piedata),
                        opacity: 1,
                        radius: '65%',
                        innerRadius: '40%',
                        explode: true,
                        xValueMapper: (PieData data, _) => data.name,
                        yValueMapper: (PieData data, _) => data.count,
                        dataLabelMapper: (PieData data, _) => (data.count/total*100).round().toString() + "%",
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
          }else{
            return Container(child: Center(child: Text('loading...'),),);
          }
        });
  }

  double _getTotal(Map<String,dynamic> json){
    double sum = 0;
    json.forEach((key,value){
      sum+=value.toDouble();
    });
    return sum;
  }

  List <PieData> _getDataList(Map<String,dynamic> json){
    List<PieData> list = List<PieData>();
    json.forEach((key,value){
      list.add(PieData(key, value.toDouble()));
    });
    return list;
  }

  @override
  void initState() {
    dataFutre = requestData();
    super.initState();
  }

  Future requestData() async {
    return NetManager.instance.dio.get('/api/statistics');
  }
}

class PieData {
  final String name;
  final double count;
  PieData(this.name, this.count);
}
