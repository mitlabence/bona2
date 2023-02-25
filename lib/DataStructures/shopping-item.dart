class ShoppingItem {
  final String itemName;

  ShoppingItem({required this.itemName});

  @override
  String toString() {
    return itemName;
  }

  @override
  bool operator ==(Object other) {
    return other is ShoppingItem && itemName == other.itemName;
  }
}
