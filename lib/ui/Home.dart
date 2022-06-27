import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double? y;
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  late TooltipBehavior _tooltipBehavior;
  int pulse_val = 0;
  String bp_value = "";
  List ecg_value = [0, 0, 0, 0, 0];
  double temp_val = 0.0;

  List<ChartData> chartdata = [];

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
    setUpTimedFetch();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  setUpTimedFetch() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchAlbum();
    });
  }

  void fetchAlbum() async {
    chartdata.clear();
    var data = jsonEncode({"Location": "belgaum,karnataka"});
    final response = await http.post(
      Uri.http("192.168.1.103:5000", "getSensorValues"),
      body: data,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    final responseJson = jsonDecode(response.body);
    print(responseJson);
    setState(() {
      temp_val = responseJson['result']['tempValue'].toDouble();
      pulse_val = responseJson['result']['heartRateValue'];
      ecg_value = responseJson['result']['ecgValue'];
      bp_value = responseJson['result']['bpValue'];
      for (int i = 0; i < 5; i++) {
        chartdata
            .add(ChartData((i + 1).toString(), double.parse(ecg_value[i])));
      }
    });
    print(chartdata);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 20,
        backgroundColor: Colors.blue,
        title: const Text('Patient Health Monitoring'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 10, 0),
                  child: Image.asset('temp.png', width: 150, height: 120),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 50, 10),
                  child: Text(temp_val.toString(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 10, 0),
                  child: Image.asset('heart-rate.png', width: 150, height: 120),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 40, 10),
                  child: Text(pulse_val.toString(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 10, 10, 0),
                  child: Image.asset('bp-sensor.png', width: 150, height: 150),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 30, 0),
                  child: Text(bp_value,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 10, 10, 10),
                  child: Image.asset('ecg.png', width: 150, height: 150),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 100, 0),
                    child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        tooltipBehavior: _tooltipBehavior,
                        title: ChartTitle(text: 'ECG data Graph'),
                        series: <ChartSeries>[
                          // Initialize line series
                          LineSeries<ChartData, String>(
                              enableTooltip: true,
                              dataSource: chartdata,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y),
                        ])),
              ],
            )
          ],
        ),
      ),
    );
  }
}
