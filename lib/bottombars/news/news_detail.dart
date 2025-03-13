import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailScreen extends StatelessWidget {
  final Map<String, dynamic> news;

  NewsDetailScreen({required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(news['name'] ?? 'News Detail'),
        backgroundColor:Color.fromARGB(255, 255, 240, 199), 
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
           decoration: BoxDecoration(
          color:  Color.fromARGB(255, 255, 240, 199),
           ),
          child: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20),
           ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (news['img'] != null && news['img'].isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      news['img'],
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image, size: 100),
                    ),
                  ),
                SizedBox(height: 10),
                _buildTitle(news['name'] ?? 'No Title'),
                _buildSubInfo('🗓 Date', news['NewsDate']),
                _buildSubInfo('👤 Reported By', news['user']),
                _buildSubInfo('🛑 CVE', news['CVE']),
                if (news['Product'] != null &&
                    news['Product'].toString().replaceAll(RegExp(r'\[|\]'), '').isNotEmpty)
                  _buildSubInfo('🛒 Affected Product', news['Product']),
                _buildSubInfo('✅ Recommendation', news['Recommendation']),
                _buildDescription(news['detail1']),
                _buildDescription(news['detail2']),
                _buildDescription(news['detail3']),
                if (news['ref'] != null && news['ref'] is String)
                  _buildReferencesSection(news['ref']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF134E41)),
    );
  }

Widget _buildSubInfo(String title, dynamic data) {
  if (data == null || data.toString().trim().isEmpty) return SizedBox.shrink();
  String cleanedData = data.toString()
      .replaceAll(RegExp(r'\[|\]'), '') // ลบ []
      .replaceAll(RegExp(r'\(|\)'), '') // ลบ []
      .replaceAll(RegExp(r'\s*\n\s*'), ' ') // ลบ \n ที่เกิน
      .trim();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 5),
      Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF134E41)),
      ),
      Text(
        cleanedData,
        style: TextStyle(fontSize: 16, color: Colors.black87),
      ),
    ],
  );
}



  Widget _buildDescription(String? text) {
  if (text == null || text.trim().isEmpty) return SizedBox.shrink();
  String cleanedText = text.replaceAll(RegExp(r'\s*\n\s*'), ' ').trim();

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      cleanedText,
      style: TextStyle(fontSize: 16, color: Colors.black87),
    ),
  );
}


  Widget _buildReferencesSection(String references) {
    List<String> refLinks = references
        .split("\n")
        .map((e) => e.replaceAll(RegExp(r'^[-\t\s]+'), '').trim())
        .where((e) => e.isNotEmpty)
        .toList();

    List<String> validLinks = refLinks.where((link) {
      Uri? uri = Uri.tryParse(link);
      return uri != null && uri.hasAbsolutePath;
    }).toList();

    if (validLinks.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(
          '🔗 References',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF134E41)),
        ),
        ...validLinks.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: GestureDetector(
              onTap: () async {
                Uri url = Uri.parse(Uri.encodeFull(link));
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: Text(
                link,
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
