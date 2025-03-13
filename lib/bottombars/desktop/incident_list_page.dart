import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 📌 ใช้จัดรูปแบบวันที่

class IncidentListPage extends StatefulWidget {
  final int? selectedDays;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;

  const IncidentListPage({
    Key? key,
    this.selectedDays,
    this.selectedStartDate,
    this.selectedEndDate,
  }) : super(key: key);

  @override
  _IncidentListPageState createState() => _IncidentListPageState();
}

class _IncidentListPageState extends State<IncidentListPage> {
  int selectedEntries = 25;
  String searchQuery = "";
  int selectedFilter = 0; // 0 = All, 1 = XDR Agent, 2 = PAN NGFW
  Map<String, bool> expandedMap = {}; // สถานะขยาย/ย่อของรายการ
  late Stream<QuerySnapshot> _incidentStream;

  @override
  void initState() {
    super.initState();
    _incidentStream = FirebaseFirestore.instance.collection('generated').snapshots();
  }
  
  List<QueryDocumentSnapshot> _filterIncidents(List<QueryDocumentSnapshot> incidents) {
    DateTime now = DateTime.now();
    DateTime startDate;

    if (widget.selectedStartDate != null && widget.selectedEndDate != null) {
      startDate = widget.selectedStartDate!;
    } else if (widget.selectedDays != null) {
      startDate = now.subtract(Duration(days: widget.selectedDays!));
    } else {
      startDate = now.subtract(Duration(days: 7));
    }

    return incidents.where((doc) {
      var data = doc.data() as Map<String, dynamic>;

      // 🔹 ตรวจสอบช่วงเวลา
      DateTime incidentDate = (data['date'] as Timestamp).toDate();
      if (incidentDate.isBefore(startDate) || incidentDate.isAfter(now)) {
        return false;
      }

      // 🔹 ตรวจสอบประเภทของ incident
      if (selectedFilter == 1 && data['source'] != 'XDR Agent') return false;
      if (selectedFilter == 2 && data['source'] != 'PAN NGFW') return false;

      // 🔹 ตรวจสอบการค้นหา
      String name = data["name"] ?? "";
      String id = data["id"] ?? "";
      return name.toLowerCase().contains(searchQuery.toLowerCase()) || id.contains(searchQuery);
    }).take(selectedEntries).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 🔹 ปุ่มกรองข้อมูล
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterButton("All Incident", 0),
                SizedBox(width: 4),
                _buildFilterButton("Generated XDR Agent", 1),
                SizedBox(width: 4),
                _buildFilterButton("Generated PAN NGFW", 2),
              ],
            ),
          ),

          // 🔹 ควบคุมจำนวนและค้นหา
          Container(
            color: Colors.green[900],
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text("Show", style: TextStyle(color: Colors.white)),
                SizedBox(width: 8),
                DropdownButton<int>(
                  value: selectedEntries,
                  dropdownColor: Colors.green[700],
                  style: TextStyle(color: Colors.white),
                  items: [25, 50, 100].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text("$value"),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedEntries = value!;
                    });
                  },
                ),
                SizedBox(width: 16),
                Icon(Icons.sort, color: Colors.white),
                Spacer(),
                Text("Search:", style: TextStyle(color: Colors.white)),
                SizedBox(width: 8),
                Expanded(child: _buildSearchBox()),
              ],
            ),
          ),

          // 🔹 รายการเหตุการณ์
          Expanded(
            child: Container(
              color: Colors.green[900],
              child: StreamBuilder<QuerySnapshot>(
                stream: _incidentStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No incidents found",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    );
                  }

                  List<QueryDocumentSnapshot> filteredIncidents = _filterIncidents(snapshot.data!.docs);

                  return ListView.builder(
                    key: ValueKey(selectedFilter),
                    itemCount: filteredIncidents.length,
                    itemBuilder: (context, index) {
                      var data = filteredIncidents[index].data() as Map<String, dynamic>;
                      return _buildIncidentCard(data);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 ปุ่มกรองข้อมูล
  Widget _buildFilterButton(String title, int filterValue) {
    return Expanded(
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              selectedFilter = filterValue;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedFilter == filterValue ? Colors.green[900] : Colors.white,
            foregroundColor: selectedFilter == filterValue ? Colors.white : Colors.green[900],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }

  /// 🔹 ช่องค้นหา
  Widget _buildSearchBox() {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.grey),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
    );
  }

  /// 🔹 การ์ดรายการเหตุการณ์
  Widget _buildIncidentCard(Map<String, dynamic> data) {
    String incidentId = data['id'] ?? "unknown";
    bool isExpanded = expandedMap[incidentId] ?? false;

    // 📌 แปลง Timestamp เป็น DateTime และจัดรูปแบบเวลา
    DateTime? incidentDate;
    if (data['date'] is Timestamp) {
      incidentDate = (data['date'] as Timestamp).toDate();
    }
    String formattedDate = incidentDate != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(incidentDate)
        : "N/A";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            ListTile(
              leading: IconButton(
                icon: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey[700],
                ),
                onPressed: () {
                  setState(() {
                    expandedMap[incidentId] = !isExpanded;
                  });
                },
              ),
              title: Text("ID : $incidentId"),
              subtitle: Text("Name : ${data['name']}"),
            ),
            if (isExpanded) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Source: ${data['source'] ?? 'N/A'}"),
                    Text("Severity: ${data['severity'] ?? 'N/A'}"),
                    Text("Date: $formattedDate"),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
