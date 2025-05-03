import 'dart:convert';

class CustomAzkar {
  final String id;
  final String title;
  final String arabicTitle;
  final List<CustomDhikrItem> items;
  final String? color;
  final String? icon;

  CustomAzkar({
    required this.id,
    required this.title,
    required this.arabicTitle,
    required this.items,
    this.color,
    this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'arabicTitle': arabicTitle,
      'items': items.map((item) => item.toJson()).toList(),
      'color': color,
      'icon': icon,
    };
  }

  factory CustomAzkar.fromJson(Map<String, dynamic> json) {
    return CustomAzkar(
      id: json['id'],
      title: json['title'],
      arabicTitle: json['arabicTitle'],
      items: (json['items'] as List)
          .map((item) => CustomDhikrItem.fromJson(item))
          .toList(),
      color: json['color'],
      icon: json['icon'],
    );
  }

  CustomAzkar copyWith({
    String? id,
    String? title,
    String? arabicTitle,
    List<CustomDhikrItem>? items,
    String? color,
    String? icon,
  }) {
    return CustomAzkar(
      id: id ?? this.id,
      title: title ?? this.title,
      arabicTitle: arabicTitle ?? this.arabicTitle,
      items: items ?? this.items,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
}

class CustomDhikrItem {
  final String id;
  final String arabic;
  final String translation;
  final int repeat;

  CustomDhikrItem({
    required this.id,
    required this.arabic,
    required this.translation,
    required this.repeat,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabic': arabic,
      'translation': translation,
      'repeat': repeat,
    };
  }

  factory CustomDhikrItem.fromJson(Map<String, dynamic> json) {
    return CustomDhikrItem(
      id: json['id'],
      arabic: json['arabic'],
      translation: json['translation'],
      repeat: json['repeat'],
    );
  }

  CustomDhikrItem copyWith({
    String? id,
    String? arabic,
    String? translation,
    int? repeat,
  }) {
    return CustomDhikrItem(
      id: id ?? this.id,
      arabic: arabic ?? this.arabic,
      translation: translation ?? this.translation,
      repeat: repeat ?? this.repeat,
    );
  }
} 