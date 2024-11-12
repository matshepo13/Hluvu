import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

// First, define the AnimatedRings widget
class AnimatedRings extends StatefulWidget {
  final VoidCallback onClose;
  
  const AnimatedRings({super.key, required this.onClose});
  
  @override
  State<AnimatedRings> createState() => _AnimatedRingsState();
}

class _AnimatedRingsState extends State<AnimatedRings> with TickerProviderStateMixin {
  late final AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: false);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ...List.generate(5, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double scale = 1 + index * 0.5 + _controller.value;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color.fromARGB(255, 159, 109, 168).withOpacity(1 - (index * 0.2)),
                        const Color.fromARGB(255, 182, 146, 189).withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
        
        // Close button
        Positioned(
          top: 5,
          right: 10,
          child: IconButton(
            icon: const Icon(Icons.close),
            color: Colors.grey[800],
            onPressed: widget.onClose,
          ),
        ),
      ],
    );
  }
}

class AlertAheadPage extends StatefulWidget {
  const AlertAheadPage({super.key});

  @override
  State<AlertAheadPage> createState() => _AlertAheadPageState();
}

class _AlertAheadPageState extends State<AlertAheadPage> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  LatLng? _fromLocation;
  LatLng? _toLocation;
  final String? _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    _fromController.addListener(_updateState);
    _toController.addListener(_updateState);
  }

  @override
  void dispose() {
    _fromController.removeListener(_updateState);
    _toController.removeListener(_updateState);
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _updateState() {
    setState(() {
      _showMap = _fromController.text.isNotEmpty && _toController.text.isNotEmpty;
    });
  }

  void _handlePlaceSelection(Prediction prediction, bool isFromField) {
    if (isFromField) {
      _fromController.text = prediction.description ?? '';
      _fromLocation = LatLng(0, 0); // Placeholder, replace with actual coordinates
    } else {
      _toController.text = prediction.description ?? '';
      _toLocation = LatLng(0, 0); // Placeholder, replace with actual coordinates
    }
    _updateState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            if (_showMap)
              Positioned.fill(
                child: Image.asset(
                  'assets/images/map.png',
                  fit: BoxFit.cover,
                ),
              ),
            Positioned(
              top: 40,
              left: 16,
              child: SafeArea(
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, 
                      color: Color.fromARGB(255, 159, 109, 168)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 100,
              left: 16,
              right: 16,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      GooglePlaceAutoCompleteTextField(
                        textEditingController: _fromController,
                        googleAPIKey: _apiKey!,
                        inputDecoration: _buildInputDecoration(
                          "Current location",
                          Icons.my_location,
                          true,
                          _fromController,
                        ).copyWith(
                          suffixIcon: _fromController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _fromController.clear();
                                  _updateState();
                                },
                              )
                            : null,
                        ),
                        countries: const ['za'],
                        debounceTime: 800,
                        isLatLngRequired: true,
                        getPlaceDetailWithLatLng: (Prediction prediction) {
                          _handlePlaceSelection(prediction, true);
                        },
                        itemClick: (Prediction prediction) {
                          _handlePlaceSelection(prediction, true);
                        },
                      ),
                      const SizedBox(height: 12),
                      GooglePlaceAutoCompleteTextField(
                        textEditingController: _toController,
                        googleAPIKey: _apiKey!,
                        inputDecoration: _buildInputDecoration(
                          "Where to?",
                          Icons.location_on_outlined,
                          false,
                          _toController,
                        ).copyWith(
                          suffixIcon: _toController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _toController.clear();
                                  _updateState();
                                },
                              )
                            : null,
                        ),
                        countries: const ['za'],
                        debounceTime: 800,
                        isLatLngRequired: true,
                        getPlaceDetailWithLatLng: (Prediction prediction) {
                          _handlePlaceSelection(prediction, false);
                        },
                        itemClick: (Prediction prediction) {
                          _handlePlaceSelection(prediction, false);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_showMap)
              Positioned(
                bottom: 32,
                left: 16,
                right: 16,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle confirm location
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 159, 109, 168),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Confirm Location',
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
    );
  }

  InputDecoration _buildInputDecoration(
    String hintText,
    IconData prefixIcon,
    bool filled,
    TextEditingController controller,
  ) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(
        prefixIcon,
        color: const Color.fromARGB(255, 159, 109, 168),
      ),
      filled: filled,
      fillColor: filled ? Colors.grey[100] : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 120, 70, 130),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 120, 70, 130),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 120, 70, 130),
        ),
      ),
    );
  }
}