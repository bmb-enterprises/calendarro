library calendarro;

import 'package:calendarro/calendarro_page.dart';
import 'package:calendarro/default_weekday_labels_row.dart';
import 'package:calendarro/date_utils.dart';
import 'package:calendarro/default_day_tile_builder.dart';
import 'package:flutter/material.dart';

abstract class DayTileBuilder {
  Widget build(BuildContext context, DateTime date, DateTimeCallback onTap);
}

enum DisplayMode { MONTHS, WEEKS }
enum SelectionMode { SINGLE, MULTI }

typedef void DateTimeCallback(DateTime datime);

class Calendarro extends StatefulWidget {
  DateTime startDate;
  DateTime endDate;
  DisplayMode displayMode;
  SelectionMode selectionMode;
  DayTileBuilder dayTileBuilder;
  Widget weekdayLabelsRow;
  DateTimeCallback onTap;

  DateTime selectedDate;
  List<DateTime> selectedDates;

  int startDayOffset;
  CalendarroState state;

  double dayTileHeight = 40.0;
  double dayLabelHeight = 20.0;

  TextStyle monthLabelStyle;
  Function monthLabelOnTap;
  EdgeInsets monthLabelPadding;
  Icon monthLabelBackArrow;

  Calendarro({
    Key key,
    this.startDate,
    this.endDate,
    this.displayMode = DisplayMode.WEEKS,
    this.dayTileBuilder,
    this.selectedDate,
    this.selectedDates,
    this.selectionMode = SelectionMode.SINGLE,
    this.onTap,
    this.weekdayLabelsRow,
    this.monthLabelStyle,
    this.monthLabelOnTap,
    this.monthLabelPadding,
    this.monthLabelBackArrow,
  }) : super(key: key) {
    if (startDate == null) {
      startDate = DateUtils.getFirstDayOfCurrentMonth();
    }
    startDate = DateUtils.toMidnight(startDate);

    if (endDate == null) {
      endDate = DateUtils.getLastDayOfCurrentMonth();
    }
    endDate = DateUtils.toMidnight(endDate);
    startDayOffset = startDate.weekday - DateTime.monday;

    if (dayTileBuilder == null) {
      dayTileBuilder = DefaultDayTileBuilder();
    }

    if (weekdayLabelsRow == null) {
      weekdayLabelsRow = CalendarroWeekdayLabelsView();
    }

    if (selectedDates == null) {
      selectedDates = List();
    }
  }

  static CalendarroState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<CalendarroState>());

  @override
  CalendarroState createState() {
    state = CalendarroState(
        selectedDate: selectedDate, selectedDates: selectedDates);
    return state;
  }

  void setSelectedDate(DateTime date) {
    state.setSelectedDate(date);
  }

  void toggleDate(DateTime date) {
    state.toggleDateSelection(date);
  }

  void setCurrentDate(DateTime date) {
    state.setCurrentDate(date);
  }

  int getPositionOfDate(DateTime date) {
    int daysDifference =
        date.difference(DateUtils.toMidnight(startDate)).inDays;
    int weekendsDifference = ((daysDifference + startDate.weekday) / 7).toInt();
    var position = daysDifference - weekendsDifference * 2;
    return position;
  }

  int getPageForDate(DateTime date) {
    if (displayMode == DisplayMode.WEEKS) {
      int daysDifferenceFromStartDate = date.difference(startDate).inDays;
      int page = (daysDifferenceFromStartDate + startDayOffset) ~/ 7;
      return page;
    } else {
      var monthDifference = (date.year * 12 + date.month) -
          (startDate.year * 12 + startDate.month);
      return monthDifference;
    }
  }
}

class CalendarroState extends State<Calendarro> {
  DateTime selectedDate;
  List<DateTime> selectedDates;
  String monthLabel = "";

  int pagesCount;
  PageView pageView;

  CalendarroState({this.selectedDate, this.selectedDates});

  @override
  void initState() {
    super.initState();

    if (selectedDate == null) {
      selectedDate = widget.startDate;
    }

    monthLabel = getMonthText(widget.selectedDate);
  }

