// import 'dart:async';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:percent_indicator/percent_indicator.dart';
// import 'package:confetti/confetti.dart';

// // Example: your data imports
// import 'package:prayer/models/azakdata.dart';

// ///
// /// ──────────────────────────────────────────────────────────────────────────────
// ///  0) Wave Background (Now Themed)
// /// ──────────────────────────────────────────────────────────────────────────────
// ///
// /// This widget animates one or more "waves" across the screen using
// /// a custom painter. Instead of forcing green, we now adapt to the theme.
// ///
// class AnimatedWaveBackground extends StatefulWidget {
//   final Widget child;

//   const AnimatedWaveBackground({Key? key, required this.child})
//       : super(key: key);

//   @override
//   _AnimatedWaveBackgroundState createState() => _AnimatedWaveBackgroundState();
// }

// class _AnimatedWaveBackgroundState extends State<AnimatedWaveBackground>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _waveController;

//   @override
//   void initState() {
//     super.initState();
//     // This controller will run indefinitely and rebuild the painter every frame
//     _waveController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 5),
//     )..repeat(); // loop forever
//   }

//   @override
//   void dispose() {
//     _waveController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return AnimatedBuilder(
//       animation: _waveController,
//       builder: (context, child) {
//         return CustomPaint(
//           painter: _GreenWavePainter(
//             waveValue: _waveController.value,
//             // Use the theme’s primary color at ~15% opacity:
//             waveColor: theme.colorScheme.primary.withOpacity(0.15),
//           ),
//           child: child,
//         );
//       },
//       child: widget.child,
//     );
//   }
// }

// class _GreenWavePainter extends CustomPainter {
//   final double waveValue;
//   final Color waveColor;

//   _GreenWavePainter({
//     required this.waveValue,
//     required this.waveColor,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = waveColor
//       ..style = PaintingStyle.fill;

//     // We will draw 2 or 3 waves at different phases or amplitudes
//     _drawWave(canvas, size, paint, amplitude: 20, speed: 1.0, yOffset: 0);
//     _drawWave(canvas, size, paint, amplitude: 25, speed: 1.5, yOffset: 30);
//     _drawWave(canvas, size, paint, amplitude: 15, speed: 2.0, yOffset: 60);
//   }

//   void _drawWave(Canvas canvas, Size size, Paint paint,
//       {double amplitude = 20, double speed = 1.0, double yOffset = 0}) {
//     final path = Path();
//     final double waveWidth = size.width;
//     final double waveHeight = size.height;

//     // Start from bottom-left
//     path.moveTo(0, waveHeight);
//     // Create a wave from left to right
//     for (double x = 0; x <= waveWidth; x++) {
//       double y = amplitude *
//               math.sin((x / waveWidth * 2 * math.pi * speed) +
//                   (waveValue * 2 * math.pi * speed)) +
//           (waveHeight - 100 - yOffset);
//       path.lineTo(x, y);
//     }
//     // Down to bottom-right corner
//     path.lineTo(waveWidth, waveHeight);
//     // Close the shape
//     path.close();
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(_GreenWavePainter oldDelegate) => true;
// }

// ///
// /// ──────────────────────────────────────────────────────────────────────────────
// ///  AZKAR & TASBIH ADVANCED PAGE
// /// ──────────────────────────────────────────────────────────────────────────────
// ///
// class AzkarAndTasbihAdvancedPage extends StatefulWidget {
//   const AzkarAndTasbihAdvancedPage({Key? key}) : super(key: key);

//   @override
//   State<AzkarAndTasbihAdvancedPage> createState() =>
//       _AzkarAndTasbihAdvancedPageState();
// }

// class _AzkarAndTasbihAdvancedPageState
//     extends State<AzkarAndTasbihAdvancedPage> with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     // Two tabs: "Azkar" & "Tasbih"
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Azkar & Tasbih'),
//           bottom: TabBar(
//             controller: _tabController,
//             labelColor: Colors.white, // ensure text of selected tab is white
//             unselectedLabelColor: Colors.white, // ensure text of unselected tab is white
//             tabs: const [
//               Tab(icon: Icon(Icons.menu_book), text: 'Azkar'),
//               Tab(icon: Icon(Icons.fingerprint), text: 'Tasbih'),
//             ],
//           ),
//         ),
//         body: AnimatedWaveBackground(
//           child: TabBarView(
//             controller: _tabController,
//             children: const [
//               _AzkarMenuPage(),
//               TasbihAdvancedPage(),
//             ],
//           ),
//         ),
//         backgroundColor: theme.scaffoldBackgroundColor,
//       ),
//     );
//   }
// }

