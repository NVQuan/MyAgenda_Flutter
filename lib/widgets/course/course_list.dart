import 'package:flutter/material.dart';
import 'package:flutter_calendar/date_utils.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:myagenda/models/calendar_type.Dart';
import 'package:myagenda/models/courses/base_course.dart';
import 'package:myagenda/models/courses/course.dart';
import 'package:myagenda/utils/date.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/widgets/calendar/calendar_event.dart';
import 'package:myagenda/widgets/course/course_row.dart';
import 'package:myagenda/widgets/course/course_row_header.dart';
import 'package:myagenda/widgets/ui/screen_message/empty_day.dart';

class CourseList extends StatefulWidget {
  final Map<int, List<BaseCourse>> coursesData;
  final int numberWeeks;
  final CalendarType calType;
  final Color noteColor;

  const CourseList({
    Key key,
    @required this.coursesData,
    @required this.numberWeeks,
    @required this.noteColor,
    this.calType = CalendarType.VERTICAL,
  }) : super(key: key);

  _CourseListState createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> {
  DateTime _lastDatePos;

  @override
  void initState() {
    super.initState();
    _lastDatePos = DateTime.now();
  }

  Widget _buildListCours(BuildContext context, List<BaseCourse> courses) {
    List<Widget> widgets = [];

    bool classicView = (widget.calType == CalendarType.HORIZONTAL ||
        widget.calType == CalendarType.VERTICAL);

    if (courses != null && courses.length > 0) {
      courses.forEach((course) {
        if (course == null)
          widgets.add(const EmptyDay());
        else if (course is CourseHeader)
          widgets.add(CourseRowHeader(coursHeader: course));
        else if (course is Course)
          widgets.add(CourseRow(course: course, noteColor: widget.noteColor));
      });
    } else {
      widgets.add(const EmptyDay(
        padding: EdgeInsets.fromLTRB(26.0, 10.0, 26.0, 16.0),
      ));
    }

    return ListView(
      shrinkWrap: true,
      children: widgets,
      padding: EdgeInsets.only(
        bottom: classicView ? 36.0 : 2.0,
        top: widget.calType == CalendarType.VERTICAL ? 0.0 : 12.0,
      ),
    );
  }

  Widget _buildHorizontal(context, Map<int, List<BaseCourse>> elements) {
    if (elements.length < 1) return const SizedBox.shrink();

    List<Widget> listTabView = [];
    List<Widget> tabs = [];

    // Build horizontal view
    DateTime lastDate;
    elements.forEach((date, courses) {
      if (lastDate == null || Date.dateToInt(lastDate) != date)
        lastDate = Date.intToDate(date);

      tabs.add(Tab(text: Date.dateFromNow(lastDate, true)));

      listTabView.add(
        _buildListCours(context, courses),
      );
    });

    final theme = Theme.of(context);

    final baseStyle = theme.primaryTextTheme.title;
    final unselectedStyle = baseStyle.copyWith(
      fontSize: 17.0,
      color: baseStyle.color.withAlpha(180),
    );
    final labelStyle = unselectedStyle.copyWith(color: baseStyle.color);

    return DefaultTabController(
      length: elements.length,
      child: Column(
        children: [
          Container(
            color: theme.primaryColor,
            child: TabBar(
              isScrollable: true,
              tabs: tabs,
              labelColor: labelStyle.color,
              labelStyle: labelStyle,
              unselectedLabelColor: theme.primaryTextTheme.caption.color,
              unselectedLabelStyle: unselectedStyle,
              indicatorPadding: const EdgeInsets.only(bottom: 0.2),
              indicatorWeight: 2.5,
              indicatorColor: labelStyle.color,
            ),
          ),
          Expanded(child: TabBarView(children: listTabView)),
        ],
      ),
    );
  }

  Widget _buildVertical(context, Map<int, List<BaseCourse>> elements) {
    // Build vertical view
    final List<BaseCourse> listChildren = [];
    DateTime lastDate;
    elements.forEach((date, courses) {
      if (lastDate == null || Date.dateToInt(lastDate) != date)
        lastDate = Date.intToDate(date);

      listChildren.add(CourseHeader(lastDate));
      if (courses != null && courses.length > 0) listChildren.addAll(courses);
    });

    return _buildListCours(context, listChildren);
  }

  Widget buildDialog(BuildContext context, DateTime date, Map events) {
    List<Course> courseEvents = _getDayEvents(date, events);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 480),
        child: _buildListCours(context, courseEvents),
      ),
    );
  }

  List<Course> _getDayEvents(
      DateTime day, Map<DateTime, List<BaseCourse>> data) {
    DateTime key = data.keys
        .firstWhere((d) => DateUtils.isSameDay(day, d), orElse: () => null);
    if (key != null)
      return data[key].map((e) {
        if (e is Course) return e;
      }).toList();
    return [];
  }

  Widget _buildCalendar(context, Map<int, List<BaseCourse>> elements) {
    var events = elements.map(
      (intDate, events) => MapEntry(Date.intToDate(intDate), events),
    );

    final isGenColor = PreferencesProvider.of(context).isGenerateEventColor;
    final today = DateTime.now();

    // Build calendar view
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Calendar(
        monthView: widget.calType == CalendarType.MONTH_VIEW,
        firstDate: DateTime(today.year, today.month, today.day),
        initialSelectedDate: _lastDatePos,
        dayBuilder: (_, date) => _getDayEvents(date, events).map((e) {
              return Event(title: e.title, color: e.getColor(isGenColor));
            }).toList(),
        onDateSelected: (date) {
          showDialog(
            context: context,
            builder: (dCtx) => buildDialog(dCtx, date, events),
          );
          setState(() => _lastDatePos = date);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var content;
    if (widget.calType == CalendarType.VERTICAL)
      content = _buildVertical(context, widget.coursesData);
    else if (widget.calType == CalendarType.HORIZONTAL)
      content = _buildHorizontal(context, widget.coursesData);
    else
      content = _buildCalendar(context, widget.coursesData);

    return Container(child: content);
  }
}
