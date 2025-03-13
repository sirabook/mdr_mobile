import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentSummary extends StatefulWidget {
  final int? selectedDays;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;

  const IncidentSummary({
    Key? key,
    this.selectedDays,
    this.selectedStartDate,
    this.selectedEndDate,
  }) : super(key: key);

  @override
  _IncidentSummaryState createState() => _IncidentSummaryState();
}

class _IncidentSummaryState extends State<IncidentSummary> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  List<List<double>> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void didUpdateWidget(covariant IncidentSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDays != widget.selectedDays ||
        oldWidget.selectedStartDate != widget.selectedStartDate ||
        oldWidget.selectedEndDate != widget.selectedEndDate) {
      fetchData();
    }
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      DateTime startDate;
      DateTime endDate = DateTime.now();

      if (widget.selectedStartDate != null && widget.selectedEndDate != null) {
        startDate = widget.selectedStartDate!;
        endDate = widget.selectedEndDate!;
      } else if (widget.selectedDays != null) {
        startDate = DateTime.now().subtract(Duration(days: widget.selectedDays!));
      } else {
        return;
      }

      QuerySnapshot snapshot = await _firestore
          .collection('incident')
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .get();

      Map<String, List<double>> incidentMap = {
        "Ratchaburi": [0, 0, 0, 0],
        "Chonburi": [0, 0, 0, 0],
        "Neurological Institute": [0, 0, 0, 0],
        "Maharat Nakhon": [0, 0, 0, 0],
        "Hat Yai": [0, 0, 0, 0],
      };

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String location = data["location"] ?? "Unknown";
        int low = data["low"] ?? 0;
        int medium = data["medium"] ?? 0;
        int high = data["high"] ?? 0;
        int critical = data["critical"] ?? 0;

        if (incidentMap.containsKey(location)) {
  incidentMap[location]![0] += low.toDouble();
  incidentMap[location]![1] += medium.toDouble();
  incidentMap[location]![2] += high.toDouble();
  incidentMap[location]![3] += critical.toDouble();
}

      }

      setState(() {
        data = incidentMap.values.toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching incident summary: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             SizedBox(height: 55),
            SizedBox(height: 220, child: isLoading ? Center(child: CircularProgressIndicator()) : _buildChart()),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    return BarChart(
      BarChartData(
        barGroups: _getBarGroups(),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                List<String> locations = [
                  "Ratchaburi",
                  "Chonburi",
                  "Neurological\nInstitute",
                  "Maharat \nNakhon",
                  "Hat Yai"
                ];
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    locations[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.transparent,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toInt().toString(),
                const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              );
            },
          ),
          handleBuiltInTouches: true,
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    List<Color> colors = [Colors.green, Colors.blueAccent, Colors.orange, Colors.red];

    return List.generate(data.length, (index) {
      // ✅ กรองค่าที่เป็น 0 ออกจากแท่งกราฟ
      List<BarChartRodData> rods = [];
      for (int i = 0; i < data[index].length; i++) {
        if (data[index][i] > 0) {
          rods.add(BarChartRodData(
            toY: data[index][i],
            color: colors[i],
            width: 10,
            borderRadius: BorderRadius.zero,
          ));
        }
      }

      if (rods.isEmpty) return null; // ✅ ถ้าทุกค่าเป็น 0 ให้ข้ามไปเลย

      return BarChartGroupData(
        x: index,
        barRods: rods,
        showingTooltipIndicators: List.generate(rods.length, (i) => i),
        barsSpace: 8,
      );
    }).whereType<BarChartGroupData>().toList(); // ✅ ลบค่าที่เป็น `null`
  }
}
