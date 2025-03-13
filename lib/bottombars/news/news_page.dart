import 'package:flutter/material.dart';
import 'news_highlight.dart';
import 'news_list.dart';

class NewsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CyberSecurityNewsPage(),
    );
  }
}

class CyberSecurityNewsPage extends StatefulWidget {
  @override
  _CyberSecurityNewsPageState createState() => _CyberSecurityNewsPageState();
}

class _CyberSecurityNewsPageState extends State<CyberSecurityNewsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
           decoration: BoxDecoration(
          color:  Color.fromARGB(255, 255, 240, 199), // 
           ),
          child: Column(
            children: [
              NewsHighlight(), // ✅ ส่วนของข่าวเด่น
              Text(
            "Cyber Security News",
            style: TextStyle(color: Colors.black,fontSize: 25,fontWeight:FontWeight.bold),
          ),
              NewsList(), // ✅ รายการข่าว
            ],
          ),
        ),
      ),
    );
  }
}
 