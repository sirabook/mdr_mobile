import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EndpointStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('endpoints').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var total = snapshot.data!.docs.length;
        var connected = snapshot.data!.docs.where((doc) => (doc.data() as Map<String, dynamic>?)?['status'] == 'Connected').length;
        var disconnected = snapshot.data!.docs.where((doc) => (doc.data() as Map<String, dynamic>?)?['status'] == 'Disconnected').length;
        var unknown = total - (connected + disconnected);

        List<Widget> statusCards = [
          _buildStatusCard(context, "Total", total, Colors.blue),
          _buildStatusCard(context, "Connected", connected, Colors.green),
          _buildStatusCard(context, "Disconnected", disconnected, Colors.grey),
          _buildStatusCard(context, "Unknown", unknown, Colors.orange),
        ];

        return SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: statusCards,
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(BuildContext context, String title, int count, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width / 3 - 16,
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$count",
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
