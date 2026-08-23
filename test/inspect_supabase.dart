// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  test('inspect openapi schema', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    final url = dotenv.env['SUPABASE_URL']!;
    final key = dotenv.env['SUPABASE_PUBLISHABLE_KEY']!;
    
    final client = HttpClient();
    final req = await client.getUrl(Uri.parse('$url/rest/v1/?apikey=$key'));
    req.headers.add('apikey', key);
    req.headers.add('Authorization', 'Bearer $key');
    final resp = await req.close();
    final body = await resp.transform(utf8.decoder).join();
    print('STATUS: ${resp.statusCode}');
    if (resp.statusCode == 200) {
      final json = jsonDecode(body);
      final paths = (json['paths'] as Map<String, dynamic>).keys.toList();
      print('FOUND_PATHS: $paths');
      final definitions = (json['definitions'] as Map<String, dynamic>?)?.keys.toList();
      print('FOUND_DEFINITIONS: $definitions');
    } else {
      print('BODY: $body');
    }
  });
}