  void setSelectedDate(DateTime date) {
    setState(() {
      if (widget.selectionMode == SelectionMode.SINGLE) {
        selectedDate = date;
      } else {
        bool dateSelected = false;

        for (var i = selectedDates.length - 1; i >= 0; i--) {
          if (DateUtils.isSameDay(selectedDates[i], date)) {
            selectedDates.removeAt(i);
            dateSelected = true;
          }
        }

        if (!dateSelected) {
          selectedDates.add(date);
        }
      }
    });
  }

  void setCurrentDate(DateTime date) {
    setState(() {
      int page = widget.getPageForDate(date);
      pageView.controller.jumpToPage(page);
    });
  }

  Map<String, DateTime> getStartAndEnd(int position) {
    DateTime pageStartDate;
    DateTime pageEndDate;

    if (widget.displayMode == DisplayMode.WEEKS) {
      if (position == 0) {
        pageStartDate = widget.startDate;
        pageEndDate = DateUtils.addDaysToDate(
            widget.startDate, 6 - widget.startDayOffset);
      } else if (position == pagesCount - 1) {
        pageStartDate = DateUtils.addDaysToDate(
            widget.startDate, 7 * position - widget.startDayOffset);
        pageEndDate = widget.endDate;
      } else {
        pageStartDate = DateUtils.addDaysToDate(
            widget.startDate, 7 * position - widget.startDayOffset);
        pageEndDate = DateUtils.addDaysToDate(
            widget.startDate, 7 * position + 6 - widget.startDayOffset);
      }
    } else {
      if (position == 0) {
        pageStartDate = widget.startDate;
        if (pagesCount <= 1) {
          pageEndDate = widget.endDate;
        } else {
          var lastDayOfMonth = DateUtils.getLastDayOfMonth(widget.startDate);
          pageEndDate = lastDayOfMonth;
        }
      } else if (position == pagesCount - 1) {
        pageStartDate = DateUtils.getFirstDayOfMonth(widget.endDate);
        pageEndDate = widget.endDate;
      } else {
        DateTime firstDateOfCurrentMonth =
            DateUtils.addMonths(widget.startDate, position);
        pageStartDate = firstDateOfCurrentMonth;
        pageEndDate = DateUtils.getLastDayOfMonth(firstDateOfCurrentMonth);
      }
    }

    return {"start": pageStartDate, "end": pageEndDate};
  }

  void setMonthLabel(int position) {
    Map<String, DateTime> dates = getStartAndEnd(position);
    DateTime pageStartDate = dates["start"];

    setState(() {
      monthLabel = getMonthText(pageStartDate);
    });
  }

  String getMonthText(DateTime dateTime) {
    String dateString = "";

    switch (dateTime.month) {
      case 1:
        {
          dateString = "January";
        }
        break;
      case 2:
        {
          dateString = "Febuary";
        }
        break;

      case 3:
        {
          dateString = "March";
        }
        break;
      case 4:
        {
          dateString = "April";
        }
        break;
      case 5:
        {
          dateString = "May";
        }
        break;
      case 6:
        {
          dateString = "June";
        }
        break;
      case 7:
        {
          dateString = "July";
        }
        break;
      case 8:
        {
          dateString = "Augest";
        }
        break;
      case 9:
        {
          dateString = "September";
        }
        break;
      case 10:
        {
          dateString = "October";
        }
        break;
      case 11:
        {
          dateString = "November";
        }
        break;
      case 12:
        {
          dateString = "December";
        }
        break;
      default:
        {
          dateString = "January";
        }
        break;
    }

    if (widget.selectedDate.year != dateTime.year) {
      dateString = dateString + ", ${dateTime.year}";
    }
    return dateString;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.displayMode == DisplayMode.WEEKS) {
      int lastPage = widget.getPageForDate(widget.endDate);
      pagesCount = lastPage + 1;
    } else {
      pagesCount = widget.endDate.month - widget.startDate.month + 1;
    }

