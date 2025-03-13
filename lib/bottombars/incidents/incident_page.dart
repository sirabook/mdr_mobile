import 'package:flutter/material.dart';
import 'package:mdr_mobile/bottombars/incidents/incident_severity.dart';
import 'package:mdr_mobile/bottombars/incidents/incident_summary.dart';
import 'package:mdr_mobile/bottombars/days_filter.dart';
import 'package:mdr_mobile/bottombars/incidents/incident_tenant.dart';


class IncidentPage extends StatefulWidget {
  const IncidentPage({Key? key}) : super(key: key);

  @override
  _IncidentPageState createState() => _IncidentPageState();
}

class _IncidentPageState extends State<IncidentPage> {
  int? selectedDays = 1; // ค่าเริ่มต้น: 1 วัน
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
    return Container(
      color: Color.fromARGB(255, 255, 240, 199),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 ใช้ DaysFilter ที่รองรับช่วงวัน
                DaysFilter(
                  selectedDays: selectedDays,
                  selectedStartDate: selectedStartDate,
                  selectedEndDate: selectedEndDate,
                  onFilterChanged: updateFilter,
                ),
                 SizedBox(height: 20),

                //  IncidentSummaryScreen
                 Text(
                  "Incident Summary",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                IncidentSummary(
                  selectedDays: selectedDays,
                  selectedStartDate: selectedStartDate,
                  selectedEndDate: selectedEndDate,
                ),

                 SizedBox(height: 20),
                IncidentSeverity(
                  selectedDays: selectedDays,
                  selectedStartDate: selectedStartDate,
                  selectedEndDate: selectedEndDate,
                ),
                SizedBox(height: 20),
                 Text(
                  "Tenant",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                IncidentTenant(
                  selectedDays: selectedDays,
                  selectedStartDate: selectedStartDate,
                  selectedEndDate: selectedEndDate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
