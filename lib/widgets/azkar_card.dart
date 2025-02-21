// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/azkar_model.dart';
// import '../pages/azkar_detail_page.dart';

// class AzkarCard extends StatefulWidget {
//   final AzkarModel azkar;
//   const AzkarCard({Key? key, required this.azkar}) : super(key: key);

//   @override
//   State<AzkarCard> createState() => _AzkarCardState();
// }

// class _AzkarCardState extends State<AzkarCard> {
//   late SharedPreferences _prefs;

//   @override
//   void initState() {
//     super.initState();
//     _loadState();
//   }

//   Future<void> _loadState() async {
//     _prefs = await SharedPreferences.getInstance();
//     final savedCount = _prefs.getInt(widget.azkar.title) ?? widget.azkar.counter;
//     final savedFav = _prefs.getBool('${widget.azkar.title}_fav') ?? widget.azkar.isFavorite;
//     setState(() {
//       widget.azkar.counter = savedCount;
//       widget.azkar.isFavorite = savedFav;
//     });
//   }

//   Future<void> _incrementCounter() async {
//     setState(() {
//       widget.azkar.counter++;
//     });
//     await _prefs.setInt(widget.azkar.title, widget.azkar.counter);
//   }

//   Future<void> _toggleFavorite() async {
//     setState(() {
//       widget.azkar.isFavorite = !widget.azkar.isFavorite;
//     });
//     await _prefs.setBool('${widget.azkar.title}_fav', widget.azkar.isFavorite);
//   }

//   void _toggleExpand() {
//     setState(() {
//       widget.azkar.isExpanded = !widget.azkar.isExpanded;
//     });
//   }

//   void _openDetail() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AzkarDetailPage(azkar: widget.azkar),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 3,
//       child: InkWell(
//         onTap: _openDetail,
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               /// Header row: title and favorite icon.
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       widget.azkar.title,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: theme.colorScheme.primary,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: _toggleFavorite,
//                     icon: Icon(
//                       widget.azkar.isFavorite ? Icons.favorite : Icons.favorite_border,
//                       color: Colors.redAccent,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),

//               /// Arabic text preview
//               Text(
//                 widget.azkar.arabic,
//                 textAlign: TextAlign.right,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: theme.colorScheme.onBackground,
//                 ),
//               ),
//               const SizedBox(height: 8),

//               /// Counter row and expand icon
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Count: ${widget.azkar.counter}',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: theme.colorScheme.onBackground,
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       IconButton(
//                         onPressed: _incrementCounter,
//                         icon: Icon(Icons.add_circle, color: theme.colorScheme.primary),
//                       ),
//                       IconButton(
//                         onPressed: _toggleExpand,
//                         icon: Icon(
//                           widget.azkar.isExpanded ? Icons.expand_less : Icons.expand_more,
//                           color: theme.colorScheme.primary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),

//               /// Expanded details
//               AnimatedCrossFade(
//                 firstChild: const SizedBox.shrink(),
//                 secondChild: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Divider(),
//                     Text(
//                       widget.azkar.transliteration,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: theme.colorScheme.onBackground,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       widget.azkar.translation,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: theme.colorScheme.onBackground.withOpacity(0.8),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Reference: ${widget.azkar.reference}',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontStyle: FontStyle.italic,
//                         color: theme.colorScheme.onSurface.withOpacity(0.7),
//                       ),
//                     ),
//                   ],
//                 ),
//                 crossFadeState:
//                     widget.azkar.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
//                 duration: const Duration(milliseconds: 300),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
