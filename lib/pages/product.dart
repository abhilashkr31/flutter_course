import 'package:flutter/material.dart';

import '../widgets/products/ui_elements/title_default.dart';

class ProductPage extends StatelessWidget {
  final String title;
  final String description;
  final double price;
  final String imageUrl;

  ProductPage(this.title, this.imageUrl, this.price, this.description);

  _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Are you sure"),
          content: Text("This action cannot be undone!"),
          actions: <Widget>[
            FlatButton(
              child: Text("DISCARD"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("DELETE"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildAddressPriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "Union Square, San Francisco",
          style: TextStyle(fontFamily: 'Oswald', color: Colors.grey),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(
            '|',
            style: TextStyle(
              fontFamily: 'Oswald',
              color: Colors.grey,
            ),
          ),
        ),
        Text(
          "\$$price",
          style: TextStyle(fontFamily: 'Oswald', color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Product Details"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(imageUrl),
            Container(
              padding: EdgeInsets.all(10.0),
              child: TitleDefault(title),
            ),
            _buildAddressPriceRow(),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Text(
                description,
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              child: RaisedButton(
                color: Theme.of(context).accentColor,
                child: Text("DELETE"),
                onPressed: () => _showWarningDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
