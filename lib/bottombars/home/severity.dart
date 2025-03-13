import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Severity extends StatefulWidget {
  final int? selectedDays;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;

  const Severity({
    Key? key,
    this.selectedDays,
    this.selectedStartDate,
    this.selectedEndDate,
  }) : super(key: key);

  @override
  _SeverityState createState() => _SeverityState();
}

class _SeverityState extends State<Severity> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, Map<String, dynamic>> severityData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSeverityData();
  }

  @override
  void didUpdateWidget(covariant Severity oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDays != widget.selectedDays ||
        oldWidget.selectedStartDate != widget.selectedStartDate ||
        oldWidget.selectedEndDate != widget.selectedEndDate) {
      fetchSeverityData();
    }
  }

  Future<void> fetchSeverityData() async {
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
          .collection('severity')
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .get();

      Map<String, Map<String, dynamic>> updatedData = {
        "Critical": {"count": 0, "blocked": 0, "detected": 0},
        "High": {"count": 0, "blocked": 0, "detected": 0},
        "Medium": {"count": 0, "blocked": 0, "detected": 0},
        "Low": {"count": 0, "blocked": 0, "detected": 0},
      };

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String severity = data["severity"] ?? "Unknown";

        if (updatedData.containsKey(severity)) {
          updatedData[severity]!["count"] += data["count"] ?? 0;
          updatedData[severity]!["blocked"] += data["blocked"] ?? 0;
          updatedData[severity]!["detected"] += data["detected"] ?? 0;
        }
      }

      setState(() {
        severityData = updatedData;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching severity data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Color getSeverityColor(String severity) {
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
      height: 180,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: severityLevels.length,
              itemBuilder: (context, index) {
                String severity = severityLevels[index];
                var item = severityData[severity] ?? {"count": 0, "blocked": 0, "detected": 0};

                return SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 16, // ปรับขนาดให้พอดี 2 ใบต่อจอ
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: getSeverityColor(severity),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "$severity Severity",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${item["count"]}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildInfoBox("Blocked", item["blocked"]),
                        const SizedBox(height: 5),
                        _buildInfoBox("Detected", item["detected"]),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoBox(String label, int value) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "$label : $value",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
  );
}

}
