import 'package:calendarro/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:calendarro/calendarro.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Calendarro Demo',
      theme: new ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: new MyHomePage(title: 'Calendarro Demo'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  Calendarro monthCalendarro;
  DateTime todaysDate = DateTime.now();

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var startDate = DateUtils.getFirstDayOfCurrentMonth();
    var endDate = DateUtils.getLastDayOfNextMonth();
    monthCalendarro = Calendarro(
      startDate: startDate,
      endDate: endDate,
      selectedDate: todaysDate,
      displayMode: DisplayMode.MONTHS,
      weekdayLabelsRow: CustomWeekdayLabelsRow(),
      monthLabelStyle: TextStyle(fontSize: 20.0),
      monthLabelOnTap: () {
        print("clicked");
      },
      onTap: (date) {
        monthCalendarro.selectedDates;
        print("onTap: $date");
      },
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.orange,
            child: Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Calendarro(
                weekdayLabelsRow: CustomWeekdayLabelsRow(),
                monthLabelPadding:
                    EdgeInsets.only(top: 10, bottom: 20, left: 20),
                monthLabelStyle: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
                monthLabelBackArrow: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                monthLabelOnTap: () {
                  print("clicked");
                },
                selectedDate: todaysDate,
                startDate: todaysDate.subtract(
                  Duration(days: 500),
                ),
                endDate: todaysDate.add(
                  Duration(days: 200),
                ),
              ),
            ),
          ),
          Container(height: 32.0),
          monthCalendarro
        ],
      ),
    );
  }
}

class CustomWeekdayLabelsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text("M", textAlign: TextAlign.center)),
        Expanded(child: Text("T", textAlign: TextAlign.center)),
        Expanded(child: Text("W", textAlign: TextAlign.center)),
        Expanded(child: Text("T", textAlign: TextAlign.center)),
        Expanded(child: Text("F", textAlign: TextAlign.center)),
        Expanded(child: Text("S", textAlign: TextAlign.center)),
        Expanded(child: Text("S", textAlign: TextAlign.center)),
      ],
    );
  }
}
