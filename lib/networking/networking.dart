import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class NetworkRequest {
  static Future<dynamic> getHttpData(String url) async {
    http.Response? response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var document = parse(response.body);
      return document;
    } else {
      print('Network error: ${response.statusCode}');

      return null;
    }
  }
}
