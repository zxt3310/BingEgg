

String jsonStr = '[{"id": 1, "item_id": null, "item_name": "\u9e21\u86cb", "quantity": 24, "created_at": "2019-12-08 06:23:49"}, {"id": 2, "item_id": null, "item_name": "\u652f\u4e0b", "quantity": 20, "created_at": "2019-12-08 07:36:28"}, {"id": 3, "item_id": null, "item_name": "\u852c\u83dc", "quantity": 20, "created_at": "2019-12-08 07:37:27"}, {"id": 5, "item_id": null, "item_name": "\u9e21", "quantity": 1, "created_at": "2019-12-08 13:36:15"}, {"id": 6, "item_id": null, "item_name": "\u8304\u5b50", "quantity": 4, "created_at": "2019-12-08 13:36:24"}, {"id": 7, "item_id": null, "item_name": "\u72d7", "quantity": 3, "created_at": "2019-12-08 13:49:16"}, {"id": 9, "item_id": null, "item_name": "\u80e1\u841d\u535c", "quantity": 1, "created_at": "2019-12-10 02:15:37"}, {"id": 10, "item_id": null, "item_name": "\u9999\u8549", "quantity": 1, "created_at": "2019-12-11 11:08:18"}]';

// void main(){
//   var a = json.decode(jsonStr);
//   FoodMaterial food = FoodMaterial.fromJson(json.decode(jsonStr));
//   print(food.id);
// }

// class FoodMaterial {
//   final int id;
//   final int itemId;
//   final String itemName;
//   final int quantity;
//   final String createdAt;

//   FoodMaterial(
//       this.id, this.itemId, this.itemName, this.quantity, this.createdAt);
//   FoodMaterial.fromJson(Map<String, dynamic> json)
//       : id = json['id'],
//         itemId = json['item_id'],
//         itemName = json['item_name'],
//         quantity = json['quantity'],
//         createdAt = json['created_at'];

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'item_id': itemId,
//         'item_name': itemName,
//         'quantity': quantity,
//         'create_at': createdAt
//       };
  
// }