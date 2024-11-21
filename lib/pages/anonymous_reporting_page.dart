import 'package:flutter/material.dart';
import 'report_form_page.dart';

class AnonymousReportingPage extends StatefulWidget {
  const AnonymousReportingPage({super.key});

  @override
  State<AnonymousReportingPage> createState() => _AnonymousReportingPageState();
}

class _AnonymousReportingPageState extends State<AnonymousReportingPage> {
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Anonymous Reporting',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 159, 109, 168),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              
              // Image at the top
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/anon.webp',
                  height: 290,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 32),
              
              // Terms and conditions card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'By submitting an anonymous report, you agree to:\n\n'
                        '• Provide truthful and accurate information\n'
                        '• Not misuse this platform for false reporting\n'
                        '• Understand that while your identity remains anonymous, '
                        'the information will be shared with relevant authorities\n'
                        '• Accept that follow-up may be limited due to anonymity',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _termsAccepted,
                            onChanged: (value) {
                              setState(() {
                                _termsAccepted = value ?? false;
                              });
                            },
                            activeColor: const Color.fromARGB(255, 159, 109, 168),
                          ),
                          const Expanded(
                            child: Text(
                              'I have read and agree to the terms and conditions',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Create Report Button
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: ElevatedButton(
                  onPressed: _termsAccepted
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReportFormPage(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 159, 109, 168),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: const Text(
                    'Create Anonymous Report',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}