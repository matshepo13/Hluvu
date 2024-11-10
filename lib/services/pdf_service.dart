import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PdfService {
  Future<String> generateReport(String reportContent) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('CRIMINAL INCIDENT REPORT',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold
              )
            )
          ),
          pw.SizedBox(height: 20),
          pw.Text(reportContent),
        ],
      )
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/incident_report.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file.path;
  }
}