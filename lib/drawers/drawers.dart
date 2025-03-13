import 'package:flutter/material.dart';

class Drawers extends StatelessWidget {
  final String title; // ชื่อของหน้า
  final List<String> menuItems; // รายการเมนูที่ส่งเข้ามา

  const Drawers({super.key, required this.title, required this.menuItems});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft, // ให้ Drawer อยู่มุมซ้าย
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(30), // มุมบนขวาโค้ง
          bottomRight: Radius.circular(30), // มุมล่างขวาโค้ง
        ),
        child: Container(
          width: MediaQuery.of(context).size.width / 2.5, // กำหนดความกว้าง
          color: Colors.lightGreen, // สีพื้นหลัง
          padding: const EdgeInsets.symmetric(vertical: 20), // เพิ่มระยะห่างด้านใน
          child: Column(
            mainAxisSize: MainAxisSize.min, // ให้ขนาดพอดีกับเนื้อหา
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ปุ่มแสดงชื่อหน้า
              Padding(
                
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      title, // เปลี่ยนเป็นชื่อหน้าที่ส่งมา
                      maxLines: 1, // จำกัด 1 บรรทัด
                      overflow: TextOverflow.ellipsis, // ถ้ายาวเกิน ตัดเป็น ...
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

               SizedBox(height: 20), // ระยะห่าง

              // สร้างเมนูจาก List ที่ส่งมา
              ...menuItems.map((item) => Column(
                    children: [
                      const Divider(color: Colors.black54, thickness: 1, indent: 16, endIndent: 16),
                      ListTile(
                        title: Text(
                          item,
                          // maxLines: 1, 
                          // overflow: TextOverflow.ellipsis,
                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        
                        onTap: () {},
                      ),
                    ],
                  )),

              // ปุ่มย้อนกลับมุมล่างขวา
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton(
                    mini: true, // ทำให้ปุ่มเล็กลง
                    backgroundColor: Colors.green.shade800,
                    onPressed: () {
                      Navigator.pop(context); // ปิด Drawer
                    },
                    child: const Icon(Icons.arrow_back, color: Colors.white),
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
