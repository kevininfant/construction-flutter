import 'package:flutter/material.dart';
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
   final int maxLines;
  const CustomTextField({super.key,required this.controller,required this.hintText , required this.maxLines });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines:maxLines , 
      controller: controller ,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black38,
          )
        ),
          focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 33, 44, 243), // Set your desired focused border color
          ),
        ),
      ),
      validator: (val){
        if (val == null || val.isEmpty) {
          return "Enter the $hintText";
        }
        return null;
      },
    );
  }
}