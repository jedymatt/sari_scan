// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Product {
  final int? id;
  final String name;
  final num price;
  final String barcode;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.barcode,
  });

  Product copyWith({
    int? id,
    String? name,
    num? price,
    String? barcode,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      barcode: barcode ?? this.barcode,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'price': price,
      'barcode': barcode,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'] as String,
      price: map['price'] as num,
      barcode: map['barcode'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, barcode: $barcode)';
  }

  @override
  bool operator ==(covariant Product other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.price == price &&
        other.barcode == barcode;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ price.hashCode ^ barcode.hashCode;
  }
}

enum UtangType { debt, payment }

double balanceOf(Iterable<UtangEntry> entries) {
  var total = 0.0;
  for (final e in entries) {
    total += e.type == UtangType.debt ? e.amount : -e.amount;
  }
  return total;
}

class Customer {
  final int? id;
  final String name;
  final String? phone;
  final DateTime? deletedAt;
  final DateTime? createdAt;

  Customer({
    this.id,
    required this.name,
    this.phone,
    this.deletedAt,
    this.createdAt,
  });

  bool get isTrashed => deletedAt != null;

  Customer copyWith({
    int? id,
    String? name,
    String? phone,
    DateTime? deletedAt,
    DateTime? createdAt,
    bool clearPhone = false,
    bool clearDeletedAt = false,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: clearPhone ? null : (phone ?? this.phone),
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class UtangEntry {
  final int? id;
  final int customerId;
  final UtangType type;
  final double amount;
  final String? note;
  final DateTime? createdAt;

  UtangEntry({
    this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    this.note,
    this.createdAt,
  });
}

class CustomerWithBalance {
  final Customer customer;
  final double balance;

  CustomerWithBalance({required this.customer, required this.balance});
}
