
/// Contains the name of the item.
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

  ShoppingItem operator +(ShoppingItem other) {
    /// Adding two ShoppingItems should only happen when the second is not a true
    /// shopping item (i.e. merging). Thus the itemName of the other ShoppingItem
    /// should be discarded.
    return ShoppingItem(itemName: itemName);
  }

  ShoppingItem operator -(ShoppingItem other){
    return ShoppingItem(itemName: itemName);
  }
}
