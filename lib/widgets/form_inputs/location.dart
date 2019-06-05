import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:map_view/map_view.dart';
import 'package:http/http.dart' as http;

import '../../models/location_data.dart';

class LocationInput extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  final FocusNode _addressInputFocusNode = FocusNode();
  final TextEditingController _addressInputController = TextEditingController();
  Uri _staticMapUri;
  LocationData _locationData;

  @override
  void initState() {
    _addressInputFocusNode.addListener(_updateLocation);
    super.initState();
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void getStaticMap(String address) async {
    if (address.isEmpty) {
      setState(() {
        _staticMapUri = null;
      });
      return;
    }
    final Uri uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      {
        'address': address,
        'key': 'AIzaSyDP2O_br7gTWG3Qu9Vs5NlFZWKLXFfK4SM',
      },
    );
    final http.Response response = await http.get(uri);
    final decodeResponse = json.decode(response.body);
    print(decodeResponse);

    final formattedAddress = decodeResponse['results'][0]['formatted_address'];
    final coords = decodeResponse['results'][0]['geometry']['location'];

    _locationData = LocationData(
      latitude: coords['lat'],
      longitude: coords['lng'],
      address: formattedAddress,
    );

    final StaticMapProvider staticMapProvider =
        StaticMapProvider('AIzaSyDP2O_br7gTWG3Qu9Vs5NlFZWKLXFfK4SM');
    final Uri staticMapUri = staticMapProvider.getStaticUriWithMarkers([
      Marker(
        'position',
        'Position',
        _locationData.latitude,
        _locationData.longitude,
      ),
    ],
        center: Location(_locationData.latitude, _locationData.longitude),
        width: 500,
        height: 300,
        maptype: StaticMapViewType.roadmap);
    setState(() {
      _addressInputController.text = _locationData.address;
      _staticMapUri = staticMapUri;
    });
  }

  void _updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      getStaticMap(_addressInputController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextFormField(
          autofocus: true,
          focusNode: _addressInputFocusNode,
          controller: _addressInputController,
          validator: (String input) {
            if (_locationData == null || input.isEmpty) {
              return 'No valid loaction found.';
            }
          },
          decoration: InputDecoration(labelText: 'Address'),
        ),
        SizedBox(
          height: 10.0,
        ),
        Image.network(_staticMapUri.toString())
      ],
    );
  }
}
