import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const supabaseUrl = 'https://slodgecpfofupebjyxxt.supabase.co';
  static const supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNsb2RnZWNwZm9mdXBlYmp5eHh0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc0MjI4ODksImV4cCI6MjA2Mjk5ODg4OX0.JUOdAgswDqHeSmpYxw-wn4kZPxqWIemiHVhqXisO68o';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
// await Supabase.initialize(
//     url: 'https://slodgecpfofupebjyxxt.supabase.co',
//     anonKey:
//         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNsb2RnZWNwZm9mdXBlYmp5eHh0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc0MjI4ODksImV4cCI6MjA2Mjk5ODg4OX0.JUOdAgswDqHeSmpYxw-wn4kZPxqWIemiHVhqXisO68o',
//   );