// ///
// /// ──────────────────────────────────────────────────────────────────────────────
// ///  1) AZKAR MENU PAGE
// /// ──────────────────────────────────────────────────────────────────────────────
// class _AzkarMenuPage extends StatefulWidget {
//   const _AzkarMenuPage();

//   @override
//   State<_AzkarMenuPage> createState() => _AzkarMenuPageState();
// }

// class _AzkarMenuPageState extends State<_AzkarMenuPage> {
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         children: [
//           _AzkarCard(
//             title: 'Morning Azkar',
//             subtitle: 'أذكار الصباح',
//             color: theme.colorScheme.primary,
//             icon: Icons.sunny_snowing,
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => AzkarReadingPage(
//                     title: 'Morning Azkar',
//                     items: morningAdhkar, // from azakdata.dart
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 20),
//           _AzkarCard(
//             title: 'Evening Azkar',
//             subtitle: 'أذكار المساء',
//             color: theme.colorScheme.secondary,
//             icon: Icons.nights_stay_outlined,
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => AzkarReadingPage(
//                     title: 'Evening Azkar',
//                     items: eveningAdhkar, // from azakdata.dart
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 20),
//           _AzkarCard(
//             title: 'Sleep Azkar',
//             subtitle: 'أذكار النوم',
//             color: Colors.teal,
//             icon: Icons.bed,
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => AzkarReadingPage(
//                     title: 'Sleep Azkar',
//                     items: sleepAzkar, // from azakdata.dart
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 20),
//           _AzkarCard(
//             title: 'Waking Up Azkar',
//             subtitle: 'أذكار الاستيقاظ',
//             color: Colors.deepPurple,
//             icon: Icons.wb_sunny_outlined,
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => AzkarReadingPage(
//                     title: 'Waking Up Azkar',
//                     items: wakingUpAzkar, // from azakdata.dart
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 20),
//           _AzkarCard(
//             title: 'After Prayers',
//             subtitle: 'أذكار بعد الصلاة',
//             color: Colors.indigo,
//             icon: Icons.done_all,
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => AzkarReadingPage(
//                     title: 'After Prayers Azkar',
//                     items: afterPrayersAzkar, // from azakdata.dart
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 20),
//           _AzkarCard(
//             title: 'Surah Al-Mulk',
//             subtitle: 'سورة الملك',
//             color: Colors.redAccent,
//             icon: Icons.book_outlined,
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => AzkarReadingPage(
//                     title: 'Surah Al-Mulk',
//                     items: surahAlMulkAzkar, // from azakdata.dart
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 20),
//           _AzkarCard(
//             title: 'Surah Yaseen',
//             subtitle: 'سورة يس',
//             color: Colors.orange,
//             icon: Icons.book,
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => AzkarReadingPage(
//                     title: 'Surah Yaseen',
//                     items: surahYaseenAzkar, // from azakdata.dart
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// A neat card for "Morning" / "Evening" / Sleep, etc.
// class _AzkarCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final Color color;
//   final IconData icon;
//   final VoidCallback onTap;

//   const _AzkarCard({
//     required this.title,
//     required this.subtitle,
//     required this.color,
//     required this.icon,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: color.withOpacity(0.85),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 6,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Row(
//             children: [
//               Icon(icon, color: Colors.white, size: 36),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 20,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       subtitle,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         color: Colors.white70,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Icon(Icons.arrow_forward_ios, color: Colors.white70),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// ///
// /// ──────────────────────────────────────────────────────────────────────────────
// ///  2) TASBIH PAGE (ADVANCED)
// ///      - 4 counters: 1 global & 3 named
// /// ──────────────────────────────────────────────────────────────────────────────
// class TasbihAdvancedPage extends StatefulWidget {
//   const TasbihAdvancedPage({Key? key}) : super(key: key);

//   @override
//   State<TasbihAdvancedPage> createState() => _TasbihAdvancedPageState();
// }

// class _TasbihAdvancedPageState extends State<TasbihAdvancedPage> {
//   // Main “global” tasbih
//   int globalCount = 0;
//   final int globalTarget = 99; // for example

//   // Additional counters
//   int countSubhanallah = 0;
//   int countAlhamdulillah = 0;
//   int countAllahuAkbar = 0;
//   final int eachTarget = 33; // typical tasbih counts

//   void _incrementGlobal() {
//     setState(() {
//       if (globalCount < globalTarget) {
//         globalCount++;
//       }
//     });
//   }

//   void _incrementSubhanallah() {
//     setState(() {
//       if (countSubhanallah < eachTarget) {
//         countSubhanallah++;
//       }
//     });
//   }

//   void _incrementAlhamdulillah() {
//     setState(() {
//       if (countAlhamdulillah < eachTarget) {
//         countAlhamdulillah++;
//       }
//     });
//   }

//   void _incrementAllahuAkbar() {
//     setState(() {
//       if (countAllahuAkbar < eachTarget) {
//         countAllahuAkbar++;
//       }
//     });
//   }

//   void _resetAll() {
//     setState(() {
//       globalCount = 0;
//       countSubhanallah = 0;
//       countAlhamdulillah = 0;
//       countAllahuAkbar = 0;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final mainFraction = (globalCount / globalTarget).clamp(0.0, 1.0);
//     final subFraction1 = (countSubhanallah / eachTarget).clamp(0.0, 1.0);
//     final subFraction2 = (countAlhamdulillah / eachTarget).clamp(0.0, 1.0);
//     final subFraction3 = (countAllahuAkbar / eachTarget).clamp(0.0, 1.0);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Tasbih Advanced')),
//       body: AnimatedWaveBackground(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               children: [
//                 //
//                 // ────────── Global Tasbih ──────────
//                 //
//                 const Text(
//                   'Global Tasbih',
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 GestureDetector(
//                   onTap: _incrementGlobal,
//                   behavior: HitTestBehavior.opaque,
//                   child: Container(
//                     width: double.infinity,
//                     height: 270,
//                     decoration: BoxDecoration(
//                       color: theme.colorScheme.primary.withOpacity(0.06),
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Center(
//                       child: CircularPercentIndicator(
//                         radius: 80.0,
//                         lineWidth: 12.0,
//                         animation: true,
//                         animationDuration: 300,
//                         animateFromLastPercent: true,
//                         percent: mainFraction,
//                         center: Text(
//                           '$globalCount / $globalTarget',
//                           style: const TextStyle(
//                             fontSize: 26,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         progressColor: theme.colorScheme.primary,
//                         backgroundColor:
//                             theme.colorScheme.primary.withOpacity(0.2),
//                         circularStrokeCap: CircularStrokeCap.round,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 //
//                 // ────────── Sub Counters ──────────
//                 //
//                 const Text(
//                   'Sub-Counters',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _buildSmallTasbihBox(
//                       context,
//                       title: 'SubḥānAllāh',
//                       count: countSubhanallah,
//                       target: eachTarget,
//                       fraction: subFraction1,
//                       onTap: _incrementSubhanallah,
//                     ),
//                     _buildSmallTasbihBox(
//                       context,
//                       title: 'Al-ḥamdu lillāh',
//                       count: countAlhamdulillah,
//                       target: eachTarget,
//                       fraction: subFraction2,
//                       onTap: _incrementAlhamdulillah,
//                     ),
//                     _buildSmallTasbihBox(
//                       context,
//                       title: 'Allāhu Akbar',
//                       count: countAllahuAkbar,
//                       target: eachTarget,
//                       fraction: subFraction3,
//                       onTap: _incrementAllahuAkbar,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 30),
//                 ElevatedButton.icon(
//                   onPressed: _resetAll,
//                   icon: const Icon(Icons.refresh),
//                   label: const Text(
//                     'Reset All',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 30,
//                       vertical: 12,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Tap the main box for a global count.\n'
//                   'Tap any sub box for specific counts (33 each).',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSmallTasbihBox(
//     BuildContext context, {
//     required String title,
//     required int count,
//     required int target,
//     required double fraction,
//     required VoidCallback onTap,
//   }) {
//     final theme = Theme.of(context);
//     return GestureDetector(
//       onTap: onTap,
//       behavior: HitTestBehavior.opaque,
//       child: Container(
//         width: 110,
//         height: 140,
//         decoration: BoxDecoration(
//           color: theme.colorScheme.primary.withOpacity(0.07),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularPercentIndicator(
//               radius: 32.0,
//               lineWidth: 6.0,
//               animation: true,
//               animationDuration: 300,
//               animateFromLastPercent: true,
//               percent: fraction,
//               center: Text(
//                 '$count',
//                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               progressColor: theme.colorScheme.secondary,
//               backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
//               circularStrokeCap: CircularStrokeCap.round,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 height: 1.3,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ///
// /// ──────────────────────────────────────────────────────────────────────────────
// ///  AZKAR READING PAGE
// /// ──────────────────────────────────────────────────────────────────────────────
// ///
// /// Displays each Dhikr in a horizontally-swipeable manner with:
// ///  - A top linear progress bar for overall completion (how many dhikr done).
// ///  - Each dhikr has a circular indicator that animates from the last percent.
// ///  - Confetti on the final item, then a completion dialog.
// ///  - Copy-to-clipboard button for the Arabic text.
// ///  - Display Style Toggle: Switch between "Compact" vs "Expanded".
// ///
// class AzkarReadingPage extends StatefulWidget {
//   final String title;
//   final List<DhikrItem> items;

//   const AzkarReadingPage({
//     Key? key,
//     required this.title,
//     required this.items,
//   }) : super(key: key);

//   @override
//   State<AzkarReadingPage> createState() => _AzkarReadingPageState();
// }

// class _AzkarReadingPageState extends State<AzkarReadingPage> {
//   late PageController _pageController;
//   late List<int> currentCounts;
//   late ConfettiController _confettiCtrl;

//   bool _compactView = false; // toggles card spacing / style

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     currentCounts = List.filled(widget.items.length, 0);
//     _confettiCtrl = ConfettiController(duration: const Duration(seconds: 2));
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _confettiCtrl.dispose();
//     super.dispose();
//   }

//   int get completedItemsCount {
//     int c = 0;
//     for (int i = 0; i < widget.items.length; i++) {
//       if (currentCounts[i] == widget.items[i].repeat) {
//         c++;
//       }
//     }
//     return c;
//   }

//   double get overallFraction {
//     return (completedItemsCount / widget.items.length).clamp(0.0, 1.0);
//   }

//   void _incrementCount(int index) {
//     setState(() {
//       if (currentCounts[index] < widget.items[index].repeat) {
//         currentCounts[index]++;
//       }
//       if (currentCounts[index] == widget.items[index].repeat) {
//         // If finished this dhikr
//         if (index < widget.items.length - 1) {
//           _pageController.nextPage(
//             duration: const Duration(milliseconds: 400),
//             curve: Curves.easeInOut,
//           );
//         } else {
//           // last one
//           _confettiCtrl.play();
//           Future.delayed(const Duration(milliseconds: 1500), () {
//             _showCompletionDialog();
//           });
//         }
//       }
//     });
//   }

//   void _showCompletionDialog() async {
//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text('${widget.title} Completed!'),
//         content: const Text('You have finished all azkār in this category.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//     Navigator.pop(context);
//   }

//   // Copy to clipboard logic
//   void _copyAzkarText(String text) {
//     Clipboard.setData(ClipboardData(text: text));
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Azkar text copied to clipboard!')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//         actions: [
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               setState(() => _compactView = (value == 'Compact'));
//             },
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: 'Compact',
//                 child: Text('Compact View'),
//               ),
//               const PopupMenuItem(
//                 value: 'Expanded',
//                 child: Text('Expanded View'),
//               ),
//             ],
//             icon: const Icon(Icons.view_list_outlined),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // Wave background (adapted to theme)
//           AnimatedWaveBackground(
//             child: Column(
//               children: [
//                 // top linear progress
//                 LinearPercentIndicator(
//                   lineHeight: 6.0,
//                   animation: true,
//                   animationDuration: 300,
//                   animateFromLastPercent: true,
//                   percent: overallFraction,
//                   progressColor: theme.colorScheme.primary,
//                   backgroundColor:
//                       theme.colorScheme.primary.withOpacity(0.2),
//                   padding: EdgeInsets.zero,
//                 ),
//                 // main content: PageView
//                 Expanded(
//                   child: PageView.builder(
//                     controller: _pageController,
//                     physics: const BouncingScrollPhysics(),
//                     itemCount: widget.items.length,
//                     itemBuilder: (context, index) {
//                       final item = widget.items[index];
//                       final count = currentCounts[index];
//                       final required = item.repeat;
//                       final fraction = (count / required).clamp(0.0, 1.0);

//                       return GestureDetector(
//                         onTap: () => _incrementCount(index),
//                         behavior: HitTestBehavior.opaque,
//                         child: Container(
//                           padding: EdgeInsets.all(_compactView ? 8.0 : 16.0),
//                           child: Center(
//                             child: Card(
//                               elevation: 8,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Container(
//                                 width: double.infinity,
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: _compactView ? 16 : 20,
//                                   vertical: _compactView ? 20 : 30,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(20),
//                                   color: Colors.white.withOpacity(0.9),
//                                 ),
//                                 child: SingleChildScrollView(
//                                   child: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       // Arabic text
//                                       Directionality(
//                                         textDirection: TextDirection.rtl,
//                                         child: Text(
//                                           item.arabic,
//                                           textAlign: TextAlign.center,
//                                           style: TextStyle(
//                                             fontSize: _compactView ? 18 : 20,
//                                             height: 1.6,
//                                             color:
//                                                 theme.colorScheme.onSurface,
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(height: 12),
//                                       // translation or short note
//                                       Text(
//                                         item.translation,
//                                         textAlign: TextAlign.justify,
//                                         style: TextStyle(
//                                           fontSize: _compactView ? 14 : 15,
//                                           fontStyle: FontStyle.italic,
//                                           color: Colors.black54,
//                                           height: 1.4,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 20),
//                                       // circular progress
//                                       CircularPercentIndicator(
//                                         radius: _compactView ? 50 : 60,
//                                         lineWidth: _compactView ? 6 : 8,
//                                         animation: true,
//                                         animationDuration: 300,
//                                         animateFromLastPercent: true,
//                                         percent: fraction,
//                                         center: Text(
//                                           '$count / $required',
//                                           style: TextStyle(
//                                             fontSize: _compactView ? 16 : 18,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         progressColor:
//                                             theme.colorScheme.primary,
//                                         backgroundColor:
//                                             theme.colorScheme.primary
//                                                 .withOpacity(0.2),
//                                         circularStrokeCap:
//                                             CircularStrokeCap.round,
//                                       ),
//                                       const SizedBox(height: 10),
//                                       // Copy to clipboard button
//                                       TextButton.icon(
//                                         onPressed: () =>
//                                             _copyAzkarText(item.arabic),
//                                         icon: const Icon(Icons.copy),
//                                         label: const Text('Copy'),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       // A small reminder
//                                       const Text(
//                                         'Tap Anywhere to Count',
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 10),
//                                       if (!_compactView)
//                                         const Text(
//                                           'Remembrance of Allah is the greatest (Qur\'an 29:45).',
//                                           textAlign: TextAlign.center,
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             fontStyle: FontStyle.italic,
//                                             color: Colors.grey,
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Confetti overlay
//           Align(
//             alignment: Alignment.center,
//             child: ConfettiWidget(
//               confettiController: _confettiCtrl,
//               blastDirectionality: BlastDirectionality.explosive,
//               shouldLoop: false,
//               numberOfParticles: 25,
//               colors: const [
//                 Colors.green,
//                 Colors.blue,
//                 Colors.pink,
//                 Colors.orange
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
