import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/pages/sign_up.dart';
import 'package:task_manager/features/task/presentation/pages/task_list_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  static const routeName = '/sign-in';
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    context.read<AuthBloc>().add(SignInEvent(email: email, password: password));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In'), centerTitle: true),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.failure.message)));
          }
          if (state is Authenticated) {
            context.pushReplacement(TaskListPage.routeName);
          }
        },
        builder: (context, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 24.0,

            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  key: Key('emailField'),
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  key: Key('passwordField'),
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ),
              state is AuthLoading
                  ? const CircularProgressIndicator(
                    key: Key('loadingIndicator'),
                  )
                  : ElevatedButton(
                    key: Key('continueButton'),
                    onPressed: () {
                      _login();
                    },
                    child: Text('Continue'),
                  ),
              Row(
                children: <Widget>[
                  const Expanded(child: Divider(thickness: 1)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("Or"),
                  ),
                  const Expanded(child: Divider(thickness: 1)),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  context.push(SignUpPage.routeName);
                },
                child: Text('Sign Up'),
              ),
            ],
          );
        },
      ),
    );
  }
}
