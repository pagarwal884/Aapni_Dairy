class MilkEntry {
  String? id; // MongoDB _id
  int customerCid;
  String entryDate;
  String shift;
  double quantity;
  double fat;
  double snf;
  double rate;
  double totalAmount;
  double snfK;

  MilkEntry({
    this.id,
    required this.customerCid,
    required this.entryDate,
    required this.shift,
    required this.quantity,
    required this.fat,
    this.snf = 8.5,
    this.rate = 0.0,
    this.totalAmount = 0.0,
    this.snfK = 0.0,
  });

  factory MilkEntry.fromMap(Map<String, dynamic> map) {
    double safeToDouble(dynamic value, double defaultValue) {
      if (value == null) return defaultValue;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    }

    return MilkEntry(
      id: map['_id'],
      customerCid: map['customerCid'] is int ? map['customerCid'] : 0,
      entryDate: map['entryDate']?.toString() ?? '',
      shift: map['shift'] ?? '',
      quantity: safeToDouble(map['quantity'], 0.0),
      fat: safeToDouble(map['fat'], 0.0),
      snf: safeToDouble(map['snf'], 8.5),
      rate: safeToDouble(map['rate'], 0.0),
      totalAmount: safeToDouble(map['total_amount'], 0.0),
      snfK: safeToDouble(map['SNF_K'], 0.0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer_c_id': customerCid,
      'entryDate': entryDate,
      'shift': shift,
      'quantity': quantity,
      'fat': fat,
      'snf': snf,
      'rate': rate,
      'total_amount': totalAmount,
      'SNF_K': snfK,
    };
  }
}
