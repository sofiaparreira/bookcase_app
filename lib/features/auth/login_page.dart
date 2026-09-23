import 'package:bookcase/shared/widgets/text_field/text_field_default.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    return Scaffold(
      body: Column(
        children: [
          TextFieldDefault(
            label: 'E-mail',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }
}
