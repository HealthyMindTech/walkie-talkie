import 'package:flutter/material.dart';
import '../widgets/audio_player.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logging/logging.dart';

import '../geolocator.dart';
import '../widgets/geometry.dart';

import '../widgets/custom_button.dart';
import '../services/backend.dart';

import 'dart:convert';
import 'dart:async';

class ExplorePage extends StatefulWidget {
  final String title;

  const ExplorePage({super.key, required this.title});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  static final log = Logger('_ExplorePageState');
  late MapController _mapController;
  late Stream<Position>? posStream;
  final GlobalKey<AudioPlayerWidgetState> audioPlayerKey =
      GlobalKey<AudioPlayerWidgetState>();
  StreamSubscription? subscription;
  LatLng? position;

  WebSocketChannel? _webSocketChannel;
  bool userHasInteracted = false;

  void _websocketListen(dynamic event) async {
    try {
      final decodedJson = jsonDecode(event);

      switch (decodedJson["type"]) {
        case "audio":
          final path = decodedJson["path"];
          log.info("Received audio: $path");
          final url =
              Supabase.instance.client.storage.from('audio').getPublicUrl(path);
          audioPlayerKey.currentState!.addUrl(url);
          break;
        default:
          log.info("Unknown message type: ${decodedJson["type"]}");
      }
    } catch (e) {
      log.warning("Error decoding json: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    final token = Supabase.instance.client.auth.currentSession!.accessToken;

    Backend().startWebsocket(token).then((webSocket) {
      log.info("websocket: $webSocket");
      _webSocketChannel = webSocket;
      _webSocketChannel?.stream.listen(_websocketListen);
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

  void _onAudioEnd() {
    log.info("Audio ended");
    _webSocketChannel?.sink.add(jsonEncode({
      "type": "generate_new_chunk",
    }));
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
      backgroundColor: const Color.fromRGBO(36, 58, 47, 1),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Top area with character name and progress bar
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: const Color.fromRGBO(36, 58, 47, 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        color: const Color.fromRGBO(36, 58, 47, 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 2.0,
                                    color: const Color(0xFFfbfcf4),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomButton(
                                        children: [
                                          // Character icon
                                          const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                          ),
                                        ],
                                        onPressed:
                                            () {}, // Replace with your button press action
                                      ),
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: DefaultTextStyle.of(context)
                                              .style,
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: 'John ',
                                              style: TextStyle(
                                                fontSize: 26.0,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFFfbfcf4),
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'the ',
                                              style: TextStyle(
                                                fontSize: 26.0,
                                                fontWeight: FontWeight.normal,
                                                color: const Color(0xFFfbfcf4),
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'Chef',
                                              style: TextStyle(
                                                fontSize: 26.0,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFFfbfcf4),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      CustomButton(
                                        // Level indicator
                                        children: [
                                          Text(
                                            'lvl 5',
                                            style: const TextStyle(
                                              color: Color(0xFFfbfcf4),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ],
                                        onPressed:
                                            () {}, // Replace with your button press action
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    height: 2.0,
                                    color: const Color(0xFFfbfcf4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 0.0),
                          decoration: BoxDecoration(
                            // color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Level and XP remaining row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '3.2 km walked', // Level display
                                    style: const TextStyle(
                                      color: Color(0xFFfbfcf4),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    '4.1 km to level up', // XP remaining for next level
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                  height: 4), // Spacing between text and bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    10), // Fully rounded corners
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Color(
                                            0xFFfbfcf4), // Background color of the bar
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor:
                                          0.75, // Fraction of the bar filled with experience
                                      child: Container(
                                        height: 10,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Color(0xFFf8c85c),
                                              Color(0xFFfc8c3e)
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Map area with padding
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            center: position ?? const LatLng(0, 0),
                            initialZoom: 13.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              tileProvider: NetworkTileProvider(),
                              userAgentPackageName: 'com.example.app',
                            ),
                            if (position != null)
                              MarkerLayer(
                                  markers: [_createMyMarker(position!)]),
                          ]),
                    ),
                  ),
                ),
                // Bottom area for audio player
                AudioPlayerWidget(
                    key: audioPlayerKey, onEndOfAudio: _onAudioEnd)
              ],
            ),
          ),
          if (!userHasInteracted)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: CustomButton(
                    children: [
                      const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Start Listening',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    onPressed: () {
                      setState(() {
                        userHasInteracted = true;
                      });
                      audioPlayerKey.currentState?.startAudio(); // Call the method to start audio
                      // Optionally start the audio player here
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    subscription?.cancel();
    _mapController.dispose();
    _webSocketChannel?.sink.close();
    super.dispose();
  }
}
