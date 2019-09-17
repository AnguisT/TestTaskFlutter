// dart
import "dart:async";
import "dart:convert";

// package
import "package:http/http.dart" as http;

class CustomHttpClient {
  String urlServer = "https://randomuser.me/api?results=";

  Future getPeople(count) async {
    var url = urlServer + count.toString();
    return await http.get(url).then((response) {
      return json.decode(response.body);
    }).catchError((error) {
      return 'Error';
    });
  }
}