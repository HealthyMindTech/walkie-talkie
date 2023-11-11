import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../geolocator.dart';
import '../widgets/geometry.dart';
import '../services/backend.dart';
import 'login_screen.dart';
import 'package:logging/logging.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class ExplorePage extends StatefulWidget {
  final String title;

  const ExplorePage({super.key, required this.title});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class CustomButton extends StatelessWidget {
  // Add children and onPressed to your properties
  final List<Widget>? children;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.children,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 10.0, vertical: 8.0), // Increased vertical padding
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFf8c85c), Color(0xFFfc8c3e)], // Orange gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: Offset(0, 4),
              blurRadius: 4.0,
            ),
          ],
          borderRadius: BorderRadius.circular(10.0), // Slightly rounded corners
          border: Border.all(
            color: Color(0xFFae3d0b), // Adjusted for a darker border color
            width: 2.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children!,
        ),
      ),
    );
  }
}

class _ExplorePageState extends State<ExplorePage> {
  late MapController _mapController;
  late Stream<Position>? posStream;
  StreamSubscription? subscription;
  LatLng? position;
  WebSocketChannel? _webSocketChannel;
  static final log = Logger("_MyHomePageState");

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    final token = Supabase.instance.client.auth.currentSession!.accessToken;

    Backend().startWebsocket(token).then((webSocket) {
      log.info("websocket: $webSocket");
      _webSocketChannel = webSocket;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setPosition();
      _trackPosition();
    });
  }

  Marker _createMyMarker(LatLng point) {
    const double width = 20;
    const double height = 20;

    return Marker(
        width: width,
        height: height,
        point: point,
        child: const CircleWidget(
            size: Size(width, height), color: Colors.purple));
  }

  void _sendPosition(Position position) {
    _webSocketChannel?.sink.add(jsonEncode({
      "type": "location",
      "location": {
        "latitude": position.latitude,
        "longitude": position.longitude,
      },
    }));
  }

  Future<void> _setPosition() async {
    final Position position = await GeoLocator.instance.determinePosition();

    _sendPosition(position);
    final LatLng latlng = LatLng(position.latitude, position.longitude);
    if (mounted) {
      setState(() {
        this.position = latlng;
      });
    }
  }

  Future<void> _trackPosition() async {
    posStream = await GeoLocator.instance.trackPosition();
    subscription = posStream?.listen(_haveMoved);
  }

  void _haveMoved(Position pos) async {
    final newPos = LatLng(pos.latitude, pos.longitude);
    _sendPosition(pos);
    log.info("position: $newPos");
    _mapController.move(newPos, _mapController.camera.zoom);
    if (mounted) {
      setState(() {
        position = newPos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color.fromRGBO(36, 58, 47, 1), // Set the background color
      body: SafeArea(
        child: Column(
          children: [
            // Top area with character name and progress bar
            Container(
              padding: EdgeInsets.all(16.0),
              color: Color.fromRGBO(36, 58, 47, 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    color: Color.fromRGBO(36, 58, 47, 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 2.0,
                                color: Colors.grey[300],
                              ),
                              SizedBox(height: 2),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'John the Chef',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                  CustomButton(
                                    // Level indicator
                                    children: [
                                      Text(
                                        '45',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                    onPressed:
                                        () {}, // Replace with your button press action
                                  ),
                                ],
                              ),
                              SizedBox(height: 2),
                              Container(
                                height: 2.0,
                                color: Colors.grey[300],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.45, // Dummy progress value
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color.fromRGBO(254, 159, 77, 1)),
                      minHeight: 20,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Map area with padding
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        center: position ?? LatLng(0, 0),
                        zoom: 13.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          tileProvider: NetworkTileProvider(),
                          userAgentPackageName: 'com.example.app',
                        ),
                        if (position != null)
                          MarkerLayer(markers: [_createMyMarker(position!)]),
                      ]),
                ),
              ),
            ),
            // Bottom area for audio player
            Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.black.withOpacity(0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.play_arrow, color: Colors.white),
                  Text(
                    'Audio Player',
                    style: TextStyle(color: Colors.white),
                  ),
                  CustomButton(
                    children: [
                      Text(
                        'Pause',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                    onPressed: () {
                      // Your button press action
                    },
                  ),
                  Icon(Icons.stop, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    subscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }
}
