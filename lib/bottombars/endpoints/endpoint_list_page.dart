import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
class EndpointListPage extends StatefulWidget {
  @override
  _EndpointListPageState createState() => _EndpointListPageState();
}

class _EndpointListPageState extends State<EndpointListPage> {
  int selectedEntries = 25;
  String searchQuery = "";
  bool isEndpointInfo = true;
  bool isAscending = true;
  Map<String, bool> expandedMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildTabMenu(),
          _buildControlPanel(),
          Expanded(child: _buildEndpointList()),
        ],
      ),
    );
  }

  Widget _buildTabMenu() {
    return Row(
      children: [
        _buildTabButton("Endpoint Info", true),
        _buildTabButton("Endpoint Action", false),
      ],
    );
  }

  Widget _buildTabButton(String title, bool isInfoTab) {
    bool isSelected = isEndpointInfo == isInfoTab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isEndpointInfo = isInfoTab),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green[800] : Colors.grey[300],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isInfoTab ? 20 : 0),
              topRight: Radius.circular(!isInfoTab ? 20 : 0),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      color: Colors.green[800],
      padding: EdgeInsets.all(8),
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
            onChanged: (value) => setState(() => selectedEntries = value!),
          ),
          IconButton(
            icon: Icon(isAscending ? Icons.arrow_drop_down : Icons.arrow_drop_up, color: Colors.white),
            onPressed: () => setState(() => isAscending = !isAscending),
          ),
          Spacer(),
          Text("Search:", style: TextStyle(color: Colors.white)),
          SizedBox(width: 8),
          Expanded(child: _buildSearchBox()),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return TextField(
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
      ),
      onChanged: (value) => setState(() => searchQuery = value),
    );
  }

  Widget _buildEndpointList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('endpoints').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var filteredData = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          String id = data['id'].toString();
          String name = data['name'].toLowerCase();
          return id.contains(searchQuery) || name.contains(searchQuery.toLowerCase());
        }).toList();

        filteredData.sort((a, b) {
          var idA = (a.data() as Map<String, dynamic>)['id'];
          var idB = (b.data() as Map<String, dynamic>)['id'];
          return isAscending ? idA.compareTo(idB) : idB.compareTo(idA);
        });

        return Container(
          color: Colors.green[800],
          child: ListView.builder(
            itemCount: filteredData.length.clamp(0, selectedEntries),
            itemBuilder: (context, index) {
              var data = filteredData[index].data() as Map<String, dynamic>;
              return _buildEndpointCard(data);
            },
          ),
        );
      },
    );
  }

    Widget _buildEndpointCard(Map<String, dynamic> data) {
  String endpointId = data['id'] ?? "unknown";
  bool isExpanded = expandedMap[endpointId] ?? false;

  return Card(
    color: Colors.white,
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Column(
      children: [
        ListTile(
          leading: IconButton(
            icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onPressed: () => setState(() => expandedMap[endpointId] = !isExpanded),
          ),
          title: isExpanded 
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ID: ${data['id']}", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Endpoint Name: ${data['name']}", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            : Text(
                "ID: ${data['id']}  Endpoint Name: ${data['name']}",
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: isEndpointInfo ? _buildEndpointInfoDetails(data) : _buildEndpointActionDetails(data),
          ),
      ],
    ),
  );
}
String _formatTimestamp(dynamic timestamp) {
  if (timestamp is Timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }
  return "Unknown";
}

  Widget _buildEndpointInfoDetails(Map<String, dynamic> data) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start, 
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text("Endpoint Type: ${data['type'] ?? 'Unknown'}"),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: Text("Operating System: ${data['os'] ?? 'Unknown'}"),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: Text("Endpoint Status: ${data['status'] ?? 'Unknown'}"),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: Text("Last Seen: ${_formatTimestamp(data['last_seen'])}"),
      ),
    ],
  );
}


  Widget _buildEndpointActionDetails(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Endpoint Status: ${data['status'] ?? 'Unknown'}"),
        Row(
          children: [
            Text("Isolate Status: "),
            Switch(
              value: data['isolate_status'] ?? false,
              onChanged: (value) {
                setState(() {
                  data['isolate_status'] = value;
                });
              },
            ),
             Text((data['isolate_status'] ?? false) ? "Isolated" : "Unisolated"),
          ],
        ),
        Text("Scan Status: ${data['scan_status'] ?? 'Unknown'}"),
         Text("Last Seen: ${_formatTimestamp(data['last_seen'])}"),
      ],
    );
  }

}
