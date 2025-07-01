// Step 1: Define the Item model in item.dart

// This class represents a single product item from the catalog
class Item {
  final String id; // Unique identifier for the item
  final String name; // Display name of the item
  final double price; // Price of the item before tax or discount
  final String image; // Image URL for the item

  // Constructor to initialize all required fields
  Item({required this.id, required this.name, required this.price, required this.image});

  // Factory constructor to create Item from a JSON object
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'], // Assign 'id' from JSON
      name: json['name'], // Assign 'name' from JSON
      price: (json['price'] as num).toDouble(), // Convert 'price' to double
      image: json['image'] ?? '', // Assign 'image' from JSON or default to empty
    );
  }

  // Convert the Item instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include item ID
      'name': name, // Include item name
      'price': price, // Include item price
      'image': image, // Include item image
    };
  }
}