    pageView = PageView.builder(
      itemBuilder: (context, position) => buildCalendarPage(position),
      itemCount: pagesCount,
      onPageChanged: setMonthLabel,
      controller: PageController(
        initialPage:
            selectedDate != null ? widget.getPageForDate(selectedDate) : 0,
      ),
    );

    double widgetHeight;
    if (widget.displayMode == DisplayMode.WEEKS) {
      widgetHeight = widget.dayLabelHeight + widget.dayTileHeight;
    } else {
      var maxWeeksNumber = DateUtils.calculateMaxWeeksNumberMonthly(
          widget.startDate, widget.endDate);
      widgetHeight =
          widget.dayLabelHeight + maxWeeksNumber * widget.dayTileHeight;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: widget.monthLabelPadding ?? EdgeInsets.all(20),
          child: InkWell(
            onTap: widget.monthLabelOnTap,
            child: Row(
              children: <Widget>[
                widget.monthLabelBackArrow ?? Container(),
                Text(
                  monthLabel,
                  style: widget.monthLabelStyle,
                ),
              ],
            ),
          ),
        ),
        widget.weekdayLabelsRow,
        Container(
          height: widgetHeight,
          child: pageView,
        )
      ],
    );
  }

  Widget buildCalendarPage(int position) {
    if (widget.displayMode == DisplayMode.WEEKS) {
      return buildCalendarPageInWeeksMode(position);
    } else {
      return buildCalendarPageInMonthsMode(position);
    }
  }

  Widget buildCalendarPageInWeeksMode(int position) {
    DateTime pageStartDate;
    DateTime pageEndDate;

    if (position == 0) {
      pageStartDate = widget.startDate;
      pageEndDate =
          DateUtils.addDaysToDate(widget.startDate, 6 - widget.startDayOffset);
    } else if (position == pagesCount - 1) {
      pageStartDate = DateUtils.addDaysToDate(
          widget.startDate, 7 * position - widget.startDayOffset);
      pageEndDate = widget.endDate;
    } else {
      pageStartDate = DateUtils.addDaysToDate(
          widget.startDate, 7 * position - widget.startDayOffset);
      pageEndDate = DateUtils.addDaysToDate(
          widget.startDate, 7 * position + 6 - widget.startDayOffset);
    }

    return CalendarroPage(
      pageStartDate: pageStartDate,
      pageEndDate: pageEndDate,
    );
  }

  Widget buildCalendarPageInMonthsMode(int position) {
    DateTime pageStartDate;
    DateTime pageEndDate;

    if (position == 0) {
      pageStartDate = widget.startDate;
      if (pagesCount <= 1) {
        pageEndDate = widget.endDate;
      } else {
        var lastDayOfMonth = DateUtils.getLastDayOfMonth(widget.startDate);
        pageEndDate = lastDayOfMonth;
      }
    } else if (position == pagesCount - 1) {
      pageStartDate = DateUtils.getFirstDayOfMonth(widget.endDate);
      pageEndDate = widget.endDate;
    } else {
      DateTime firstDateOfCurrentMonth =
          DateUtils.addMonths(widget.startDate, position);
      pageStartDate = firstDateOfCurrentMonth;
      pageEndDate = DateUtils.getLastDayOfMonth(firstDateOfCurrentMonth);
    }

    return CalendarroPage(
      pageStartDate: pageStartDate,
      pageEndDate: pageEndDate,
    );
  }

  bool isDateSelected(DateTime date) {
    if (widget.selectionMode == SelectionMode.MULTI) {
      return selectedDates.contains(date);
    } else {
      return DateUtils.isSameDay(selectedDate, date);
    }
  }

  void toggleDateSelection(DateTime date) {
    setState(() {
      for (var i = selectedDates.length - 1; i >= 0; i--) {
        if (DateUtils.isSameDay(selectedDates[i], date)) {
          selectedDates.removeAt(i);
          return;
        }
      }

      selectedDates.add(date);
    });
  }

  void update() {
    setState(() {});
  }
}
