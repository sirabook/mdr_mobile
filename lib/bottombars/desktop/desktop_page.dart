import 'package:flutter/material.dart';
import 'package:mdr_mobile/bottombars/days_filter.dart';
import 'package:mdr_mobile/bottombars/desktop/incident_list_page.dart';

class DesktopPage extends StatefulWidget {
  const DesktopPage({Key? key}) : super(key: key);

  @override
  _DesktopPageState createState() => _DesktopPageState();
}

class _DesktopPageState extends State<DesktopPage> {
  int? selectedDays = 1;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  void updateFilter(int? days, {DateTime? startDate, DateTime? endDate}) {
    setState(() {
      if (days != null) {
        selectedDays = days;
        selectedStartDate = null;
        selectedEndDate = null;
      } else if (startDate != null && endDate != null) {
        selectedDays = null;
        selectedStartDate = startDate;
        selectedEndDate = endDate;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DaysFilter(
                  selectedDays: selectedDays,
                  selectedStartDate: selectedStartDate,
                  selectedEndDate: selectedEndDate,
                  onFilterChanged: updateFilter,
                ),
                SizedBox(height: 20),
                Text(
                  "Incidents",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: IncidentListPage(
              selectedDays: selectedDays,
              selectedStartDate: selectedStartDate,
              selectedEndDate: selectedEndDate,
            ),
          ),
          
        ],
      ),
    );
  }
}
