import 'package:flutter/material.dart';
import 'package:mdr_mobile/bottombars/endpoints/endpoint_list_page.dart';
import 'package:mdr_mobile/bottombars/endpoints/endpoint_status.dart';


class EndpointPage extends StatefulWidget {
  const EndpointPage({Key? key}) : super(key: key);

  @override
  _EndpointPageState createState() => _EndpointPageState();
}

class _EndpointPageState extends State<EndpointPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 240, 199),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Endpoint",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          EndpointStatus(),
          SizedBox(height: 20),
          
          Expanded(
            child: EndpointListPage(),
          ),

        ],
      ),
    );
  }
}
