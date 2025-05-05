/// Represents a single Azkār item, with persistent state fields.
class AzkarModel {
  final String id;
  final String text;           // Main text/title for display
  final String textAr;         // Arabic text
  final String category;       // e.g. "Morning", "Evening"
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String reference;
  final String audioUrl;       // Not used in this audio-disabled version
  final int count;             // How many repetitions
  int counter;
  bool isFavorite;
  bool isExpanded;

  AzkarModel({
    required this.id,
    required this.text,
    required this.textAr,
    this.category = "",
    this.title = "",
    this.arabic = "",
    this.transliteration = "",
    this.translation = "",
    this.reference = "",
    this.audioUrl = "",
    required this.count,
    this.counter = 0,
    this.isFavorite = false,
    this.isExpanded = false,
  });
}
