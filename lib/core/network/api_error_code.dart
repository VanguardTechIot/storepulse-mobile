import 'dart:convert';
import 'package:http/http.dart' as http;

String? apiErrorCodeOf(http.Response response) {
  try {
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic> && body['message'] is String) {
      return body['message'] as String;
    }
    return null;
  } on FormatException {
    return null;
  }
}
