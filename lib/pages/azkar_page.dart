import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:confetti/confetti.dart';

///
/// ──────────────────────────────────────────────────────────────────────────────
///  DATA MODEL
/// ──────────────────────────────────────────────────────────────────────────────
///
class DhikrItem {
  final String arabic;       // Full Arabic text
  final String translation;  // Short English translation
  final int repeat;          // How many times

  DhikrItem({
    required this.arabic,
    required this.translation,
    required this.repeat,
  });
}

///
/// ──────────────────────────────────────────────────────────────────────────────
///  MORNING ADHKAR (Full Copy-Paste + Short Translations)
/// ──────────────────────────────────────────────────────────────────────────────
///
/// EXACT Arabic text you provided (no ellipses). Each item includes a short
/// English meaning/translation (sourced from common references).
///
final List<DhikrItem> morningAdhkar = [
  DhikrItem(
    arabic:
        'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلۡحَيُّ '
        'ٱلۡقَيُّومُۚ لَا تَأۡخُذُهُۥ سِنَةٞ وَلَا نَوۡمٞۚ '
        'لَّهُۥ مَا فِي ٱلسَّمَٰوَٰتِ وَمَا فِي ٱلۡأَرۡضِۗ '
        'مَن ذَا ٱلَّذِي يَشۡفَعُ عِندَهُۥٓ إِلَّا بِإِذۡنِهِۦۚ '
        'يَعۡلَمُ مَا بَيۡنَ أَيۡدِيهِمۡ وَمَا خَلۡفَهُمۡۖ '
        'وَلَا يُحِيطُونَ بِشَيۡءٖ مِّنۡ عِلۡمِهِۦٓ إِلَّا '
        'بِمَا شَآءَۚ وَسِعَ كُرۡسِيُّهُ ٱلسَّمَٰوَٰتِ '
        'وَٱلۡأَرۡضَۖ وَلَا يَـُٔودُهُۥ حِفۡظُهُمَاۚ '
        'وَهُوَ ٱلۡعَلِيُّ ٱلۡعَظِيمُ ٢٥٥',
    translation:
        'Ayatul Kursi (Qur’an 2:255). “Allah – there is no deity except Him, '
        'the Ever-Living, the Sustainer of [all] existence...”',
    repeat: 1,
  ),
  DhikrItem(
    arabic:
        'بسم الله الرحمن الرحيم\n'
        'قُلۡ هُوَ ٱللَّهُ أَحَدٌ ١ ٱللَّهُ '
        'ٱلصَّمَدُ ٢ لَمۡ يَلِدۡ وَلَمۡ يُولَدۡ ٣ '
        'وَلَمۡ يَكُن لَّهُۥ كُفُوًا أَحَدُۢ ٤',
    translation:
        'Surah Al-Ikhlas (Qur’an 112). “Say, He is Allah, [who is] One...”',
    repeat: 3,
  ),
  DhikrItem(
    arabic:
        'بسم الله الرحمن الرحيم\n'
        'قُلۡ أَعُوذُ بِرَبِّ ٱلۡفَلَقِ ١ '
        'مِن شَرِّ مَا خَلَقَ ٢ وَمِن شَرِّ غَاسِقٍ '
        'إِذَا وَقَبَ ٣ وَمِن شَرِّ ٱلنَّفَّٰثَٰتِ '
        'فِي ٱلۡعُقَدِ ٤ وَمِن شَرِّ حَاسِدٍ '
        'إِذَا حَسَدَ ٥',
    translation:
        'Surah Al-Falaq (Qur’an 113). “Say: I seek refuge in the Lord of daybreak...”',
    repeat: 3,
  ),
  DhikrItem(
    arabic:
        'بسم الله الرحمن الرحيم\n'
        'قُلۡ أَعُوذُ بِرَبِّ ٱلنَّاسِ ١ '
        'مَلِكِ ٱلنَّاسِ ٢ إِلَٰهِ ٱلنَّاسِ ٣ '
        'مِن شَرِّ ٱلۡوَسۡوَاسِ ٱلۡخَنَّاسِ ٤ '
        'ٱلَّذِي يُوَسۡوِسُ فِي صُدُورِ ٱلنَّاسِ ٥ '
        'مِنَ ٱلۡجِنَّةِ وَٱلنَّاسِ ٦',
    translation:
        'Surah An-Nas (Qur’an 114). “Say: I seek refuge in the Lord of mankind...”',
    repeat: 3,
  ),
  DhikrItem(
    arabic:
        'أصبَحنا وَأصبَحَ المُلكُ للَّهِ، وَالحَمدُ للَّهِ، '
        'لا إلَهَ إلّا اللَّهُ وَحدَهُ لا شَريكَ لَهُ، لَهُ '
        'المُلكُ وَلَهُ الحَمدُ، وَهُوَ عَلى كُلِّ شَيءٍ '
        'قَديرٌ، رَبِّ أسألُكَ خَيرَ ما في هَذا اليَومِ '
        'وَخَيرَ ما بَعدَهُ، وَأعوذُ بِكَ مِن شَرِّ ما في '
        'هَذا اليَومِ وَشَرِّ ما بَعدَهُ، رَبِّ أعوذُ بِكَ '
        'مِنَ الكَسَلِ وَسُوءِ الكِبَرِ، رَبِّ أعوذُ بِكَ '
        'مِن عَذابٍ في النّارِ وَعَذابٍ في القَبرِ',
    translation:
        '“We have reached the morning and at this very time all sovereignty '
        'belongs to Allah... I seek refuge in You from the evil of this '
        'day and what follows it...”',
    repeat: 1,
  ),
  DhikrItem(
    arabic:
        'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، '
        'وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
    translation:
        '“O Allah, by Your leave we have reached morning, and by Your leave '
        'we have reached evening, by Your leave we live and die, and unto '
        'You is the resurrection.”',
    repeat: 1,
  ),
  DhikrItem(
    arabic:
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، '
        'خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ '
        'وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ '
        'مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، '
        'وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا '
        'يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    translation:
        '“O Allah, You are my Lord, none has the right to be worshiped but '
        'You. You created me and I am Your servant... (Sayyid al-Istighfar).”',
    repeat: 1,
  ),
  DhikrItem(
    arabic:
        'اللَّهُمَّ إِنِّي أَصْبَحْتُ أُشْهِدُكَ، وَأُشْهِدُ '
        'حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، '
        'أَنَّكَ أَنْتَ اللَّهُ لَا إِلَهَ إِلَّا أَنْتَ '
        'وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّدًا عَبْدُكَ '
        'وَرَسُولُكَ',
    translation:
        '“O Allah, I have entered morning calling You to witness, and calling '
        'the bearers of Your Throne, Your angels, and all Your creation to '
        'witness that indeed You are Allah...”',
    repeat: 4,
  ),
  DhikrItem(
    arabic:
        'اللَّهُمَّ مَا أَصْبَحَ بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ '
        'مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، '
        'فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ',
    translation:
        '“O Allah, whatever blessing I or any of Your creation has this '
        'morning is from You alone...”',
    repeat: 1,
  ),
  DhikrItem(
    arabic:
        'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي '
        'فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، '
        'لَا إِلَهَ إِلَّا أَنْتَ. اللَّهُمَّ إِنِّي '
        'أَعُوذُ بِكَ مِنَ الْكُفْرِ، وَالْفَقْرِ، وَأَعُوذُ '
        'بِكَ مِنْ عَذَابِ الْقَبْرِ، لَا إِلَهَ إِلَّا أَنْتَ',
    translation:
        '“O Allah, grant me well-being in my body, hearing, and sight... '
        'I seek refuge in You from disbelief and poverty...”',
    repeat: 3,
  ),
  DhikrItem(
    arabic:
        'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ '
        'تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
    translation:
        '“Allah is sufficient for me, there is no god but He; in Him I put '
        'my trust...”',
    repeat: 7,
  ),
  DhikrItem(
    arabic:
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ '
        'فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي '
        'أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي '
        'وَدُنْيَايَ وَأَهْلِي، وَمَالِي، اللَّهُمَّ اسْتُرْ '
        'عَوْرَاتِي، وَآمِنْ رَوْعَاتِي، اللَّهُمَّ احْفَظْنِي '
        'مِنْ بَيْنِ يَدَيَّ، وَمِنْ خَلْفِي، وَعَنْ يَمِينِي، '
        'وَعَنْ شِمَالِي، وَمِنْ فَوْقِي، وَأَعُوذُ '
        'بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِي',
    translation:
        '“O Allah, I ask You for pardon and well-being in this life and the next... ”',
    repeat: 1,
  ),
  DhikrItem(
    arabic:
        'اللَّهُمَّ عَالِمَ الغَيْبِ وَالشَّهَادَةِ فَاطِرَ '
        'السَّمَاوَاتِ وَالْأَرْضِ، رَبَّ كُلِّ شَيْءٍ '
        'وَمَلِيكَهُ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، '
        'أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي، وَمِنْ شَرِّ '
        'الشَّيْطَانِ وَشِرْكِهِ، وَأَنْ أَقْتَرِفَ عَلَى '
        'نَفْسِي سُوءًا، أَوْ أَجُرَّهُ إِلَى مُسْلِمٍ',
    translation:
        '“O Allah, Knower of the unseen and the seen, Creator of the heavens '
        'and earth, Lord of everything... I seek refuge in You from the evil '
        'of myself and from Satan...”',
    repeat: 1,
  ),
  DhikrItem(
    arabic:
        'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ '
        'شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ '
        'السَّمِيعُ الْعَلِيمُ',
    translation:
        '“In the name of Allah, with whose name nothing in the earth or the '
        'heavens can harm...”',
    repeat: 3,
  ),
  DhikrItem(
    arabic:
        'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، '
        'وَبِمُحَمَّدٍ صلى الله عليه وسلم نَبِيًّا',
    translation:
        '“I am pleased with Allah as my Lord, Islam as my religion, and '
        'Muhammad (peace be upon him) as my Prophet.”',
    repeat: 3,
  ),
  DhikrItem(
    arabic:
        'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغيثُ '
        'أَصْلِحْ لِي شَأْنِيَ كُلَّهُ وَلاَ تَكِلْنِي '
        'إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
    translation:
        '“O Ever-Living, O Sustainer, by Your mercy I seek assistance, rectify '
        'all of my affairs...”',
    repeat: 1,
  ),
  DhikrItem(
    arabic:
        'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ رَبِّ '
        'الْعَالَمِينَ، اللَّهُمَّ إِنِّي أَسْأَلُكَ '
        'خَيْرَ هَذَا الْيَوْمِ فَتْحَهُ، وَنَصْرَهُ، '
        'وَنُورَهُ، وَبَرَكَتَهُ، وَهُدَاهُ، وَأَعُوذُ بِكَ '
        'مِنْ شَرِّ مَا فِيهِ وَشَرِّ مَا بَعْدَهُ',
    translation:
        '“We have reached morning, and the entire kingdom belongs to Allah, '
        'Lord of the worlds. O Allah, I ask You for the good of this day...”',
    repeat: 1,
  ),
  DhikrItem(
    arabic:
        'أَصْبَحْنا عَلَى فِطْرَةِ الْإِسْلَامِ، وَعَلَى '
        'كَلِمَةِ الْإِخْلَاصِ، وَعَلَى دِينِ نَبِيِّنَا '
        'مُحَمَّدٍ صلى الله عليه وسلم، وَعَلَى مِلَّةِ '
        'أَبِينَا إِبْرَاهِيمَ، حَنِيفاً مُسْلِماً وَمَا '
        'كَانَ مِنَ الْمُشرِكِينَ',
    translation:
        '“We have awakened upon the natural religion of Islam, the word of '
        'sincerity, the religion of our Prophet Muhammad...”',
    repeat: 1,
  ),
  DhikrItem(
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    translation: '“Glory be to Allah and praise be to Him.”',
    repeat: 100,
  ),
  DhikrItem(
    arabic:
        'لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، '
        'لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى '
        'كُلِّ شَيْءٍ قَدِيرٌ',
    translation:
        '“None has the right to be worshiped except Allah alone, without '
        'partner. His is the dominion, and to Him is all praise...”',
    repeat: 1,
  ),
  DhikrItem(
    arabic:
        'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ, عَدَدَ خَلْقِهِ، '
        'وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، '
        'وَمِدَادَ كَلِمَاتِهِ',
    translation:
        '“Glory be to Allah and praise be to Him, by the number of His creation, '
        'His pleasure, the weight of His Throne...”',
    repeat: 3,
  ),
  DhikrItem(
    arabic:
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْماً نَافِعاً، '
        'وَرِزْقاً طَيِّباً، وَعَمَلاً مُتَقَبَّلاً',
    translation:
        '“O Allah, I ask You for beneficial knowledge, good provision, '
        'and accepted deeds.”',
    repeat: 1,
  ),
  DhikrItem(
    arabic: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
    translation: '“I seek Allah’s forgiveness and repent to Him.”',
    repeat: 100,
  ),
  DhikrItem(
    arabic:
        'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبَيِّنَا مُحَمَّدٍ',
    translation: '“O Allah, send Your blessings and peace upon our Prophet Muhammad.”',
    repeat: 10,
  ),
];

