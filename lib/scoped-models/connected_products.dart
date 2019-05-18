import 'dart:convert';

import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/user.dart';

class ConnectedProductsModel extends Model {
  List<Product> _products = [];
  int _selProductIndex;
  User _authenticatedUser;

  void addProduct(
    String title,
    String description,
    double price,
    String image,
  ) {
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
          'https://www.eatthis.com/wp-content/uploads/2017/10/dark-chocolate-bar-squares-500x366.jpg',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
    };

    http
        .post(
      'https://flutter-product-manager-ac339.firebaseio.com/products.json',
      body: json.encode(productData),
    )
        .then((http.Response response) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Product newProduct = Product(
          id: responseData['name'],
          title: title,
          description: description,
          price: price,
          image: image,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id);
      _products.add(newProduct);
      print(_products);
      notifyListeners();
    });

    final Product newProduct = Product(
        title: title,
        description: description,
        price: price,
        image: image,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id);
    _products.add(newProduct);
    print(_products);
    notifyListeners();
  }
}

class ProductsModel extends ConnectedProductsModel {
  bool _showFavorites = false;

  int get selectedProductIndex {
    return _selProductIndex;
  }

  List<Product> get allProducts {
    if (_showFavorites) {
      return _products.where((Product product) => product.isFavorite).toList();
    }
    return List.from(_products);
  }

  Product get selectedProduct {
    if (selectedProductIndex == null) return null;
    return _products[selectedProductIndex];
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  void fetchProducts() {
    http
        .get(
            'https://flutter-product-manager-ac339.firebaseio.com/products.json')
        .then((http.Response response) {
      final List<Product> fetchedProductList = [];
      final Map<String, dynamic> productListData =
          json.decode(response.body);
      productListData
          .forEach((String productId, dynamic productData) {
        final Product product = Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          image: productData['image'],
          price: productData['price'],
          userEmail: productData['userEmail'],
          userId: productData['userId'],
        );
        fetchedProductList.add(product);
      });
      _products = fetchedProductList;
      notifyListeners();
    });
  }

  void toggleProductFavoriteStatus() {
    final bool isCurrentFavorite = _products[selectedProductIndex].isFavorite;
    final bool newFavoriteStatus = !isCurrentFavorite;
    final Product updatedProduct = Product(
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id,
        isFavorite: newFavoriteStatus);
    _products[selectedProductIndex] = updatedProduct;
    notifyListeners();
  }

  void updateProduct(
      String title, String description, double price, String image) {
    final Product updatedProduct = Product(
        title: title,
        description: description,
        price: price,
        image: image,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId);
    _products[selectedProductIndex] = updatedProduct;
    print(_products);
    notifyListeners();
  }

  void deleteProduct() {
    _products.removeAt(selectedProductIndex);
    print(_products);
    notifyListeners();
  }

  void selectProduct(int index) {
    _selProductIndex = index;
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}

class UserModel extends ConnectedProductsModel {
  void login(String email, String password) {
    _authenticatedUser =
        User(id: "fafjsljflajsf", email: email, password: password);
  }
}
