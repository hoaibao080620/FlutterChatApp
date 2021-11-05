import 'package:chatapp/services/auth.dart';
import 'package:chatapp/widget/widget.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailEditingController = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  AuthService authService = new AuthService();
  resetPassword() async {
      if(formKey.currentState.validate()) {
        await authService
            .resetPass(emailEditingController.text)
            .then((value) => Navigator.of(context).pop());
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    style: simpleTextStyle(),
                    controller: emailEditingController,
                    validator: (val) {
                      return RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(val)
                          ? null
                          : "Enter correct email";
                    },
                    decoration: textFieldInputDecoration("email"),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                resetPassword();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xff007EF4),
                        const Color(0xff2A75BC)
                      ],
                    )),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "Reset password",
                  style: biggerTextStyle(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),

          ],
        ),
      ),
    );
  }
}
