import 'package:flutter/material.dart';
import 'package:mdr_mobile/bottombars/endpoints/endpoint_page.dart';
import 'package:mdr_mobile/bottombars/incidents/incident_page.dart';
import 'package:mdr_mobile/bottombars/home/home_page.dart';
import 'package:mdr_mobile/bottombars/news/news_page.dart';
import 'package:mdr_mobile/drawers/drawers.dart';
import 'package:mdr_mobile/appbars/app_bars.dart';
import 'package:mdr_mobile/bottombars/bottom_bars.dart';

class HomeMainScreen extends StatelessWidget {
  final String userId;
  const HomeMainScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MyHomePage(userId: userId));
  }
}

class MyHomePage extends StatefulWidget {
  final String userId;
  const MyHomePage({super.key,required this.userId});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int notificationCount = 7;
  int _selectedIndex = 0;
  List<String> notifications = [
    "New message from Admin",
    "System update available",
    "Incident report submitted",
    "New article published",
    "Meeting reminder at 3 PM",
    "Password change required",
    "Survey response needed",
  ];
  final List<Widget> _pages = [
    HomePage(),
    IncidentPage(),
    EndpointPage(),
    NewsPage(),
  ];

  void _onNavItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
   void _showNotificationsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Notifications",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              if (notifications.isEmpty)
                Text(
                  "No new notifications",
                  style: TextStyle(color: Colors.grey),
                ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.notifications, color: Colors.blue),
                      title: Text(notifications[index]),
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    notifications.clear();
                    notificationCount = 0;
                  });
                  Navigator.pop(context);
                },
                child: Text("Clear All", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
   

    // 🛠 กำหนดค่า title และ menuItems ตามหน้า
    String title;
    List<String> menuItems;

    switch (_selectedIndex) {
      case 0:
        title = "Home";
        menuItems = ["Dashboard", "Endpoint"];
        break;
      case 1:
        title = "Incident";
        menuItems = ["Tenant"];
        break;
      case 2:
        title = "Endpoint";
        menuItems = ["Incidents"];
        break;
      case 3:
        title = "News";
        menuItems = ["Threat Intelligence", "Cyber Security"];
        break;
      default:
        title = "Menu";
        menuItems = [];
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBars(
        notificationCount: notificationCount,
        onNotificationTap: _showNotificationsBottomSheet,
        scaffoldKey: _scaffoldKey,
        userId: widget.userId,
      ),
      drawer: Align(
        alignment: Alignment.topLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
          width: screenWidth / 2,
          
          
          child: Drawers(title: title, menuItems: menuItems), // ส่งค่าไป Drawers
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomBars(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavItemSelected,
      ),
    );
  }
}
