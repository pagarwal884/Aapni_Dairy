class Customer {
  String? id; // MongoDB _id
  String name;
  int? localID; // optional local ID

  Customer({this.id, required this.name, this.localID});

  // Factory constructor to create Customer from Map
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['_id']?.toString(), // ensure it's string
      name: map['c_name'] ?? '',
      localID: map['c_id'],       // optional localID
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'c_name': name,
      'c_id': localID,
    };
  }
}
