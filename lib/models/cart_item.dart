import 'menu_item.dart';

class CartItem {
  final MenuItem menuItem;
  int quantity;
  final String? notes;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
    this.notes,
  });

  double get totalPrice => menuItem.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'menu_item': menuItem.toJson(),
      'quantity': quantity,
      'notes': notes,
      'total_price': totalPrice,
    };
  }
}

class Cart {
  final List<CartItem> items = [];

  void addItem(MenuItem menuItem, {String? notes}) {
    final existingIndex = items.indexWhere(
      (item) => item.menuItem.id == menuItem.id && item.notes == notes,
    );

    if (existingIndex >= 0) {
      items[existingIndex].quantity++;
    } else {
      items.add(CartItem(menuItem: menuItem, notes: notes));
    }
  }

  void removeItem(String menuItemId) {
    items.removeWhere((item) => item.menuItem.id == menuItemId);
  }

  void updateQuantity(String menuItemId, int quantity) {
    final index = items.indexWhere((item) => item.menuItem.id == menuItemId);
    if (index >= 0) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index].quantity = quantity;
      }
    }
  }

  void clear() {
    items.clear();
  }

  double get totalPrice => items.fold(0, (sum, item) => sum + item.totalPrice);

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}
