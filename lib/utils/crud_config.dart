import 'dart:convert';

import 'package:http/http.dart' as http;

class CRUD {
  //Post method
  create(
    Uri url,
    Map<String, String> header,
    Map<String, dynamic> body,
  ) async {
    print("Uri : $url");
     print("header : $header");
     print("body : $body");
     
     final response = await http.post(
      url,
      headers: header,
      body:jsonEncode(body),
    );
     return response;
  }

  //Get method
  fetchData(Uri url) async {
    return await http.get(url);
  }

  //Put Method
  update() async {}

  //Delete Method
  delete() async {}
}
