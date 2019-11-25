import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:map_view/map_view.dart';
import 'package:http/http.dart' as http;

import '../../models/location_data.dart';
import '../../models/product.dart';

class LocationInput extends StatefulWidget {
  final Function setLocation;
  final Product product;

  LocationInput(this.setLocation, this.product);
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
    if (widget.product != null) {
      getStaticMap(widget.product.location.address, false);
    }
    super.initState();
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void getStaticMap(String address, [geocode = true]) async {
    if (address.isEmpty) {
      setState(() {
        _staticMapUri = null;
      });
      widget.setLocation(null);
      return;
    }
    if (geocode) {
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

      final formattedAddress =
          decodeResponse['results'][0]['formatted_address'];
      final coords = decodeResponse['results'][0]['geometry']['location'];

      _locationData = LocationData(
        latitude: coords['lat'],
        longitude: coords['lng'],
        address: formattedAddress,
      );
    } else {
      _locationData = widget.product.location;
    }

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
    widget.setLocation(_locationData);
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
        _staticMapUri == null ? Container() : Image.network(_staticMapUri.toString())
      ],
    );
  }
}
