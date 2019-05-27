import 'dart:convert';
import 'dart:async';

import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/user.dart';
import '../models/auth.dart';

class ConnectedProductsModel extends Model {
  List<Product> _products = [];
  String _selProductId;
  User _authenticatedUser;
  bool _isLoading = false;
}

class ProductsModel extends ConnectedProductsModel {
  bool _showFavorites = false;

  String get selectedProductId {
    return _selProductId;
  }

  List<Product> get allProducts {
    if (_showFavorites) {
      return _products.where((Product product) => product.isFavorite).toList();
    }
    return List.from(_products);
  }

  Product get selectedProduct {
    if (_selProductId == null) {
      return null;
    }
    return _products.firstWhere(
      (Product product) {
        return product.id == _selProductId;
      },
    );
  }

  int get selectedProductIndex {
    return _products.indexWhere(
      (Product product) {
        return product.id == _selProductId;
      },
    );
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  Future<bool> addProduct(
    String title,
    String description,
    double price,
    String image,
  ) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
          'https://www.eatthis.com/wp-content/uploads/2017/10/dark-chocolate-bar-squares-500x366.jpg',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
    };

    return http
        .post(
      'https://flutter-product-manager-ac339.firebaseio.com/products.json?auth=${_authenticatedUser.tokenId}',
      body: json.encode(productData),
    )
        .then((http.Response response) {
      if (response.statusCode != 200 && response.statusCode != 200) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
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
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<Null> fetchProducts() {
    _isLoading = true;
    notifyListeners();
    return http
        .get(
            'https://flutter-product-manager-ac339.firebaseio.com/products.json?auth=${_authenticatedUser.tokenId}')
        .then<Null>((http.Response response) {
      final List<Product> fetchedProductList = [];
      final Map<String, dynamic> productListData = json.decode(response.body);
      if (productListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      productListData.forEach((String productId, dynamic productData) {
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
      _isLoading = false;
      notifyListeners();
      _selProductId = null;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  void toggleProductFavoriteStatus() {
    final bool isCurrentFavorite = _products[selectedProductIndex].isFavorite;
    final bool newFavoriteStatus = !isCurrentFavorite;
    final Product updatedProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id,
        isFavorite: newFavoriteStatus);
    _products[selectedProductIndex] = updatedProduct;
    _selProductId = null;
    notifyListeners();
  }

  Future<bool> updateProduct(
      String title, String description, double price, String image) {
    _isLoading = true;
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'image':
          'https://www.eatthis.com/wp-content/uploads/2017/10/dark-chocolate-bar-squares-500x366.jpg',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
    };

    print(updateData);

    return http
        .put(
      'https://flutter-product-manager-ac339.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authenticatedUser.tokenId}',
      body: json.encode(updateData),
    )
        .then((http.Response response) {
      _isLoading = false;
      final Product updatedProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          price: price,
          image: image,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId);
      _products[selectedProductIndex] = updatedProduct;
      print(_products);
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<bool> deleteProduct() {
    _isLoading = true;
    final deletedProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    _selProductId = null;
    notifyListeners();
    return http
        .delete(
            "https://flutter-product-manager-ac339.firebaseio.com/products/${deletedProductId}.json?auth=${_authenticatedUser.tokenId}")
        .then((http.Response response) {
      _isLoading = false;
      print(_products);
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  void selectProduct(String productId) {
    print("Selecting product to id" + productId.toString());
    _selProductId = productId;
    notifyListeners();
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}

class UserModel extends ConnectedProductsModel {
  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };
    http.Response response;

    if (mode == AuthMode.Login) {
      response = await http.post(
        "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyDkfSPJi74UwycYx-_fghEek-D4qViXxv4",
        body: json.encode(
          authData,
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    } else if (mode == AuthMode.Signup) {
      response = await http.post(
        "https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyDkfSPJi74UwycYx-_fghEek-D4qViXxv4",
        body: json.encode(
          authData,
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    }

    print(json.decode(response.body));

    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String message = 'Authentication Failed';
    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Authentication Success';
      _authenticatedUser = User(
        id: responseData['localId'],
        email: email,
        tokenId: responseData['idToken'],
      );
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'Email not found.';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'Invalid Password.';
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'Email already exists.';
    }

    _isLoading = false;
    notifyListeners();
    return {
      'success': !hasError,
      'message': message,
    };
  }
}

class UtilityModel extends ConnectedProductsModel {
  bool get isLoading {
    return _isLoading;
  }
}
