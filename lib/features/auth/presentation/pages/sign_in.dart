import 'package:flutter/material.dart';

class SignIn extends StatelessWidget {
  
  const SignIn({super.key});
  static const routeName = '/sign-in';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In'), centerTitle: true),
      body: Center(child: Text('Sign In')),
    );
  }
}
