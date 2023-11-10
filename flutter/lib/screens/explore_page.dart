import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../geolocator.dart';
import '../widgets/geometry.dart';
import 'login_screen.dart';

class ExplorePage extends StatefulWidget {
  final String title;

  const ExplorePage({super.key, required this.title});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late MapController _mapController;
  late Stream<Position>? posStream;
  StreamSubscription? subscription;
  LatLng? position;
  int seenEvents = 0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _setPosition();
    _trackPosition();
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

  Future<void> _setPosition() async {
    final Position position = await GeoLocator.instance.determinePosition();
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

    seenEvents++;

    if (seenEvents < 8) {
      return;
    }

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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/config');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await Supabase.instance.client.auth.signOut();

              navigator.pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to Walkie Talkie!',
            ),
            Container(
                height: MediaQuery.of(context).size.height - 300,
                padding: const EdgeInsets.all(20.0),
                child: FlutterMap(
                    mapController: _mapController,
                    options: const MapOptions(
                      initialCenter: LatLng(60.1699, 24.9384),
                      initialZoom: 12,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      if (position != null)
                        MarkerLayer(markers: [_createMyMarker(position!)]),
                    ]))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Start walking',
        child: const Icon(Icons.play_arrow),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void dispose() {
    super.dispose();
    (_mapController as MapControllerImpl).dispose();
    subscription?.cancel();
  }
}
