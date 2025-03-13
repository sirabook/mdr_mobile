import 'dart:async';
import 'package:flutter/material.dart';
import 'news_service.dart'; // ดึงข่าวจาก NewsService
import 'news_detail.dart'; // นำเข้า NewsDetailScreen

class NewsHighlight extends StatefulWidget {
  @override
  _NewsHighlightState createState() => _NewsHighlightState();
}

class _NewsHighlightState extends State<NewsHighlight> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    NewsService.startNewsRefresh(); // เริ่มต้นการรีเฟรชข่าวทุก 5 นาที
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    super.dispose();
  }

  void _startAutoScroll(List<dynamic> newsList) {
    if (newsList.isEmpty) return;
    _scrollTimer?.cancel(); // เคลียร์ Timer เดิม
    _scrollTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        setState(() {
          _currentPage = (_currentPage + 1) % newsList.length; // วนลูปในข่าว
        });
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: NewsService.newsStream, // ฟังข่าวจาก Stream
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // กำลังโหลดข่าว
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // ถ้ามีข้อผิดพลาด
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No news available.')); // ถ้าไม่มีข่าว
        }

        final newsList = snapshot.data!;
        _startAutoScroll(newsList); // เริ่มต้นการเลื่อนข่าวอัตโนมัติ

        return SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            itemCount: newsList.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final news = newsList[index];
              return _buildNewsItem(news, context); // แสดงข่าวแต่ละอัน
            },
          ),
        );
      },
    );
  }

  Widget _buildNewsItem(dynamic news, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // เมื่อกดที่ข่าวให้ไปหน้ารายละเอียด
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(news: news),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Image.network(
                news['img'] ?? '',
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey,
                  alignment: Alignment.center,
                  child: Icon(Icons.image, size: 100, color: Colors.white),
                ),
              ),
              Positioned(
                left: 0,
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    news['name'] ?? 'No Title',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2, // Ensures the text is confined to two lines
                    overflow: TextOverflow.ellipsis, // Adds ellipsis if text overflows
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
