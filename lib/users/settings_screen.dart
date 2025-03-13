import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mdr_mobile/users/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final String userId;

  SettingsScreen({required this.userId});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();

  bool isLoading = true;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      if (currentUser == null || currentUser!.uid != widget.userId) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("User data not found")));
        return;
      }

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .get();

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          emailController.text = currentUser?.email ?? data["email"] ?? "";
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> updateProfile() async {
    try {
      if (currentUser == null) return;

      // 🔹 เช็คว่าผู้ใช้ต้องการเปลี่ยนรหัสผ่านหรือไม่
      if (passwordController.text.isNotEmpty) {
        if (oldPasswordController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Please enter your current password before changing the password."),
            ),
          );
          return;
        }

        // 🔹 ทำ Re-authenticate ก่อนเปลี่ยนรหัสผ่าน
        AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser!.email!,
          password: oldPasswordController.text,
        );

        try {
          await currentUser!.reauthenticateWithCredential(credential);
          await currentUser!.updatePassword(passwordController.text);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Password Changed Successfully")));
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Current Password is Incorrect")));
          return;
        }
      }

      // 🔹 อัปเดตข้อมูล Firestore
     

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Data Saved Successfully")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> deleteProfile() async {
    try {
      if (currentUser == null) return;

      // ✅ ขอให้ผู้ใช้ป้อนรหัสผ่านก่อนลบ
      String? password = await promptForPassword();
      if (password == null || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password")),
        );
        return;
      }

      // ✅ ทำ Re-authenticate
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: password,
      );

      await currentUser!.reauthenticateWithCredential(credential);
      await FirebaseAuth.instance.currentUser?.reload();

      // ✅ ลบข้อมูลใน Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .delete();

      // ✅ ลบจาก Firebase Authentication
      await currentUser!.delete();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Account Deleted Successfully.")));

      // ✅ ล้าง SharedPreferences และนำผู้ใช้ไปที่หน้า Login
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<String?> promptForPassword() async {
    String password = "";
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Password"),
          content: TextField(
            obscureText: true,
            onChanged: (value) {
              password = value;
            },
            decoration: InputDecoration(labelText: "Password"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, password),
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.blueAccent,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    buildTextField("Email", emailController, enabled: false),
                    buildTextField(
                      "Password",
                      oldPasswordController,
                      obscureText: true,
                    ),
                    buildTextField(
                      "New Password",
                      passwordController,
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: deleteProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Delete Account",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
