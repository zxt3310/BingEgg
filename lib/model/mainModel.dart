class FoodMaterial {
  final int id;
  final int itemId;
  final int boxId;
  final String itemName;
  final double quantity;
  final String createdAt;
  final String expiryDate;
  final String lastDateAdd;
  final int category;

  FoodMaterial(this.id, this.itemId, this.boxId, this.itemName, this.quantity,
      this.createdAt, this.expiryDate, this.lastDateAdd, this.category);
  FoodMaterial.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        itemId = json['item_id'],
        boxId = json['box_id'],
        itemName = json['item_name'],
        quantity = json['quantity'],
        createdAt = json['created_at'],
        expiryDate = json['expiry_date'],
        lastDateAdd = json['last_dateadd'],
        category = json['category_id'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'item_id': itemId,
        'box_id': boxId,
        'item_name': itemName,
        'quantity': quantity,
        'create_at': createdAt,
        'expiry_date': expiryDate,
        'last_dateadd': lastDateAdd,
        'category_id': category
      };

  String getRemindDate() {
    if (lastDateAdd == null) {
      return "";
    }
    DateTime create = DateTime.parse(lastDateAdd);
    if (expiryDate.isNotEmpty) {
      int days = 0;
      int hours = 0;
      DateTime expire = DateTime.parse(expiryDate);
      Duration duration = expire.difference(create);
      hours = duration.inHours;
      days = hours ~/ 24;
      if (days > 0) {
        return '$days天后过期';
      } else {
        return '$hours小时后过期';
      }
    } else {
      Duration duration = DateTime.now().difference(create);
      int days = duration.inDays;
      int hours = duration.inHours;
      return hours > 0 ? days > 0 ? '已放入$days天' : '已放入$hours小时' : '刚刚放入';
    }
  }
}

class Fridge {
  final int id;
  final String boxname;
  final bool isdefault;
  Fridge(this.id, this.boxname, this.isdefault);

  Fridge.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        boxname = json['box_name'],
        isdefault = json['is_default'] == 0 ? false : true;
}
