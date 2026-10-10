// Modelo de item da lista de compras
class ShoppingListItem {
  final int id;
  final String title;
  final String? author;
  final double price;
  final bool bought;

  const ShoppingListItem({
    required this.id,
    required this.title,
    this.author,
    required this.price,
    required this.bought,
  });

  // Converte o JSON da API em um objeto ShoppingListItem
  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      id: json['id'] as int,
      title: json['title'] as String,
      author: json['author'] as String?,
      price: (json['price'] as num).toDouble(),
      bought: json['bought'] as bool,
    );
  }

  // Converte o objeto ShoppingListItem em JSON
  Map<String, dynamic> toJson() {
    return {'title': title, 'author': author, 'price': price, 'bought': bought};
  }
}
