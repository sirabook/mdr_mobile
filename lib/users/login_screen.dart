import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mdr_mobile/home_main_screen.dart';
import 'package:mdr_mobile/users/forget_password.dart';
import 'package:mdr_mobile/users/logo_widget_page.dart';
import 'package:mdr_mobile/users/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String selectedDomain = "@gmail.com";
  bool isLoading = false;
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    checkPreviousLogin();
  }

  Future<void> checkPreviousLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedIP = prefs.getString('user_ip');
    String currentIP = await getDeviceIP();

    if (savedIP == currentIP) {
      String? userId = prefs.getString('user_id');
      if (userId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeMainScreen(userId: userId),
          ),
        );
      }
    }
  }

  Future<String> getDeviceIP() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4) {
          return addr.address;
        }
      }
    }
    return "UNKNOWN";
  }

  Future<void> login() async {
    String email = usernameController.text.trim() + selectedDomain;
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("กรุณากรอกอีเมลและรหัสผ่าน")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        String currentIP = await getDeviceIP();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_ip', currentIP);
        await prefs.setString('user_id', userCredential.user!.uid);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => HomeMainScreen(userId: userCredential.user!.uid),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("เกิดข้อผิดพลาดในการเข้าสู่ระบบ")),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง";
      if (e.code == 'user-not-found') {
        errorMessage = "ไม่พบผู้ใช้นี้";
      } else if (e.code == 'wrong-password') {
        errorMessage = "รหัสผ่านไม่ถูกต้อง";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0E4D42), Color(0xFFF7E6CF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Container(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LogoWidget(),
                        Container(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.white70)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: usernameController,
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    labelStyle: TextStyle(color: Colors.white70),
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              DropdownButton<String>(
                                value: selectedDomain,
                                dropdownColor: Colors.black54,
                                style: TextStyle(color: Colors.white),
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
                                          style: TextStyle(color: Colors.white),
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
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ForgetPassword(),
                                  ),
                                ),
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: isLoading ? null : login,
                          child:
                              isLoading
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text("Sign In"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF5A7262),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 15,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterScreen(),
                                ),
                              ),
                          child: Text(
                            "Don't have an account? Sign up.",
                            style: TextStyle(
                              color:  Colors.blueAccent,fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}