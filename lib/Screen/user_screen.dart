import 'package:flutter/material.dart';

import '../Componets/widgets/custom_button.dart';
import '../Componets/widgets/custom_textFeld.dart';
import '../utils/theme_provider.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});
  static const routeName = "/Success-screen";

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: MyThemes.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Icon(
                    Icons.arrow_back_ios_new_outlined,
                    color: Color(0xFF1A1A1A),
                    size: 16,
                  ),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.19),
            const Text(
              "COMPLAINT FORM",
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CustomTextField(
                      maxLines: 1,
                      controller: _nameController,
                      hintText: "name",
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      maxLines: 1,
                      controller: _emailController,
                      hintText: "email",
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      maxLines: 1,
                      controller: _mobileController,
                      hintText: "mobile",
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      maxLines: 5,
                      controller: _addressController,
                      hintText: "address",
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: "SUBMIT",
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
