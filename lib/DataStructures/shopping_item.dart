
/// Contains the name of the item.
class ItemCategory {
  final String itemName;

  ItemCategory({required this.itemName});

  @override
  String toString() {
    return itemName;
  }

  ItemCategory.empty() :
      itemName = "";

  @override
  bool get isEmpty => itemName.isEmpty;


  @override
  bool operator ==(Object other) {
    return other is ItemCategory && itemName == other.itemName;
  }

  ItemCategory operator +(ItemCategory other) {
    /// Adding two ShoppingItems should only happen when the second is not a true
    /// shopping item (i.e. merging). Thus the itemName of the other ShoppingItem
    /// should be discarded.
    return ItemCategory(itemName: itemName);
  }

  ItemCategory operator -(ItemCategory other){
    return ItemCategory(itemName: itemName);
  }
}
