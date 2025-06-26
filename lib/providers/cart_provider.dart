import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';

import '../models/menu_item.dart';

class CartProvider extends ChangeNotifier {
  final Cart _cart = Cart();

  Cart get cart => _cart;

  List<CartItem> get items => _cart.items;

  int get itemCount => _cart.totalItems;

  double get totalPrice => _cart.totalPrice;

  bool get isEmpty => _cart.isEmpty;

  bool get isNotEmpty => _cart.isNotEmpty;

  void addItem(MenuItem menuItem, {String? notes}) {
    _cart.addItem(menuItem, notes: notes);

    notifyListeners();
  }

  void removeItem(String menuItemId) {
    _cart.removeItem(menuItemId);

    notifyListeners();
  }

  void updateQuantity(String menuItemId, int quantity) {
    _cart.updateQuantity(menuItemId, quantity);

    notifyListeners();
  }

  void clearCart() {
    _cart.clear();

    notifyListeners();
  }

  // إضافة ملاحظة لعنصر معين

  void updateItemNotes(String menuItemId, String? notes) {
    final index =
        _cart.items.indexWhere((item) => item.menuItem.id == menuItemId);

    if (index >= 0) {
      // إنشاء عنصر جديد بالملاحظة المحدثة

      final oldItem = _cart.items[index];

      _cart.items[index] = CartItem(
        menuItem: oldItem.menuItem,
        quantity: oldItem.quantity,
        notes: notes,
      );

      notifyListeners();
    }
  }

  // حساب الوقت المتوقع للتحضير

  int get estimatedPreparationTime {
    if (_cart.items.isEmpty) return 0;

    return _cart.items
        .map((item) => item.menuItem.preparationTime)
        .reduce((max, time) => time > max ? time : max);
  }

  // الحصول على ملخص الطلب

  Map<String, dynamic> getOrderSummary() {
    return {
      'items': _cart.items.map((item) => item.toJson()).toList(),
      'total_price': _cart.totalPrice,
      'total_items': _cart.totalItems,
      'estimated_time': estimatedPreparationTime,
      'order_date': DateTime.now().toIso8601String(),
    };
  }
}
