import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Completer<GoogleMapController> _googleMapController = Completer();
  CameraPosition? _cameraPosition;
  Location? _location;
  LocationData? _currentLocation;
  Set<Marker> _markers = {};
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _toggleMapType() {
    setState(() {
      if (_currentMapType == MapType.normal) {
        _currentMapType = MapType.satellite;
      } else {
        _currentMapType = MapType.normal;
      }
    });
  }

  _init() async {
    _location = Location();
    _cameraPosition = CameraPosition(
        target: LatLng(
            0, 0), // this is just the example lat and lng for initializing
        zoom: 15);
    _initLocation();
    _addMarker(LatLng(0, 0)); // Add initial marker
  }

  //Khởi tạo vị trí ban đầu là vị trí hiện tại của thiết bị (nếu có)
  // _init() async {
  //   _location = Location();
  //   _currentLocation = await _location?.getLocation();
  //   _cameraPosition = CameraPosition(
  //     target: LatLng(
  //       _currentLocation?.latitude ?? 0,
  //       _currentLocation?.longitude ?? 0,
  //     ),
  //     zoom: 15,
  //   );
  //   _initLocation();
  //   _addMarker(_cameraPosition!.target); // Thêm marker cho vị trí ban đầu
  // }

  //function to listen when we move position
  // _initLocation() {
  //   //use this to go to current location instead
  //   _location?.getLocation().then((location) {
  //     _currentLocation = location;
  //   });
  //   _location?.onLocationChanged.listen((newLocation) {
  //     _currentLocation = newLocation;

  //     moveToPosition(LatLng(
  //         _currentLocation?.latitude ?? 0, _currentLocation?.longitude ?? 0));
  //   });
  // }

  _initLocation() {
    _location?.getLocation().then((location) {
      _currentLocation = location;
    });
    _location?.onLocationChanged.listen((newLocation) {
      _currentLocation = newLocation;
      if (mounted) {
        setState(() {
          moveToPosition(LatLng(_currentLocation?.latitude ?? 0,
              _currentLocation?.longitude ?? 0));
        });
      }
    });
  }

  moveToPosition(LatLng latLng) async {
    GoogleMapController mapController = await _googleMapController.future;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 15)));

    print('New Position: ${latLng}');
    _updateMarkerPosition(latLng); // Update marker position
  }

  // Function to add a marker
  _addMarker(LatLng latLng) {
    final Marker marker = Marker(
      markerId: MarkerId('current_position'),
      position: latLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    if (mounted) {
      setState(() {
        _markers.add(marker);
      });
    }
  }

// Function to update marker position
  _updateMarkerPosition(LatLng latLng) {
    if (mounted) {
      setState(() {
        _markers.clear(); // Clear existing markers
        _addMarker(latLng); // Add new marker
      });
    }
  }

  // // Function to add a marker
  // _addMarker(LatLng latLng) {
  //   final Marker marker = Marker(
  //     markerId: MarkerId('current_position'),
  //     position: latLng,
  //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
  //   );

  //   setState(() {
  //     _markers.add(marker);
  //   });
  // }

  // // Function to update marker position
  // _updateMarkerPosition(LatLng latLng) {
  //   _markers.clear(); // Clear existing markers
  //   _addMarker(latLng); // Add new marker
  // }

  Widget _buildMapToggle() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: FloatingActionButton(
          onPressed: _toggleMapType,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          backgroundColor: Colors.red,
          child: const Icon(Icons.map),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return _getMap();
  }

  Widget _getMap() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _cameraPosition!,
          mapType: _currentMapType,
          onMapCreated: (GoogleMapController controller) {
            if (!_googleMapController.isCompleted) {
              _googleMapController.complete(controller);
            }
          },
          markers: _markers,
        ),
        _buildMapToggle(), // Thêm nút chuyển đổi
      ],
    );
  }
}
