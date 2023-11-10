import 'dart:async';
import 'package:geolocator/geolocator.dart';

class GeoLocator {
  static GeoLocator? _geolocator;

  static GeoLocator get instance {
    return _geolocator ??= GeoLocator();
  }

  Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return Future.value(true);
  }

  Future<Stream<Position>> trackPosition() async {
    await checkPermission();
    return Geolocator.getPositionStream();
  }

  Future<Position> determinePosition() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      return await Geolocator.getCurrentPosition();
    }
    return Future.error("Can't get position");
  }
}
