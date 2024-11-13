import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportFormPage extends StatefulWidget {
  const ReportFormPage({super.key});

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  String? selectedAbuseType;
  final TextEditingController _locationController = TextEditingController();
  final List<TextEditingController> _answerControllers = [
    TextEditingController(), // What happened
    TextEditingController(), // Who
    TextEditingController(), // How
  ];
  final List<File?> _selectedImages = List.generate(3, (_) => null); // Store up to 3 images
  final ImagePicker _picker = ImagePicker();
  String? _apiKey;
  bool _isEnglish = true; // Track current language

  @override
  void initState() {
    super.initState();
    _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
  }

  Future<void> _pickImage(int index) async {
    try {
      if (Platform.isWindows) {
        // Use file_selector for Windows
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        
        if (result != null && result.files.isNotEmpty) {
          setState(() {
            _selectedImages[index] = File(result.files.first.path!);
          });
        }
      } else {
        // For other platforms, use image_picker
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
        );
        
        if (image != null) {
          setState(() {
            _selectedImages[index] = File(image.path);
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    for (var controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _isEnglish ? 'Report Form' : 'Foromo ya Pegelo',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 159, 109, 168),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {
              setState(() {
                _isEnglish = !_isEnglish;
              });
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Field
              Text(
                _isEnglish ? 'Location:' : 'Lefelo:',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              GooglePlaceAutoCompleteTextField(
                textEditingController: _locationController,
                googleAPIKey: _apiKey!,
                inputDecoration: InputDecoration(
                  hintText: _isEnglish ? 'Enter location' : 'Tsenya lefelo',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 159, 109, 168),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 159, 109, 168),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 159, 109, 168),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                countries: const ['za'],
                debounceTime: 800,
                isLatLngRequired: true,
                getPlaceDetailWithLatLng: (Prediction prediction) {
                  _locationController.text = prediction.description!;
                },
                itemClick: (Prediction prediction) {
                  _locationController.text = prediction.description!;
                },
              ),
              const SizedBox(height: 16),

              // Type of Abuse Section
              Text(
                _isEnglish ? 'Type of Abuse:' : 'Mofuta wa Tshotlako:',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildRadioOption(_isEnglish ? 'Physical' : 'Ya mmele'),
              _buildRadioOption(_isEnglish ? 'Emotional' : 'Ya maikutlo'),
              _buildRadioOption(_isEnglish ? 'Financial' : 'Ya madi'),
              const SizedBox(height: 16),

              // Description Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEnglish ? 'Description:' : 'Tlhaloso:',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color.fromARGB(255, 159, 109, 168),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildQuestionField(
                          0,
                          _isEnglish ? 'What happened:' : 'Go diragetseng:',
                          _isEnglish ? 'Describe what happened' : 'Tlhalosa se se diragetseng',
                        ),
                        const SizedBox(height: 16),
                        _buildQuestionField(
                          1,
                          _isEnglish ? 'Who:' : 'Mang:',
                          _isEnglish ? 'Who was involved' : 'Ke mang yo o amilweng',
                        ),
                        const SizedBox(height: 16),
                        _buildQuestionField(
                          2,
                          _isEnglish ? 'How:' : 'Jang:',
                          _isEnglish ? 'How did it happen' : 'Go diragetse jang',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Supporting Documentation
              Text(
                _isEnglish ? 'Supporting Documentation:' : 'Dikwalo tsa Tshegetso:',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildImageUploadBox(0),
                  const SizedBox(width: 16),
                  _buildImageUploadBox(1),
                  const SizedBox(width: 16),
                  _buildImageUploadBox(2),
                ],
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 159, 109, 168),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEnglish ? 'Submit' : 'Romela',
                    style: const TextStyle(
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

  Widget _buildRadioOption(String value) {
    return RadioListTile<String>(
      title: Text(value),
      value: value,
      groupValue: selectedAbuseType,
      onChanged: (String? newValue) {
        setState(() {
          selectedAbuseType = newValue;
        });
      },
      activeColor: const Color.fromARGB(255, 159, 109, 168),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildImageUploadBox(int index) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: _selectedImages[index] == null
              ? IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Color.fromARGB(255, 159, 109, 168),
                    size: 32,
                  ),
                  onPressed: () => _pickImage(index),
                )
              : Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImages[index]!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedImages[index] = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildQuestionField(int index, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _answerControllers[index],
          maxLines: 2,
          style: TextStyle(color: Colors.grey[700]),
          textInputAction: index < 2 ? TextInputAction.next : TextInputAction.done,
          onSubmitted: (value) {
            if (index < 2) {
              FocusScope.of(context).nextFocus();
            } else {
              FocusScope.of(context).unfocus();
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 159, 109, 168),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 159, 109, 168),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    try {
      print('Starting form submission...');
      
      // Read the PDF file
      final ByteData pdfData = await rootBundle.load('assets/docs/anony_doc.pdf');
      final bytes = pdfData.buffer.asUint8List();
      final base64Pdf = base64Encode(bytes);
      
      print('PDF file loaded and encoded');

      // Create email content
      final emailContent = '''
Good day,

Someone has reported abuse anonymously. Here are the details:

Location: ${_locationController.text}
Type of Abuse: ${selectedAbuseType}

Description:
1. What Happened: ${_answerControllers[0].text}
2. Who was Involved: ${_answerControllers[1].text}
3. How it Happened: ${_answerControllers[2].text}

This report was submitted through the anonymous reporting system.
Please find the attached PDF document for additional information.

Best regards,
Anonymous Reporting System
''';

      // Prepare form data
      final formData = {
        'email': 'tebogomatshepo@gmail.com',
        'message': emailContent,
        '_attachment': base64Pdf,
        'subject': 'Anonymous Abuse Report',
      };

      print('Sending data to Formspree...');
      
      final response = await http.post(
        Uri.parse('https://formspree.io/f/mvgorpyp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(formData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(_isEnglish ? 'Success' : 'Katlego'),
                content: Text(
                  _isEnglish 
                    ? 'Your report has been submitted successfully.'
                    : 'Pegelo ya gago e rometse sentle.',
                ),
                actions: [
                  TextButton(
                    child: Text(_isEnglish ? 'OK' : 'Go siame'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Return to previous screen
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        throw 'Failed to submit form';
      }
    } catch (e) {
      print('Error submitting form: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEnglish 
                ? 'Failed to submit report: $e'
                : 'Go paletswe go romela pegelo: $e'
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}