import 'package:flutter/material.dart';
import 'news_card.dart';
import 'news_service.dart'; 

class NewsList extends StatefulWidget {
  @override
  _NewsListState createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  @override
  void initState() {
    super.initState();
    NewsService.startNewsRefresh(); // ✅ เรียกใช้งานระบบรีเฟรชข่าว
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: NewsService.newsStream, // ✅ ดึงข่าวจาก Stream ของ NewsService
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No news available.'));
        }

        final newsList = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: newsList.length,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          itemBuilder: (context, index) {
            return NewsCard(news: newsList[index]);
          },
        );
      },
    );
  }
}
