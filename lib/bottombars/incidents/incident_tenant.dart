import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentTenant extends StatefulWidget {
  final int? selectedDays;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;

  const IncidentTenant({
    Key? key,
    this.selectedDays,
    this.selectedStartDate,
    this.selectedEndDate,
  }) : super(key: key);

  @override
  _IncidentTenantState createState() => _IncidentTenantState();
}

class _IncidentTenantState extends State<IncidentTenant> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  Map<String, List<double>> incidentMap = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void didUpdateWidget(covariant IncidentTenant oldWidget) {
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

      Map<String, List<double>> tempMap = {};

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String location = data["location"] ?? "Unknown";
        int low = data["low"] ?? 0;
        int medium = data["medium"] ?? 0;
        int high = data["high"] ?? 0;
        int critical = data["critical"] ?? 0;

        if (!tempMap.containsKey(location)) {
          tempMap[location] = [0, 0, 0, 0];
        }

        tempMap[location]![0] += low.toDouble();
        tempMap[location]![1] += medium.toDouble();
        tempMap[location]![2] += high.toDouble();
        tempMap[location]![3] += critical.toDouble();
      }

      setState(() {
        incidentMap = tempMap;
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
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : incidentMap.isEmpty
            ? Center(child: Text("No data available", style: TextStyle(color: Colors.white)))
            : GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: incidentMap.length,
                itemBuilder: (context, index) {
                  String location = incidentMap.keys.elementAt(index);
                  List<double> values = incidentMap[location]!;
                  double totalSeverity = values.reduce((a, b) => a + b);
                  return _buildIncidentCard(location, values, totalSeverity);
                },
              );
  }

  Widget _buildIncidentCard(String location, List<double> values, double totalSeverity) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      color: Colors.teal.shade900,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Text(
    "$location Incident",
    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
  ),
),
            SizedBox(height: 60),
            Expanded(    
              child: AspectRatio(
                aspectRatio: 1.3, // ✅ กำหนดขนาดแน่นอนให้ BarChart
                child: BarChart(
                  BarChartData(
                    barGroups: _getBarGroups(values),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                     barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent, // ✅ เอาพื้นหลังตัวเลขออก
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              rod.toY.toInt().toString(),
              TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            );
          },
        ),
      ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                  child: Text(
                        "${totalSeverity.toInt()} Total Severity",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                        ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups(List<double> values) {
    List<Color> colors = [Colors.green, Colors.blueAccent, Colors.yellow, Colors.red];
    List<BarChartRodData> rods = [];

    for (int i = 0; i < values.length; i++) {
      if (values[i] > 0) {
        rods.add(BarChartRodData(
          toY: values[i],
          color: colors[i],
          width: 20,
          borderRadius: BorderRadius.zero,
        ));
      }
    }

    return [
      BarChartGroupData(
        x: 0,
        barRods: rods,
        showingTooltipIndicators: List.generate(rods.length, (i) => i),
        
      ),
    ];
  }
}
