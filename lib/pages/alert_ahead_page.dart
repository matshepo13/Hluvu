import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_flutter_app/services/ai_service.dart';
import '../widgets/danger_zone_marker.dart';
import '../models/danger_zone.dart';
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
  final AiService _aiService = AiService();
  List<DangerZone> _dangerZones = [];
  bool _showSearchAnimation = false;

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
      _showMap = _fromLocation != null && _toLocation != null;
    });
  }

  void _handlePlaceSelection(Prediction prediction, bool isFromField) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=${prediction.placeId}&key=$_apiKey'
        ),
      );
      
      if (response.statusCode == 200) {
        final details = json.decode(response.body);
        final location = details['result']['geometry']['location'];
        
        setState(() {
          if (isFromField) {
            _fromLocation = LatLng(
              location['lat'],
              location['lng'],
            );
            _fromController.text = prediction.description ?? '';
          } else {
            _toLocation = LatLng(
              location['lat'],
              location['lng'],
            );
            _toController.text = prediction.description ?? '';
          }
          // Only show map when both locations are properly set
          _showMap = _fromLocation != null && _toLocation != null;
        });
      }
    } catch (e) {
      print('Error getting place details: $e');
    }
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
                  onPressed: () async {
                    print('Confirm Location pressed - Starting API call');
                    setState(() => _showSearchAnimation = true);
                    
                    try {
                      print('Fetching danger zones for: From: ${_fromController.text}, To: ${_toController.text}');
                      final zones = await _aiService.getDangerZones(
                        _fromController.text,
                        _toController.text,
                      );
                      
                      print('Received ${zones.length} danger zones from API');
                      
                      setState(() {
                        _dangerZones = zones;
                        _showSearchAnimation = false;
                      });
                    } catch (e) {
                      print('Error fetching danger zones: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                        setState(() => _showSearchAnimation = false);
                      }
                    }
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
            if (!_showSearchAnimation && _dangerZones.isNotEmpty)
              ..._dangerZones.map((zone) => Positioned(
                left: _getRandomPosition(context, true),
                top: _getRandomPosition(context, false),
                child: DangerZoneMarker(
                  description: zone.description ?? 'No description available',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(zone.description ?? 'No description available'),
                      ),
                    );
                  },
                ),
              )).toList(),
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

  double _getRandomPosition(BuildContext context, bool isHorizontal) {
    final random = math.Random();
    final size = isHorizontal 
      ? MediaQuery.of(context).size.width 
      : MediaQuery.of(context).size.height;
    
    // Add padding to avoid overlapping with input fields
    if (isHorizontal) {
      // Horizontal position: Add padding from left and right edges
      return 40 + random.nextDouble() * (size - 140); // 40px from left, 100px marker width
    } else {
      // Vertical position: Start below the input card
      final topPadding = 250.0; // Adjust this value to move markers below input fields
      final bottomPadding = 100.0; // Space from bottom for the confirm button
      return topPadding + random.nextDouble() * (size - topPadding - bottomPadding);
    }
  }
}