import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:reggae_fitness_studio/app_theme.dart';
import 'package:reggae_fitness_studio/models/chart_data_column.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../assets/constants.dart' as constants;
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/chart_data.dart';

class AttendanceReport extends StatefulWidget {
  const AttendanceReport({Key? key, this.animationController})
      : super(key: key);

  final AnimationController? animationController;
  @override
  _AttendanceReportState createState() => _AttendanceReportState();
}

class _AttendanceReportState extends State<AttendanceReport> {
  String? dropdownvalue;
  String user_info = '';
  String id = '';
  bool _visibility = true;
  late var income;
  late var total_class;
  late var zumba;
  late var bootcamp;
  late var sn;
  late var numberPaid;
  late var numberUnpaid;
  late var presentBootcamp;
  late var absentBootcamp;
  late var presentSN;
  late var absentSN;
  late var presentZumba;
  late var absentZumba;
  late var presentRate;
  String startdate = '';
  String enddate = '';
  DateRangePickerController _datePickerController = DateRangePickerController();

  Future<void> getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_info = preferences.getString('u_info')!;
      Map<String, dynamic> map = jsonDecode(user_info);
      id = map['u_id'];
    });
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  Future generateIncomeReport(String sdate, String edate) async {
    var url =
        "http://" + constants.IP_ADDRESS + "/reggaefitness/get_report.php";
    var response = await http.post(Uri.parse(url), body: {
      "u_id": id,
      "start_date": sdate,
      "end_date": edate,
    });
    var data = json.decode(response.body);

    setState(() {
      income = (data['income']).toString();
      total_class = (data['total_class']).toString();
      zumba = int.parse(data['zumba_class'].toString());
      bootcamp = int.parse(data['bootcamp_class'].toString());
      sn = int.parse(data['sn_class'].toString());
      numberPaid = (data['paid']).toString();
      numberUnpaid = (data['unpaid']).toString();
      presentRate = (data['present_rate']).toStringAsFixed(2);
      presentBootcamp = int.parse(data['present_bootcamp'].toString());
      absentBootcamp = int.parse(data['absent_bootcamp'].toString());
      presentSN = int.parse(data['present_sn'].toString());
      absentSN = int.parse(data['absent_sn'].toString());
      presentZumba = int.parse(data['present_zumba'].toString());
      absentZumba = int.parse(data['absent_zumba'].toString());
    });
    return data;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MaterialApp(
      title: "Report",
      home: Scaffold(
        backgroundColor: ReggaeFitnessTheme.background,
        appBar: AppBar(
            centerTitle: true,
            backgroundColor: ReggaeFitnessTheme.nearlyDarkBlue,
            title: new Text('Report'),
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back_ios_new_rounded),
            )),
        body: SingleChildScrollView(
          child: Form(
              child: Column(children: <Widget>[
            Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () {
                        setState(() {
                          _visibility = !_visibility;
                        });
                      },
                      child: Text(_visibility ? "HIDE" : "SHOW")),
                ),
                BuildDatePicker(),
                const SizedBox(height: 16),
                BuildReport(),
              ],
            )
          ])),
        ),
      ),
    );
  }

  BuildDatePicker() => Container(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Visibility(
          visible: _visibility,
          child: SfDateRangePicker(
            view: DateRangePickerView.year,
            monthViewSettings:
                DateRangePickerMonthViewSettings(firstDayOfWeek: 6),
            selectionMode: DateRangePickerSelectionMode.range,
            allowViewNavigation: true,
            navigationMode: DateRangePickerNavigationMode.scroll,
            backgroundColor: Colors.white,
            rangeSelectionColor: Colors.blueAccent,
            showActionButtons: true,
            controller: _datePickerController,
            onSubmit: (Object? val) {
              if (val is PickerDateRange) {
                setState(() {
                  //final DateTime startdate = val.startDate!;
                  final DateTime rangeEndDate = val.endDate!;
                  startdate = DateFormat("yyyy-MM-dd").format(val.startDate!);
                  enddate = DateFormat("yyyy-MM-dd").format(val.endDate!);
                });
              }
              //generateIncomeReport(startdate, enddate);
            },
            onCancel: () {
              _datePickerController.selectedRanges = null;
            },
          ),
        ),
      );

  BuildReport() => Container(
      child: FutureBuilder(
          future: generateIncomeReport(startdate, enddate),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<ChartDataColumn> chartData2 = <ChartDataColumn>[
                ChartDataColumn('Strong Nation', presentSN, absentSN),
                ChartDataColumn('Zumba', presentZumba, absentZumba),
                ChartDataColumn('Bootcamp', presentBootcamp, absentBootcamp),
              ];
              final List<ChartDataDoughnut> chartData = [
                ChartDataDoughnut('Strong Nation', sn),
                ChartDataDoughnut('Zumba', zumba),
                ChartDataDoughnut('Bootcamp', bootcamp),
              ];
              return Padding(
                padding: EdgeInsets.all(10.0),
                child: Container(
                    child: Column(
                  children: [
                    Container(
                        child: Column(
                      children: [
                        /*
                        Container(
                          color: Colors.white,
                          child: SfCircularChart(
                              annotations: <CircularChartAnnotation>[
                                CircularChartAnnotation(
                                    widget: Container(
                                        child: const Text('Class',
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.5),
                                                fontSize: 25))))
                              ],
                              palette: [
                                Colors.blueGrey,
                                Colors.blue,
                                Colors.lightBlueAccent
                              ],
                              legend: Legend(
                                  isVisible: true,
                                  position: LegendPosition.bottom),
                              series: <CircularSeries>[
                                // Renders doughnut chart
                                DoughnutSeries<ChartDataDoughnut, String>(
                                  dataLabelSettings: DataLabelSettings(
                                    isVisible: true,
                                    showZeroValue: false,
                                    useSeriesColor: true,
                                  ),
                                  dataSource: chartData,
                                  xValueMapper: (ChartDataDoughnut data, _) =>
                                      data.x,
                                  yValueMapper: (ChartDataDoughnut data, _) =>
                                      data.y,
                                  innerRadius: '60%',
                                  legendIconType: LegendIconType.diamond,
                                )
                              ]),
                        ),
                        const SizedBox(height: 16),

                         */
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: ReggaeFitnessTheme.nearlyWhite,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey,
                                    offset: const Offset(1.1, 1.1),
                                    blurRadius: 10.0),
                              ],
                            ),
                            child: SfCartesianChart(
                              primaryXAxis: CategoryAxis(),
                              palette: [Colors.blueAccent, Colors.greenAccent],
                              legend: Legend(
                                  isVisible: true,
                                  toggleSeriesVisibility: true,
                                  position: LegendPosition.bottom),
                              series: <CartesianSeries>[
                                ColumnSeries<ChartDataColumn, String>(
                                    name: "Present",
                                    dataSource: chartData2,
                                    xValueMapper: (ChartDataColumn data, _) =>
                                        data.x,
                                    yValueMapper: (ChartDataColumn data, _) =>
                                        data.y),
                                ColumnSeries<ChartDataColumn, String>(
                                    name: "Absent",
                                    dataSource: chartData2,
                                    xValueMapper: (ChartDataColumn data, _) =>
                                        data.x,
                                    yValueMapper: (ChartDataColumn data, _) =>
                                        data.y1),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
                    const SizedBox(height: 16),
                    BuildSummary(),
                    const SizedBox(height: 16),
                    BuildOverview(),
                  ],
                )),
              );
            } else {
              return Text("Nothing to show");
            }
          }));

  BuildSummary() => Container(
      padding: EdgeInsets.all(10.0),
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(
                width: 240,
                child: Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(16.0)),
                      color: ReggaeFitnessTheme.nearlyWhite,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: Image.asset('assets/images/report_blue.png'),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  "Strong Nation",
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: ReggaeFitnessTheme.nearlyBlack,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 12),
                                child: Text(sn.toString() + " Classes",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: ReggaeFitnessTheme.blueGrey,
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 240,
                child: Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(16.0)),
                      color: ReggaeFitnessTheme.nearlyWhite,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: Image.asset('assets/images/report_pink.png'),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  "Zumba",
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: ReggaeFitnessTheme.nearlyBlack,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 12),
                                child: Text(zumba.toString() + " Classes",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: ReggaeFitnessTheme.blueGrey,
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 240,
                child: Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(16.0)),
                      color: ReggaeFitnessTheme.nearlyWhite,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child:
                                Image.asset('assets/images/report_orange.png'),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  "Bootcamp",
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: ReggaeFitnessTheme.nearlyBlack,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 12),
                                child: Text(bootcamp.toString() + " Classes",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: ReggaeFitnessTheme.blueGrey,
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
              ),
            ],
          )));

  BuildOverview() => Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Overview",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: ReggaeFitnessTheme.nearlyBlack,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Container(
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                color: ReggaeFitnessTheme.nearlyWhite,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey,
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Image.asset('assets/images/barbell.png'),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  "Total Class",
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                    color: ReggaeFitnessTheme.nearlyBlack,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  total_class + " Classes",
                                  style: TextStyle(
                                    fontSize: 19,
                                    color: ReggaeFitnessTheme.blueGrey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: Container(
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                color: ReggaeFitnessTheme.white,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey,
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Image.asset('assets/images/rating.png'),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  "Present Rate",
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                    color: ReggaeFitnessTheme.nearlyBlack,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    presentRate + " %",
                                    style: TextStyle(
                                      fontSize: 19,
                                      color: ReggaeFitnessTheme.blueGrey,
                                    ),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: Container(
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                color: ReggaeFitnessTheme.white,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey,
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Image.asset('assets/images/earnings.png'),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  "Earnings",
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                    color: ReggaeFitnessTheme.nearlyBlack,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    "RM " + income,
                                    style: TextStyle(
                                      fontSize: 19,
                                      color: ReggaeFitnessTheme.blueGrey,
                                    ),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ));
}
