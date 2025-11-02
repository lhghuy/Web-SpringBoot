import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report_data.dart';

class ReportService {
  static const String baseUrl = "http://localhost:8080/api/admin/reports";

  static Future<ReportData?> fetchReport(String dateFrom, String dateTo) async {
    final uri = Uri.parse("$baseUrl?dateFrom=$dateFrom&dateTo=$dateTo");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return ReportData.fromJson(data['data']);
      }
    }
    return null;
  }
}
