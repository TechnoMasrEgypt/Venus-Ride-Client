import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi/core/utils/constants.dart';
import 'package:taxi/global_variables.dart';

class LocationPickerView extends StatefulWidget {
  const LocationPickerView({super.key});

  @override
  State<LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? pickedLatLng;
  String mapTheme = '';

  @override
  void initState() {
    super.initState();
    DefaultAssetBundle.of(context)
        .loadString('assets/map/map_theme.json')
        .then((value) async {
      mapTheme = value;
      final controller = await _controller.future;
      controller.setMapStyle(mapTheme);
    });

    getCurrentPositionUpdate();
  }

  // Same pattern as HomeViewBody — fetches a fresh position rather than
  // trusting the global currentPosition, which may be null or stale when
  // this view is opened.
  void getCurrentPositionUpdate() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      currentPosition = position;

      final controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          zoom: 17,
          target: LatLng(position.latitude, position.longitude),
        ),
      ));
    } catch (e) {
      // Permission denied or location unavailable — map stays at its
      // initialCameraPosition fallback instead of crashing.
      debugPrint('LocationPickerView: could not fetch current position: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tap to choose destination')),
      body: Stack(
        children: [
          GoogleMap(
            padding: const EdgeInsets.only(top: 0),
            initialCameraPosition: CameraPosition(
              target: currentPosition != null
                  ? LatLng(currentPosition!.latitude, currentPosition!.longitude)
                  : googlePlex.target,
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            onMapCreated: (controller) {
              _controller.complete(controller);
              controller.setMapStyle(mapTheme);
            },
            onTap: (LatLng tapped) {
              setState(() {
                pickedLatLng = tapped;
              });
            },
            markers: pickedLatLng != null
                ? {
                    Marker(
                      markerId: const MarkerId('picked'),
                      position: pickedLatLng!,
                    ),
                  }
                : {},
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kDeepBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: pickedLatLng == null
                  ? null
                  : () => Navigator.of(context).pop(pickedLatLng),
              child: const Text(
                'Confirm this location',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}