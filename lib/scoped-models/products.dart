import 'package:scoped_model/scoped_model.dart';

import '../models/product.dart';

class ProductsModel extends Model {
  List<Product> _products = [];
  int _selectedProductIndex;

  int get selectedProductIndex {
    return _selectedProductIndex;
  }

  List<Product> get products {
    return List.from(_products);
  }

  Product get selectedProduct {
    if (_selectedProductIndex == null) return null;
    return _products[_selectedProductIndex];
  }

  void addProduct(Product product) {
    _products.add(product);
    _selectedProductIndex = null;
    print(_products);
    notifyListeners();
  }

  void toggleProductFavoriteStatus() {
    final bool isCurrentFavorite = products[_selectedProductIndex].isFavorite;
    final bool newFavoriteStatus = !isCurrentFavorite;
    final Product updatedProduct = Product(
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        isFavorite: newFavoriteStatus);
    _products[_selectedProductIndex] = updatedProduct;
    _selectedProductIndex = null;
    notifyListeners();
  }

  void updateProduct(Product product) {
    _products[_selectedProductIndex] = product;
    _selectedProductIndex = null;
    print(_products);
    notifyListeners();
  }

  void deleteProduct() {
    _products.removeAt(_selectedProductIndex);
    _selectedProductIndex = null;
    print(_products);
    notifyListeners();
  }

  void selectProduct(int index) {
    _selectedProductIndex = index;
  }
}
