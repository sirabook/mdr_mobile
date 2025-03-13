import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pie_chart/pie_chart.dart';

class Summary extends StatelessWidget {
  final int? selectedDays;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Summary({Key? key, this.selectedDays, this.selectedStartDate, this.selectedEndDate}) : super(key: key);

  Future<Map<String, int>> fetchSummaryActions() async {
    int totalBlocked = 0;
    int totalDetected = 0;
    int criticalCount = 0;
    int highCount = 0;
    int mediumCount = 0;
    int lowCount = 0;

    try {
      DateTime? startDate = selectedStartDate;
      DateTime? endDate = selectedEndDate;

      if (startDate == null && selectedDays != null) {
        startDate = DateTime.now().subtract(Duration(days: selectedDays!));
        endDate = DateTime.now();
      }

      if (startDate == null || endDate == null) return {};

      Timestamp startTimestamp = Timestamp.fromDate(startDate);
      Timestamp endTimestamp = Timestamp.fromDate(endDate);

      QuerySnapshot severitySnapshot = await _firestore
          .collection('severity')
          .where('date', isGreaterThanOrEqualTo: startTimestamp)
          .where('date', isLessThanOrEqualTo: endTimestamp)
          .get();

      for (var doc in severitySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        totalBlocked += _parseInt(data["blocked"]);
        totalDetected += _parseInt(data["detected"]);

        String severityLevel = data["severity"] ?? "";
        int count = _parseInt(data["count"]);

        if (severityLevel == "Critical") {
          criticalCount += count;
        } else if (severityLevel == "High") {
          highCount += count;
        } else if (severityLevel == "Medium") {
          mediumCount += count;
        } else if (severityLevel == "Low") {
          lowCount += count;
        }
      }
    } catch (e) {
      print("❌ Error fetching summary actions: $e");
    }

    return {
      "blocked": totalBlocked,
      "detected": totalDetected,
      "critical": criticalCount,
      "high": highCount,
      "medium": mediumCount,
      "low": lowCount,
    };
  }

  int _parseInt(dynamic value) {
    return int.tryParse(value?.toString() ?? "0") ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: fetchSummaryActions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("❌ Error loading data"));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("⚠️ No data available"));
        }

        var data = snapshot.data!;
        int blocked = data["blocked"]!;
        int detected = data["detected"]!;
        int critical = data["critical"]!;
        int high = data["high"]!;
        int medium = data["medium"]!;
        int low = data["low"]!;

        Map<String, double> actionChartData = {
          "Blocked": blocked.toDouble(),
          "Detected": detected.toDouble(),
        };

        Map<String, double> incidentChartData = {
          "Critical": critical.toDouble(),
          "High": high.toDouble(),
          "Medium": medium.toDouble(),
          "Low": low.toDouble(),
        };

        return Column(
          children: [
            _buildSummaryActionsCard("SUMMARY ACTIONS", blocked, detected, actionChartData),
            _buildSummaryCard(
                "SUMMARY INCIDENT", critical + high + medium + low, incidentChartData, [Colors.red, Colors.orange, Colors.lightBlueAccent.shade700, Colors.green]),
          ],
        );
      },
    );
  }

  Widget _buildSummaryActionsCard(String title, int blocked, int detected, Map<String, double> chartData) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text("Blocked: $blocked", style: const TextStyle(fontSize: 14, color: Colors.black)),
                  Text("Detected: $detected", style: const TextStyle(fontSize: 14, color: Colors.black)),
                ],
              ),
            ),
            SizedBox(
              width: 80,
              height: 80,
              child: PieChart(
                dataMap: chartData,
                chartType: ChartType.ring,
                baseChartColor: Colors.grey[200]!,
                colorList: [Colors.red, Colors.green],
                chartValuesOptions: const ChartValuesOptions(
                  showChartValues: false,
                ),
                legendOptions: const LegendOptions(showLegends: false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, int totalValue, Map<String, double> chartData, List<Color> colors) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text("Total : $totalValue", style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            SizedBox(
              width: 80,
              height: 80,
              child: PieChart(
                dataMap: chartData,
                chartType: ChartType.ring,
                baseChartColor: Colors.grey[200]!,
                colorList: colors,
                chartValuesOptions: const ChartValuesOptions(
                  showChartValues: false,
                ),
                legendOptions: const LegendOptions(showLegends: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