///
/// ──────────────────────────────────────────────────────────────────────────────
///  EVENING ADHKAR (Full Copy-Paste + Short Translations)
/// ──────────────────────────────────────────────────────────────────────────────
///
final List<DhikrItem> eveningAdhkar = [
  DhikrItem(
    arabic:
        'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلۡحَيُّ '
        'ٱلۡقَيُّومُۚ لَا تَأۡخُذُهُۥ سِنَةٞ وَلَا نَوۡمٞۚ '
        'لَّهُۥ مَا فِي ٱلسَّمَٰوَٰتِ وَمَا فِي ٱلۡأَرۡضِۗ '
        'مَن ذَا ٱلَّذِي يَشۡفَعُ عِندَهُۥٓ إِلَّا '
        'بِإِذۡنِهِۦۚ يَعۡلَمُ مَا بَيۡنَ أَيۡدِيهِمۡ '
        'وَمَا خَلۡفَهُمۡۖ وَلَا يُحِيطُونَ بِشَيۡءٖ '
        'مِّنۡ عِلۡمِهِۦٓ إِلَّا بِمَا شَآءَۚ وَسِعَ '
        'كُرۡسِيُّهُ ٱلسَّمَٰوَٰتِ وَٱلۡأَرۡضَۖ '
        'وَلَا يَـُٔودُهُۥ حِفۡظُهُمَاۚ وَهُوَ '
        'ٱلۡعَلِيُّ ٱلۡعَظِيمُ ٢٥٥',
    translation:
        'Ayatul Kursi (Qur’an 2:255). Recite in the evening as well...',
    repeat: 1,
  ),
  DhikrItem(
    arabic:
        'بسم الله الرحمن الرحيم\n'
        'قُلۡ هُوَ ٱللَّهُ أَحَدٌ ١ '
        'ٱللَّهُ ٱلصَّمَدُ ٢ لَمۡ يَلِدۡ '
        'وَلَمۡ يُولَدۡ ٣ وَلَمۡ يَكُن لَّهُۥ '
        'كُفُوًا أَحَدُۢ ٤',
    translation:
        'Surah Al-Ikhlas (Qur’an 112). “Say: He is Allah, the One...”',
    repeat: 3,
  ),
  DhikrItem(
    arabic:
        'بسم الله الرحمن الرحيم\n'
        'قُلۡ أَعُوذُ بِرَبِّ ٱلۡفَلَقِ ١ '
        'مِن شَرِّ مَا خَلَقَ ٢ وَمِن شَرِّ '
        'غَاسِقٍ إِذَا وَقَبَ ٣ وَمِن شَرِّ '
        'ٱلنَّفَّٰثَٰتِ فِي ٱلۡعُقَدِ ٤ '
        'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ ٥',
    translation:
        'Surah Al-Falaq (Qur’an 113). “Say: I seek refuge in the Lord of daybreak...”',
    repeat: 3,
  ),
  DhikrItem(
    arabic:
        'بسم الله الرحمن الرحيم\n'
        'قُلۡ أَعُوذُ بِرَبِّ ٱلنَّاسِ ١ '
        'مَلِكِ ٱلنَّاسِ ٢ إِلَٰهِ '
        'ٱلنَّاسِ ٣ مِن شَرِّ '
        'ٱلۡوَسۡوَاسِ ٱلۡخَنَّاسِ ٤ '
        'ٱلَّذِي يُوَسۡوِسُ فِي '
        'صُدُورِ ٱلنَّاسِ ٥ مِنَ '
        'ٱلۡجِنَّةِ وَٱلنَّاسِ ٦',
    translation:
        'Surah An-Nas (Qur’an 114). “Say: I seek refuge in the Lord of mankind...”',
    repeat: 3,
  ),
  DhikrItem(
    arabic:
        'أمسَينا وَأمسى المُلكُ للَّهِ، وَالحَمدُ للَّهِ، '
        'لا إلَهَ إلّا اللَّهُ وَحدَهُ لا شَريكَ لَهُ، '
        'لَهُ المُلكُ وَلَهُ الحَمدُ، وَهُوَ عَلى كُلِّ '
        'شَيءٍ قَديرٌ، رَبِّ أسألُكَ خَيرَ ما في هَذِهِ '
        'اللَّيلَةِ وَخَيرَ ما بَعدَها، وَأعوذُ بِكَ '
        'مِن شَرِّ ما في هَذِهِ اللَّيلَةِ وَشَرِّ '
        'ما بَعدَها، رَبِّ أعوذُ بِكَ مِنَ الكَسَلِ '
        'وَسُوءِ الكِبَرِ، رَبِّ أعوذُ بِكَ '
        'مِن عَذابٍ في النّارِ وَعَذابٍ في القَبرِ',
    translation:
        '“We have entered the evening and at this very time all dominion belongs '
        'to Allah... O Lord, I seek refuge in You from the evil of this night...”',
    repeat: 1,
  ),
  DhikrItem(
    arabic:
        'اللَّهُمَّ بِكَ أمسَينا، وَبِكَ أصبَحنا، وَبِكَ '
        'نَحيا، وَبِكَ نَموتُ، وَإلَيكَ المَصيرُ',
    translation:
        '“O Allah, by Your leave we have entered evening, and by Your leave we have '
        'entered morning...”',
    repeat: 1,
  ),
  DhikrItem(
    arabic:
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، '
        'خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ '
        'وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ '
        'مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، '
        'وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا '
        'يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    translation:
        '“O Allah, You are my Lord, none has the right to be worshiped except You... ”',
    repeat: 1,
  ),
  DhikrItem(
    arabic:
        'اللَّهُمَّ إنّي أمسَيتُ أُشهِدُكَ، وَأُشهِدُ حَمَلَةَ '
        'عَرشِكَ، وَمَلائِكَتَكَ، وَجَميعَ خَلقِكَ، أنَّكَ '
        'أنتَ اللَّهُ لا إلَهَ إلّا أنتَ وَحدَكَ لا شَريكَ '
        'لَكَ، وَأنَّ مُحَمَّدًا عَبدُكَ وَرَسولُكَ',
    translation:
        '“O Allah, I have entered upon the evening calling You to witness, and calling '
        'the carriers of Your Throne, Your angels, and all of Your creation...”',
    repeat: 4,
  ),
  DhikrItem(
    arabic:
        'اللَّهُمَّ ما أمسَى بي مِن نِعمَةٍ أو بِأحَدٍ مِن خَلقِكَ '
        'فَمِنكَ وَحدَكَ لا شَريكَ لَكَ، فَلَكَ الحَمدُ '
        'وَلَكَ الشُّكرُ',
    translation:
        '“O Allah, whatever blessing has come to me or any of Your creation this '
        'evening, it is from You alone...”',
    repeat: 1,
  ),
  DhikrItem(
    arabic:
        'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي '
        'فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، '
        'لاَ إِلَهَ إِلاَّ أَنْتَ. اللَّهُمَّ إِنِّي '
        'أَعُوذُ بِكَ مِنَ الْكُفْرِ، وَالفَقْرِ، '
        'وَأَعُوذُ بِكَ مِنْ عَذَابِ القَبْرِ، '
        'لاَ إِلَهَ إِلاَّ أَنْتَ',
    translation:
        '“O Allah, grant me health in my body, hearing, and sight... I seek refuge in '
        'You from disbelief, poverty, and the torment of the grave...”',
    repeat: 3,
  ),
  DhikrItem(
    arabic:
        'حَسْبِيَ اللَّهُ لاَ إِلَهَ إِلاَّ هُوَ عَلَيهِ '
        'تَوَكَّلتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
    translation:
        '“Allah is sufficient for me; there is no deity but He. In Him I have placed '
        'my trust, and He is the Lord of the Mighty Throne.”',
    repeat: 7,
  ),
  DhikrItem(
    arabic:
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ '
        'فِي الدُّنْيَا وَالآخِرَةِ، اللَّهُمَّ إِنِّي '
        'أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي '
        'وَدُنْيَايَ وَأَهْلِي، وَمَالِي، اللَّهُمَّ '
        'اسْتُرْ عَوْرَاتِي، وَآمِنْ رَوْعَاتِي، '
        'اللَّهُمَّ احْفَظْنِي مِنْ بَينِ يَدَيَّ، '
        'وَمِنْ خَلْفِي، وَعَنْ يَمِينِي، '
        'وَعَنْ شِمَالِي، وَمِنْ فَوْقِي، '
        'وَأَعُوذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِي',
    translation:
        '“O Allah, I ask You for pardon and well-being in this world and the Hereafter... ”',
    repeat: 1,
  ),
  DhikrItem(
    arabic:
        'اللَّهُمَّ عَالِمَ الغَيْبِ وَالشَّهَادَةِ فَاطِرَ '
        'السَّمَاوَاتِ وَالْأَرْضِ، رَبَّ كُلِّ شَيْءٍ '
        'وَمَلِيكَهُ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، '
        'أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي، وَمِنْ شَرِّ '
        'الشَّيْطَانِ وَشِرْكِهِ، وَأَنْ أَقْتَرِفَ عَلَى '
        'نَفْسِي سُوءًا، أَوْ أَجُرَّهُ إِلَى مُسْلِمٍ',
    translation:
        '“O Allah, Knower of the unseen and the seen, Creator of the heavens and earth... ”',
    repeat: 1,
  ),
  DhikrItem(
    arabic:
        'بِسْمِ اللَّهِ الَّذِي لاَ يَضُرُّ مَعَ اسْمِهِ '
        'شَيْءٌ فِي الْأَرْضِ وَلاَ فِي السّمَاءِ '
        'وَهُوَ السَّمِيعُ الْعَلِيمُ',
    translation:
        '“In the name of Allah with Whose name nothing can harm on earth or in heaven...”',
    repeat: 3,
  ),
  DhikrItem(
    arabic:
        'رَضِيتُ بِاللَّهِ رَبَّاً، وَبِالْإِسْلاَمِ دِيناً، '
        'وَبِمُحَمَّدٍ صلى الله عليه وسلم نَبِيّاً',
    translation:
        '“I am pleased with Allah as my Lord, Islam as my religion, and Muhammad (pbuh) '
        'as my Prophet.”',
    repeat: 3,
  ),
  DhikrItem(
    arabic:
        'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغيثُ '
        'أَصْلِحْ لِي شَأْنِيَ كُلَّهُ وَلاَ تَكِلْنِي '
        'إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
    translation:
        '“O Ever-Living, O Sustainer, by Your mercy I seek help; rectify all my affairs...”',
    repeat: 1,
  ),
  DhikrItem(
    arabic:
        'أمسَينا وَأمسَى المُلكُ للَّهِ رَبِّ العالَمينَ، '
        'اللَّهُمَّ إنّي أسألُكَ خَيرَ هَذِهِ اللَّيلَةِ: '
        'فَتحَها، وَنَصرَها، وَنورَها، وَبَرَكَتَها، '
        'وَهُداها، وَأعوذُ بِكَ مِن شَرِّ ما فيها '
        'وَشَرِّ ما بَعدَها',
    translation:
        '“We have reached the evening, and all dominion belongs to Allah, Lord of the worlds... ”',
    repeat: 1,
  ),
  DhikrItem(
    arabic:
        'أمسَينا عَلَى فِطْرَةِ الْإِسْلاَمِ، وَعَلَى '
        'كَلِمَةِ الْإِخْلاَصِ، وَعَلَى دِينِ '
        'نَبِيِّنَا مُحَمَّدٍ صلى الله عليه وسلم، '
        'وَعَلَى مِلَّةِ أَبِينَا إِبْرَاهِيمَ، '
        'حَنِيفاً مُسْلِماً وَمَا كَانَ مِنَ '
        'الْمُشرِكِينَ',
    translation:
        '“We have entered upon the natural religion of Islam, the word of sincerity, '
        'the religion of Prophet Muhammad, and the way of our father Ibrahim...”',
    repeat: 1,
  ),
  DhikrItem(
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    translation: '“Glory be to Allah and praise be to Him.”',
    repeat: 100,
  ),
  DhikrItem(
    arabic:
        'لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ '
        'لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، '
        'وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    translation:
        '“None has the right to be worshiped except Allah alone, without partner. '
        'His is the dominion, and to Him belongs the praise...”',
    repeat: 1,
  ),
  DhikrItem(
    arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ '
        'مِنْ شَرِّ مَا خَلَقَ',
    translation:
        '“I seek refuge in the perfect words of Allah from the evil of what He created.”',
    repeat: 3,
  ),
  DhikrItem(
    arabic: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبَيِّنَا مُحَمَّدٍ',
    translation:
        '“O Allah, send blessings and peace upon our Prophet Muhammad.”',
    repeat: 10,
  ),
];

