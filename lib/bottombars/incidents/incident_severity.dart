import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentSeverity extends StatefulWidget {
  final int? selectedDays;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;

  const IncidentSeverity({
    Key? key,
    this.selectedDays,
    this.selectedStartDate,
    this.selectedEndDate,
  }) : super(key: key);

  @override
  _IncidentSeverityState createState() => _IncidentSeverityState();
}

class _IncidentSeverityState extends State<IncidentSeverity> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<double> count = [0, 0, 0, 0]; // ใช้ List แทน Map
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchIncidentSeverityData();
  }

  @override
  void didUpdateWidget(covariant IncidentSeverity oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDays != widget.selectedDays ||
        oldWidget.selectedStartDate != widget.selectedStartDate ||
        oldWidget.selectedEndDate != widget.selectedEndDate) {
      fetchIncidentSeverityData();
    }
  }

  Future<void> fetchIncidentSeverityData() async {
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

      // รีเซ็ตค่า count
      List<double> totalIncident = [0, 0, 0, 0];

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        totalIncident[0] += (data["low"] ?? 0).toDouble();
        totalIncident[1] += (data["medium"] ?? 0).toDouble();
        totalIncident[2] += (data["high"] ?? 0).toDouble();
        totalIncident[3] += (data["critical"] ?? 0).toDouble();
      }

      setState(() {
        count = totalIncident; // อัปเดตค่า count
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching incident summary: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Color getIncidentSeverityColor(String severity) {
    switch (severity) {
      case "Critical":
        return Colors.red;
      case "High":
        return Colors.orange;
      case "Medium":
        return Colors.lightBlueAccent.shade700;
      case "Low":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> severityLevels = ["Critical", "High", "Medium", "Low"];

    return SizedBox(
      height: 115,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: severityLevels.length,
              itemBuilder: (context, index) {
                String severity = severityLevels[index];

                return SizedBox(
                  width: MediaQuery.of(context).size.width / 3 - 8, // ปรับขนาดให้พอดี 3 ใบต่อจอ
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: getIncidentSeverityColor(severity),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          severity,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Severity",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${count[3 - index].toInt()}", // ใช้ count[index] ให้ตรงกับระดับความรุนแรง
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
