import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mdr_mobile/users/logo_widget_page.dart';
import 'package:mdr_mobile/users/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String selectedDomain = "@gmail.com";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> register() async {
    try {
      String fullEmail = emailController.text + selectedDomain;

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: fullEmail,
            password: passwordController.text,
          );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'userId': userCredential.user!.uid,
        'email': fullEmail,
        'username': userController.text,
        'address': addressController.text,
        'phone': phoneController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("สมัครสมาชิกสำเร็จ! กรุณาล็อกอิน")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade800,
                  Colors.deepPurple.shade400,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 60),
                    LogoWidget(),
                    SizedBox(height: 20),
                    Text(
                      'Complete the form',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    buildEmailField(),
                    buildTextField(userController, 'Fullname', Icons.person),
                    buildTextField(
                      passwordController,
                      'Password',
                      Icons.lock,
                      isPassword: true,
                    ),
                    buildTextField(
                      addressController,
                      'Address',
                      Icons.location_on,
                    ),
                    buildTextField(phoneController, 'Telephone', Icons.phone),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Create an account',
                        style: TextStyle(fontSize: 18, color: Colors.deepPurple),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Already have an account? Log in',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepPurple),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.email, color: Colors.deepPurple),
                ),
                Expanded(
                  child: TextField(
                    controller: emailController,
                    onChanged: (text) {
                      setState(() {}); // อัปเดต UI ถ้าผู้ใช้พิมพ์
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: emailController.text.isEmpty ? "Email" : "",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: selectedDomain,
                  dropdownColor: Colors.white,
                  style: TextStyle(color: Colors.black),
                  underline: SizedBox(),
                  items:
                      [
                        "@gmail.com",
                        "@hotmail.com",
                        "@yahoo.com",
                        "@outlook.com",
                        "@live.com",
                        "@protonmail.com",
                      ].map((String domain) {
                        return DropdownMenuItem<String>(
                          value: domain,
                          child: Text(
                            domain,
                            style: TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDomain = newValue!;
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.deepPurple),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(icon, color: Colors.deepPurple),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      obscureText: isPassword,
                      onChanged: (text) {
                        setState(() {}); // รีเฟรช UI เมื่อมีการพิมพ์
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: controller.text.isEmpty ? label : "",
                        hintStyle: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
