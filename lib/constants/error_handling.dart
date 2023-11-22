import 'dart:convert';
import 'package:construction_app/constants/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
httpErrorHandle({
  // ignore: non_constant_identifier_names
  required responseData,
  required BuildContext context,
  required VoidCallback onSuccess,
}) async {
  switch (responseData.code) {
    case 200:
      onSuccess();
      break;
    case 400:
    showSnackBar(context, jsonDecode(responseData.body)['message'] );
    break;
     case 500:
    showSnackBar(context, jsonDecode(responseData.body)['error'] );
    break;
    default:
 showSnackBar(context, jsonDecode(responseData.body));
  }
}
