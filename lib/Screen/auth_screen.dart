import 'package:construction_app/Screen/home_screen.dart';
import 'package:construction_app/Screen/user_screen.dart';
import 'package:flutter/material.dart';
import '../Componets/widgets/circular_widget.dart';
import '../Componets/widgets/custom_textFeld.dart';
import '../Componets/widgets/custom_button.dart';
import '../Providers/auth.dart';
import 'package:construction_app/utils/theme_provider.dart';

enum AuthMode { signup, signin }

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _authMode = AuthMode.signin;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthProvider authProvider = AuthProvider();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  var _isLoading = false;
 void _submitForm() {
  setState(() {
    _isLoading = true;
  });
  if (_formKey.currentState!.validate()) {
    if (_authMode == AuthMode.signin) {
      authProvider.signInUser(
        context: context,
        email: _emailController.text,
        password: _passwordController.text,
      ).then((success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UsersScreen()),
          );
        setState(() {
          _isLoading = false;
        });
      });
    } else {
      authProvider.signUpUser(
        context: context,
        email: _emailController.text,
        name: _nameController.text,
        password: _passwordController.text,
      ).then((success) {
         Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        setState(() {
          _isLoading = false;
        });
      });
    }
  } else {
    setState(() {
      _isLoading = false;
    });
  }
}


  void _switchAuthMode() {
    setState(() {
      _authMode =
          _authMode == AuthMode.signin ? AuthMode.signup : AuthMode.signin;
    });
  }
 @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyThemes.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Image(
                  image: AssetImage('assets/images/authscreen/login.png')),
              Center(
                child: Text(
                  _authMode == AuthMode.signup ? 'SIGNUP' : 'LOGIN',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff003579)),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_authMode == AuthMode.signup)
                        CustomTextField(
                           maxLines : 1,
                          controller: _nameController,
                          hintText: "name",
                        ),
                      const SizedBox(height: 10),
                      CustomTextField(
                         maxLines : 1,
                        controller: _emailController,
                        hintText: "email",
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                         maxLines : 1,
                        controller: _passwordController,
                        hintText: "password",
                      ),
                      const SizedBox(height: 10),
                      CustomButton(
                        text: _authMode == AuthMode.signin ? 'LOGIN' : 'SIGNUP',
                        onTap: _submitForm,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: _switchAuthMode,
                  child: Row(
                    children: [
                      Text(
                        _authMode == AuthMode.signin
                            ? 'Don\'t have an account? '
                            : 'Already have an account? ',
                        style: const TextStyle( color: Color(0xff003579)),
                      ),
                      Text(
                        _authMode == AuthMode.signin ? 'Sign up' : 'Login',
                        style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                        const Center(
                          child: CustomLoadingWidget()
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