///
/// ──────────────────────────────────────────────────────────────────────────────
///  MAIN ADVANCED PAGE (Azkar & Tasbih)
/// ──────────────────────────────────────────────────────────────────────────────
///
/// You can reference this in your main nav, e.g.:
/// final _pages = [
///   PrayerTimesPage(),
///   AzkarAndTasbihAdvancedPage(),
///   QiblaPage(),
///   ...
/// ];
///
class AzkarAndTasbihAdvancedPage extends StatefulWidget {
  const AzkarAndTasbihAdvancedPage({Key? key}) : super(key: key);

  @override
  State<AzkarAndTasbihAdvancedPage> createState() =>
      _AzkarAndTasbihAdvancedPageState();
}

class _AzkarAndTasbihAdvancedPageState
    extends State<AzkarAndTasbihAdvancedPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Two tabs: "Azkar" & "Tasbih"
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Azkar & Tasbih'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.menu_book), text: 'Azkar'),
              Tab(icon: Icon(Icons.fingerprint), text: 'Tasbih'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            _AzkarMenuPage(),
            TasbihAdvancedPage(),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
    );
  }
}

///
/// ──────────────────────────────────────────────────────────────────────────────
///  1) AZKAR MENU PAGE
/// ──────────────────────────────────────────────────────────────────────────────
class _AzkarMenuPage extends StatelessWidget {
  const _AzkarMenuPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.05),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _AzkarCard(
            title: 'Morning Azkar',
            subtitle: 'أذكار الصباح',
            color: theme.colorScheme.primary,
            icon: Icons.sunny_snowing,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AzkarReadingPage(
                    title: 'Morning Azkar',
                    items: morningAdhkar,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _AzkarCard(
            title: 'Evening Azkar',
            subtitle: 'أذكار المساء',
            color: theme.colorScheme.secondary,
            icon: Icons.nights_stay_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AzkarReadingPage(
                    title: 'Evening Azkar',
                    items: eveningAdhkar,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// A neat card for "Morning" / "Evening"
class _AzkarCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _AzkarCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.85),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward_ios, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

///
/// ──────────────────────────────────────────────────────────────────────────────
///  2) TASBIH PAGE (ADVANCED) 
///      - 4 counters: 1 global & 3 named
/// ──────────────────────────────────────────────────────────────────────────────
class TasbihAdvancedPage extends StatefulWidget {
  const TasbihAdvancedPage({Key? key}) : super(key: key);

  @override
  State<TasbihAdvancedPage> createState() => _TasbihAdvancedPageState();
}

class _TasbihAdvancedPageState extends State<TasbihAdvancedPage> {
  // Main “global” tasbih
  int globalCount = 0;
  final int globalTarget = 99; // for example

  // Additional counters
  int countSubhanallah = 0;
  int countAlhamdulillah = 0;
  int countAllahuAkbar = 0;
  final int eachTarget = 33; // typical tasbih counts

  void _incrementGlobal() {
    setState(() {
      if (globalCount < globalTarget) {
        globalCount++;
      }
    });
  }

  void _incrementSubhanallah() {
    setState(() {
      if (countSubhanallah < eachTarget) {
        countSubhanallah++;
      }
    });
  }

  void _incrementAlhamdulillah() {
    setState(() {
      if (countAlhamdulillah < eachTarget) {
        countAlhamdulillah++;
      }
    });
  }

  void _incrementAllahuAkbar() {
    setState(() {
      if (countAllahuAkbar < eachTarget) {
        countAllahuAkbar++;
      }
    });
  }

  void _resetAll() {
    setState(() {
      globalCount = 0;
      countSubhanallah = 0;
      countAlhamdulillah = 0;
      countAllahuAkbar = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mainFraction = (globalCount / globalTarget).clamp(0.0, 1.0);
    final subFraction1 = (countSubhanallah / eachTarget).clamp(0.0, 1.0);
    final subFraction2 = (countAlhamdulillah / eachTarget).clamp(0.0, 1.0);
    final subFraction3 = (countAllahuAkbar / eachTarget).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text('Tasbih Advanced')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              //
              // ────────── Global Tasbih ──────────
              //
              const Text(
                'Global Tasbih',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _incrementGlobal,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  height: 270,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.06),
                        theme.colorScheme.secondary.withOpacity(0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: CircularPercentIndicator(
                      radius: 80.0,
                      lineWidth: 12.0,
                      animation: true,
                      animationDuration: 300,
                      animateFromLastPercent: true, // so it doesn't reset to 0
                      percent: mainFraction,
                      center: Text(
                        '$globalCount / $globalTarget',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      progressColor: theme.colorScheme.primary,
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.2),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              //
              // ────────── Sub Counters ──────────
              //
              const Text(
                'Sub-Counters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSmallTasbihBox(
                    context,
                    title: 'SubḥānAllāh',
                    count: countSubhanallah,
                    target: eachTarget,
                    fraction: subFraction1,
                    onTap: _incrementSubhanallah,
                  ),
                  _buildSmallTasbihBox(
                    context,
                    title: 'Al-ḥamdu lillāh',
                    count: countAlhamdulillah,
                    target: eachTarget,
                    fraction: subFraction2,
                    onTap: _incrementAlhamdulillah,
                  ),
                  _buildSmallTasbihBox(
                    context,
                    title: 'Allāhu Akbar',
                    count: countAllahuAkbar,
                    target: eachTarget,
                    fraction: subFraction3,
                    onTap: _incrementAllahuAkbar,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _resetAll,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset All'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tap the main box for a global count.\n'
                'Tap any sub box for specific counts (33 each).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallTasbihBox(
    BuildContext context, {
    required String title,
    required int count,
    required int target,
    required double fraction,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 110,
        height: 140,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularPercentIndicator(
              radius: 32.0,
              lineWidth: 6.0,
              animation: true,
              animationDuration: 300,
              animateFromLastPercent: true,
              percent: fraction,
              center: Text(
                '$count',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              progressColor: theme.colorScheme.secondary,
              backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///
/// ──────────────────────────────────────────────────────────────────────────────
///  AZKAR READING PAGE
/// ──────────────────────────────────────────────────────────────────────────────
///
/// Displays each Dhikr in a horizontally-swipeable manner with:
///  - A top linear progress bar for overall completion (how many dhikr done).
///  - Each dhikr has a circular indicator that animates from the last percent.
///  - Confetti on the final item, then a completion dialog.
class AzkarReadingPage extends StatefulWidget {
  final String title;
  final List<DhikrItem> items;

  const AzkarReadingPage({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  @override
  State<AzkarReadingPage> createState() => _AzkarReadingPageState();
}

class _AzkarReadingPageState extends State<AzkarReadingPage> {
  late PageController _pageController;
  late List<int> currentCounts;
  late ConfettiController _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    currentCounts = List.filled(widget.items.length, 0);
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  int get completedItemsCount {
    int c = 0;
    for (int i = 0; i < widget.items.length; i++) {
      if (currentCounts[i] == widget.items[i].repeat) {
        c++;
      }
    }
    return c;
  }

  double get overallFraction {
    return (completedItemsCount / widget.items.length).clamp(0.0, 1.0);
  }

  void _incrementCount(int index) {
    setState(() {
      if (currentCounts[index] < widget.items[index].repeat) {
        currentCounts[index]++;
      }
      // if finished this dhikr
      if (currentCounts[index] == widget.items[index].repeat) {
        if (index < widget.items.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        } else {
          // last one
          _confettiCtrl.play();
          Future.delayed(const Duration(milliseconds: 1500), () {
            _showCompletionDialog();
          });
        }
      }
    });
  }

  void _showCompletionDialog() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${widget.title} Completed!'),
        content: const Text('You have finished all azkār in this category.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          Column(
            children: [
              // top linear progress
              LinearPercentIndicator(
                lineHeight: 6.0,
                animation: true,
                animationDuration: 300,
                animateFromLastPercent: true,
                percent: overallFraction,
                progressColor: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                padding: EdgeInsets.zero,
              ),
              // main content: PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final count = currentCounts[index];
                    final required = item.repeat;
                    final fraction = (count / required).clamp(0.0, 1.0);

                    return GestureDetector(
                      onTap: () => _incrementCount(index),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 30),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.08),
                                    theme.colorScheme.secondary.withOpacity(0.08),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Arabic text
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Text(
                                        item.arabic,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 20,
                                          height: 1.6,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // English translation
                                    Text(
                                      item.translation,
                                      textAlign: TextAlign.justify,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black54,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // circular progress
                                    CircularPercentIndicator(
                                      radius: 60.0,
                                      lineWidth: 8.0,
                                      animation: true,
                                      animationDuration: 300,
                                      animateFromLastPercent: true,
                                      percent: fraction,
                                      center: Text(
                                        '$count / $required',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      progressColor: theme.colorScheme.primary,
                                      backgroundColor: theme.colorScheme.primary
                                          .withOpacity(0.2),
                                      circularStrokeCap: CircularStrokeCap.round,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Tap Anywhere to Count',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 25,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange],
            ),
          ),
        ],
      ),
    );
  }
}
