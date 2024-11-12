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
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng? _fromLocation;
  LatLng? _toLocation;

  final _initialCameraPosition = const CameraPosition(
    target: LatLng(-25.7479, 28.2293), // Pretoria coordinates
    zoom: 13,
  );

  final String? _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

  bool _showSearchAnimation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _fromLocation = LatLng(position.latitude, position.longitude);
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _fromLocation!,
            infoWindow: const InfoWindow(title: 'Current Location'),
          ),
        );
      });
      _mapController?.animateCamera(CameraUpdate.newLatLng(_fromLocation!));
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _updateMapMarkers() {
    setState(() {
      _markers.clear();
      if (_fromLocation != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('from'),
            position: _fromLocation!,
            infoWindow: const InfoWindow(title: 'From'),
          ),
        );
      }
      if (_toLocation != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('to'),
            position: _toLocation!,
            infoWindow: const InfoWindow(title: 'To'),
          ),
        );
      }
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
          _updateMapMarkers();
        });

        // Animate camera to show both markers if they exist
        if (_fromLocation != null && _toLocation != null) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(
                  _fromLocation!.latitude < _toLocation!.latitude ? _fromLocation!.latitude : _toLocation!.latitude,
                  _fromLocation!.longitude < _toLocation!.longitude ? _fromLocation!.longitude : _toLocation!.longitude,
                ),
                northeast: LatLng(
                  _fromLocation!.latitude > _toLocation!.latitude ? _fromLocation!.latitude : _toLocation!.latitude,
                  _fromLocation!.longitude > _toLocation!.longitude ? _fromLocation!.longitude : _toLocation!.longitude,
                ),
              ),
              100, // padding
            ),
          );
        } else {
          // Animate to single marker
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(
              isFromField ? _fromLocation! : _toLocation!,
            ),
          );
        }
      }
    } catch (e) {
      print('Error getting place details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error getting location details'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_apiKey == null) {
      return const Scaffold(
        body: Center(
          child: Text('Google Maps API key not found'),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            markers: _markers,
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
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
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: !_showSearchAnimation ? Card(
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
              ) : const SizedBox(), // Empty when showing animation
            ),
          ),
          
          if (_showSearchAnimation)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4, // Moved down to 40% of screen height
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedRings(
                  onClose: () {
                    setState(() {
                      _showSearchAnimation = false;
                    });
                  },
                ),
              ),
            ),
          
          if (!_showSearchAnimation)
            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: _fromLocation != null && _toLocation != null
                    ? () {
                        setState(() {
                          _showSearchAnimation = true;
                        });
                      }
                    : null,
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
    );
  }


  InputDecoration _buildInputDecoration(
    String hintText,
    IconData prefixIcon,
    bool filled,
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