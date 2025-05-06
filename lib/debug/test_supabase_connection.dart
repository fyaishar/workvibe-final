import 'dart:convert';
import 'dart:io';
import 'package:finalworkvibe/config/env.dart';

void main() async {
  print('Testing Supabase connection...');
  print('URL: ${Env.supabaseUrl}');
  print('API Key length: ${Env.supabaseAnonKey.length} characters');
  
  final client = HttpClient();
  
  try {
    // Test endpoint - just getting public settings
    final request = await client.getUrl(
      Uri.parse('${Env.supabaseUrl}/rest/v1/'),
    );
    
    // Add the required headers
    request.headers.set('apikey', Env.supabaseAnonKey);
    request.headers.set('Authorization', 'Bearer ${Env.supabaseAnonKey}');
    
    final response = await request.close();
    
    final body = await response.transform(utf8.decoder).join();
    
    print('\nResponse status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('✅ Connection successful!');
      print('\nResponse headers:');
      response.headers.forEach((name, values) {
        print('  $name: $values');
      });
      
      print('\nResponse body (first 200 chars):');
      print('  ${body.substring(0, body.length > 200 ? 200 : body.length)}...');
    } else {
      print('❌ Connection failed!');
      print('\nResponse body:');
      print(body);
    }
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.close();
  }
}

// Run this test with:
// dart lib/debug/test_supabase_connection.dart 