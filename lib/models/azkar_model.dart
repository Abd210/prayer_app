/// Represents a single Azkār item, with persistent state fields.
class AzkarModel {
  final String category;        // e.g. "Morning", "Evening"
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String reference;
  final String audioUrl;        // Not used in this audio-disabled version
  int counter;
  bool isFavorite;
  bool isExpanded;

  AzkarModel({
    required this.category,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.reference,
    required this.audioUrl,
    this.counter = 0,
    this.isFavorite = false,
    this.isExpanded = false,
  });
}
