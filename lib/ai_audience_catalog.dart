import 'dart:math';
import 'package:flutter/material.dart';
import 'vision_service.dart';

class AiViewerProfile {
  final String id;
  final String name;
  final String city;
  final String archetype;
  final String preferredLanguage;
  final Color avatarColor;
  final String? avatarUrl;
  final List<String> sampleComments;

  const AiViewerProfile({
    required this.id,
    required this.name,
    required this.city,
    required this.archetype,
    required this.preferredLanguage,
    required this.avatarColor,
    this.avatarUrl,
    required this.sampleComments,
  });

  String? get photoUrl {
    if (avatarUrl != null) return avatarUrl!.isEmpty ? null : avatarUrl;
    final num = int.tryParse(id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    // ~35% of accounts have NO profile photo (real Instagram blank silhouette)
    if (num % 3 == 0) return null;
    return AiAudienceCatalog.realisticPhotoUrls[(num - 1) % AiAudienceCatalog.realisticPhotoUrls.length];
  }
}

/// Exactly 30 distinct Indian viewer profiles representing cities across India.
/// Phrased with authentic, casual, human social media livestream commentary
/// (slang, punchy expressions, natural punctuation, casual Hinglish/regional tones).
class AiAudienceCatalog {
  static const List<AiViewerProfile> profiles = [
    // 1. Mumbai
    AiViewerProfile(
      id: 'ai_01',
      name: 'Aarav Sharma',
      city: 'Mumbai',
      archetype: 'The Trendsetter',
      preferredLanguage: 'Hinglish',
      avatarColor: Color(0xFF6C5CE7),
      sampleComments: [
        'bhai OP stream chal rhi h 🔥',
        'arre waah bhai kya baat hai!',
        'love from bandra bro ❤️',
        'bhai ek baar naam lelo na pls 😂',
        'mast lag rhe ho bro',
      ],
    ),

    // 2. Ahmedabad
    AiViewerProfile(
      id: 'ai_02',
      name: 'Priya Patel',
      city: 'Ahmedabad',
      archetype: 'The Enthusiastic Supporter',
      preferredLanguage: 'Hinglish',
      avatarColor: Color(0xFF00B894),
      sampleComments: [
        'kem cho bhai! full support ❤️',
        'dil bhej diya bhai dhada dhad 🔥',
        'bhai aawaz ekdum mast aa rhi h 👍',
        'double tap done bro! ❤️❤️❤️',
        'superbbbb ✨',
      ],
    ),

    // 3. Bengaluru
    AiViewerProfile(
      id: 'ai_03',
      name: 'Vikram Rao',
      city: 'Bengaluru',
      archetype: 'The Techie Observer',
      preferredLanguage: 'English',
      avatarColor: Color(0xFFE17055),
      sampleComments: [
        'setup kafi sleek h bro 👌',
        'audio full clear h bhai',
        'konsa phone use kr rhe ho bhai?',
        'bengaluru se full support 🔥',
        'clean quality bro 👍',
      ],
    ),

    // 4. Hyderabad
    AiViewerProfile(
      id: 'ai_04',
      name: 'Ananya Reddy',
      city: 'Hyderabad',
      archetype: 'The Warm Complimenter',
      preferredLanguage: 'Hinglish',
      avatarColor: Color(0xFFFD79A8),
      sampleComments: [
        'loving the vibe bro! 💖',
        'bhai mast lag rha h stream',
        'bagunnara anna! love from hyd ❤️',
        'so good to see you live ✨',
        'super cute vibe today 👏',
      ],
    ),

    // 5. Delhi
    AiViewerProfile(
      id: 'ai_05',
      name: 'Rohan Mehta',
      city: 'Delhi',
      archetype: 'The Witty Jokester',
      preferredLanguage: 'Hindi',
      avatarColor: Color(0xFF0984E3),
      sampleComments: [
        'dilli walo ki taraf se salam bhai! 😂',
        'bhai kya bolti public 🔥',
        'shoutout de do bhai ko ek bar 😂',
        'ek number bhai ek number!',
        'mauj kardi bhai sach me lol',
      ],
    ),

    // 6. Kolkata
    AiViewerProfile(
      id: 'ai_06',
      name: 'Sneha Mukherjee',
      city: 'Kolkata',
      archetype: 'The Thoughtful Questioner',
      preferredLanguage: 'English',
      avatarColor: Color(0xFFE84393),
      sampleComments: [
        'hloo bro! topic kafi sahi h 🌟',
        'bhai live stream mast chal rhi h',
        'kolkata se hello 👋',
        'bhai lighting ekdum clean h ✨',
      ],
    ),

    // 7. Lucknow
    AiViewerProfile(
      id: 'ai_07',
      name: 'Farhan Qureshi',
      city: 'Lucknow',
      archetype: 'The Polite Admirer',
      preferredLanguage: 'Hindi',
      avatarColor: Color(0xFF00CEC9),
      sampleComments: [
        'aadab bhai! maza aa gaya ✨',
        'lucknow se dher sara pyar ❤️',
        'zabardast stream chal rhi h bhai',
        'bhai bolne ka andaz ekdum mast h 👌',
      ],
    ),

    // 8. Chennai
    AiViewerProfile(
      id: 'ai_08',
      name: 'Karthik Subramanian',
      city: 'Chennai',
      archetype: 'The Analytical Viewer',
      preferredLanguage: 'English',
      avatarColor: Color(0xFFF39C12),
      sampleComments: [
        'vanakkam bro! audio full clear 👍',
        'super presentation anna 🔥',
        'clean stream quality bro',
        'chennai gang watching! 👏',
      ],
    ),

    // 9. Kochi
    AiViewerProfile(
      id: 'ai_09',
      name: 'Divya Nair',
      city: 'Kochi',
      archetype: 'The Cheerful Creative',
      preferredLanguage: 'English',
      avatarColor: Color(0xFF27AE60),
      sampleComments: [
        'namaskaram bro! full energetic vibe 🌴',
        'kochi gang tuning in! ❤️',
        'loving this session ✨',
        'super energetic today bro 🎉',
      ],
    ),

    // 10. Pune
    AiViewerProfile(
      id: 'ai_10',
      name: 'Aditya Verma',
      city: 'Pune',
      archetype: 'The Casual Hype Man',
      preferredLanguage: 'Hinglish',
      avatarColor: Color(0xFF8E44AD),
      sampleComments: [
        'pune gang assemble! 🔥',
        'full power chal rha h bro ⚡',
        'bhai screen pe aag laga di lol 😂',
        'spam hearts guys double tap ❤️',
      ],
    ),

    // 11. Bengaluru
    AiViewerProfile(
      id: 'ai_11',
      name: 'Meera Iyer',
      city: 'Bengaluru',
      archetype: 'The Curious Learner',
      preferredLanguage: 'English',
      avatarColor: Color(0xFF16A085),
      sampleComments: [
        'tumba chennagi heltidira! super bro ✨',
        'bhai tips kafi sahi h 👌',
        'great vibe today 👏',
        'bengaluru traffic se live dekh rhi hu lol 😂',
      ],
    ),

    // 12. Bhopal
    AiViewerProfile(
      id: 'ai_12',
      name: 'Kabir Khan',
      city: 'Bhopal',
      archetype: 'The Big Dreamer',
      preferredLanguage: 'Hindi',
      avatarColor: Color(0xFFD35400),
      sampleComments: [
        'salam bhai! kafi inspiring session h 🏙️',
        'bhai next stream kab hogi?',
        'bhai full support h aapko ❤️',
        'bhopal se big cheers bhai 🙌',
      ],
    ),

    // 13. Jaipur
    AiViewerProfile(
      id: 'ai_13',
      name: 'Ishaan Joshi',
      city: 'Jaipur',
      archetype: 'The Culture Buff',
      preferredLanguage: 'Hindi',
      avatarColor: Color(0xFFC0392B),
      sampleComments: [
        'ram ram bhai! jaipur se pyar 🌸',
        'bhai mast lag rhe ho',
        'kya baat h bhai mazaa aa gya 🔥',
        'full chill stream h boss ✨',
      ],
    ),

    // 14. Kolkata
    AiViewerProfile(
      id: 'ai_14',
      name: 'Ritu Sengupta',
      city: 'Kolkata',
      archetype: 'The Thoughtful Critic',
      preferredLanguage: 'English',
      avatarColor: Color(0xFF2980B9),
      sampleComments: [
        'super relatable points bro 👍',
        'audio video mast h ekdum',
        'nice session 👏',
        'loving how candid you are! 🌟',
      ],
    ),

    // 15. Nagpur
    AiViewerProfile(
      id: 'ai_15',
      name: 'Arjun Deshmukh',
      city: 'Nagpur',
      archetype: 'The Energetic Enthusiast',
      preferredLanguage: 'Hindi',
      avatarColor: Color(0xFF2C3E50),
      sampleComments: [
        'nagpur se full support bhai 🍊',
        'josh high h ekdum 💥',
        'bhai shoutout de do na please 😂',
        'arre bhai bhai kya baat h 🔥',
      ],
    ),

    // 16. Mangalore
    AiViewerProfile(
      id: 'ai_16',
      name: 'Pooja Hegde',
      city: 'Mangalore',
      archetype: 'The Style Spotter',
      preferredLanguage: 'English',
      avatarColor: Color(0xFFFF7675),
      sampleComments: [
        'aesthetic kafi cool h bro ✨',
        'namaskara! loving the vibe 🌊',
        'crystal clear bro 👍',
        'coastal karnataka tuning in! 🌴',
      ],
    ),

    // 17. Srinagar
    AiViewerProfile(
      id: 'ai_17',
      name: 'Tariq Ahmed',
      city: 'Srinagar',
      archetype: 'The Serene Observer',
      preferredLanguage: 'Hindi',
      avatarColor: Color(0xFF74B9FF),
      sampleComments: [
        'salam from kashmir bhai ❄️',
        'bhai maza aa rha h sunke',
        'keep it up bro ❤️',
        'bohot pyara stream h bhai ✨',
      ],
    ),

    // 18. Madurai
    AiViewerProfile(
      id: 'ai_18',
      name: 'Deepa Sundaram',
      city: 'Madurai',
      archetype: 'The Encouraging Mentor',
      preferredLanguage: 'English',
      avatarColor: Color(0xFF55EFC4),
      sampleComments: [
        'vanakkam! romba nalla irukku 🌺',
        'super delivery bro 👏',
        'great energy today ✨',
        'madurai gang watching! 👍',
      ],
    ),

    // 19. Vijayawada
    AiViewerProfile(
      id: 'ai_19',
      name: 'Nikhil Teja',
      city: 'Vijayawada',
      archetype: 'The Cinema Buff',
      preferredLanguage: 'Hinglish',
      avatarColor: Color(0xFFFF9FF3),
      sampleComments: [
        'mass entry anna! adirindi 🔥',
        'vijayawada nundi full josh lo unnamu!',
        'bhai lighting mast h 🎬',
        'hero lag rhe ho bro! 😂🔥',
      ],
    ),

    // 20. Nashik
    AiViewerProfile(
      id: 'ai_20',
      name: 'Swati Kulkarni',
      city: 'Nashik',
      archetype: 'The Detail-Oriented Companion',
      preferredLanguage: 'Hinglish',
      avatarColor: Color(0xFFFECA57),
      sampleComments: [
        'bhai sach me maza aa gya 😂',
        'hearts sent from nashik! ❤️',
        'bhai mast stream chal rhi h',
        'sahi bola bhai ekdum 👍',
      ],
    ),

    // 21. Thiruvananthapuram
    AiViewerProfile(
      id: 'ai_21',
      name: 'Rahul Menon',
      city: 'Thiruvananthapuram',
      archetype: 'The Arts Aficionado',
      preferredLanguage: 'English',
      avatarColor: Color(0xFF48DBFB),
      sampleComments: [
        'adipoli bro! super stream 🎨',
        'capital city watching! ✨',
        'loving the vibes ❤️',
        'kollam bro kalakki! 🔥',
      ],
    ),

    // 22. Hyderabad
    AiViewerProfile(
      id: 'ai_22',
      name: 'Zoya Mirza',
      city: 'Hyderabad',
      archetype: 'The Lifestyle Explorer',
      preferredLanguage: 'Hinglish',
      avatarColor: Color(0xFFFF6B6B),
      sampleComments: [
        'hloo bro! hyderabad se salam ✨',
        'bhai kafi stylish lag rhe ho aaj',
        'so fun to watch 💖',
        'dil bhej diya bhai ❤️',
      ],
    ),

    // 23. Mysuru
    AiViewerProfile(
      id: 'ai_23',
      name: 'Sanjay Gowda',
      city: 'Mysuru',
      archetype: 'The Friendly Local',
      preferredLanguage: 'English',
      avatarColor: Color(0xFF1DD1A1),
      sampleComments: [
        'mysuru nundi namaskara! 🏰',
        'thumbaa khushi aayithu bro!',
        'superb stream anna 🔥',
        'clean sound bro 👍',
      ],
    ),

    // 24. Chandigarh
    AiViewerProfile(
      id: 'ai_24',
      name: 'Bhavna Chawla',
      city: 'Chandigarh',
      archetype: 'The Vibrant Mood Booster',
      preferredLanguage: 'Hindi',
      avatarColor: Color(0xFFEE5253),
      sampleComments: [
        'chak de phatte! full lit h stream 💃',
        'chandigarh se dher sara pyar ❤️',
        'bhai kya energy h! 🔥',
        'arre wahh mazaa aa gya 😂',
      ],
    ),

    // 25. Visakhapatnam
    AiViewerProfile(
      id: 'ai_25',
      name: 'Chaitanya Varma',
      city: 'Visakhapatnam',
      archetype: 'The Aspiring Creator',
      preferredLanguage: 'English',
      avatarColor: Color(0xFF54A0FF),
      sampleComments: [
        'vizag beach vibes bro! 🌊',
        'super confidence anna 🔥',
        'love from vizag ❤️',
        'bhai frame rate ekdum smooth h 👌',
      ],
    ),

    // 26. Coimbatore
    AiViewerProfile(
      id: 'ai_26',
      name: 'Harini Ramaswamy',
      city: 'Coimbatore',
      archetype: 'The Positive Energy Sender',
      preferredLanguage: 'English',
      avatarColor: Color(0xFF5F27CD),
      sampleComments: [
        'kovai nundi vanakkam! positive aura ✨',
        'nalla pesureenga bro 👍',
        'super presentation 👏',
        'great vibe today anna ❤️',
      ],
    ),

    // 27. Gurugram
    AiViewerProfile(
      id: 'ai_27',
      name: 'Gaurav Bhatia',
      city: 'Gurugram',
      archetype: 'The Startup Hustler',
      preferredLanguage: 'English',
      avatarColor: Color(0xFF341F97),
      sampleComments: [
        'cyber city tuning in! solid stream 📈',
        'bhai confidence 100/100 h',
        'full fire 🔥',
        'bhai link share kro sab log 🚀',
      ],
    ),

    // 28. Kozhikode
    AiViewerProfile(
      id: 'ai_28',
      name: 'Nandini Pillai',
      city: 'Kozhikode',
      archetype: 'The Gentle Empath',
      preferredLanguage: 'English',
      avatarColor: Color(0xFF01A3A4),
      sampleComments: [
        'calicut loves you! valare nannayi parayunnu 🌸',
        'so sweet and energetic ❤️',
        'great stream bro ✨',
        'loving your smile today 😊',
      ],
    ),

    // 29. Kanpur
    AiViewerProfile(
      id: 'ai_29',
      name: 'Amitabh Saxena',
      city: 'Kanpur',
      archetype: 'The Classic Nostalgia Buff',
      preferredLanguage: 'Hindi',
      avatarColor: Color(0xFFB71540),
      sampleComments: [
        'kanpur se pranam bhai 🙏',
        'ekdum dil jeet liya aapne ❤️',
        'bhai gazab bolte ho aap 🔥',
        'mauj kardi guru ji 😂',
      ],
    ),

    // 30. Goa
    AiViewerProfile(
      id: 'ai_30',
      name: 'Tanvi Shenoy',
      city: 'Goa',
      archetype: 'The Free-Spirited Wanderer',
      preferredLanguage: 'English',
      avatarColor: Color(0xFFE55039),
      sampleComments: [
        'goa se big cheers bro! 🌴',
        'full chill vibes here ✨',
        'keep rocking bro 🌊',
        'super chill session today ❤️',
      ],
    ),
  ];

  static final Random _random = Random();

  static const List<String> _authenticHypeMessages = [
    'bhai OP stream chal rhi h 🔥',
    'arre waah kya baat hai! 🙌',
    'lit stream bhaiii 🔥🔥',
    'W stream bro',
    'full power ⚡',
    'sahi h boss 👌',
    'mast lag rhe ho bro ✨',
    'banger live session 🔥',
    'yo bro wassup!',
    'ek number bhai! 💯',
    'gazab look h boss ✨',
    'kya bolti public 🔥',
    'superbbbb ✨',
    'epic vibe bro',
    'smooth quality today 👌',
    'damnn 🔥',
    'chalo full on fire 🚀',
    'bhai level up ho gaya aaj 🔥',
    'hahahaha lol 😂',
    'bhai full on scene ban gaya aaj',
    'aag laga di chat me 🔥',
    'mast energy h bhai ⚡',
    'bhai full support h aapko ❤️',
  ];

  static const List<String> _authenticQuestionMessages = [
    'bhai konsa phone use kr rhe ho?',
    'audio clear aa rhi h na sabhi ko?',
    'dinner kar liya bhai?',
    'aaj itni late live bro? 😂',
    'kahan se live ho abhi bhai?',
    'next live kab aane wale ho?',
    'bhai camera kafi crisp h aaj 👌',
    'bhai ek baar shoutout de do na please 🙏',
    'college ke baad direct live join kiya lol',
    'room setup kafi clean h bro',
    'bhai smile karo ek baar 😁',
    'background music konsa chal rha h bro?',
    'filter konsa use kiya h bro?',
    'aaj energy full on lag rahi hai!',
    'pune se kaun kaun live dekh rha h?',
    'delhi se koi h kya chat me?',
    'bhai mera naam bol do na ek baar ❤️',
    'kal wala stream bohot mast tha bhai',
    'bhai fan on h kya thoda shor aa rha tha',
    'stream kab tak chalegi bhai aaj?',
    'konsa game khelte ho bhai?',
  ];

  static const List<String> _authenticComplimentsAndObservations = [
    'subah se notification ka wait kr rha tha',
    'video quality 10/10 hai aaj bro',
    'sound ekdum crystal clear h',
    'arre mast baat boli bhai tune 👏',
    'aaj mood kafi badhiya lag rha h',
    'maine like aur share kar diya bhai 👍',
    'double tap kar diya chat me ❤️',
    'spammed 100 hearts bro ❤️❤️❤️',
    'chal badhiya h continue karo bro',
    'face pe glow aa rha h aaj ✨',
    'clean presentation bro 👍',
    'full chill stream boss ✨',
    'dil bhej diya bhai dhada dhad 🔥',
    'bhai aawaz ekdum mast aa rhi h 👍',
    'loving the vibe today 💖',
    'so good to see you live ✨',
    'stream kafi smooth chal rhi h boss',
  ];

  static const List<String> _authenticPureEmojis = [
    '🔥🔥🔥',
    '😂😂😂',
    '❤️❤️',
    '🙌🙌🙌',
    '🔥🔥 W',
    '💯💯',
    '🫡🫡',
    '✨✨',
    '👀👀',
    '😍😍',
    '⚡⚡⚡',
    '👏🏼👏🏼',
    '🔥🔥 bhai bhai',
    '❤️❤️❤️',
    '🙌🔥',
    '🎉🎉',
    '🚀🚀',
  ];

  static const List<String> _authenticCityGreetings = [
    'love from mumbai bhai ❤️',
    'dilli walo ki taraf se salam bhai! 🙌',
    'bengaluru gang watching! 🚀',
    'punjab se salam bhai 🙌',
    'hyderabad wale bhi attend kr rhe h! ✨',
    'kolkata se big fan bro ❤️',
    'lucknow se dher sara pyar 🌸',
    'chennai gang tuning in! 🔥',
    'jaipur se ram ram brother 🙏',
    'ahmedabad se full support bhai!',
    'pune gang assemble! 🔥',
    'bhopal se cheers bhai 🙌',
    'namaste bhaiya kaise ho sab?',
    'kem cho bhai! full support ❤️',
    'vanakkam anna! audio full clear 👍',
  ];

  static String _resolveLanguageKey(String? streamLanguage) {
    if (streamLanguage == null || streamLanguage.isEmpty) return 'hinglish';
    final l = streamLanguage.toLowerCase();
    if (l.contains('hinglish')) return 'hinglish';
    if (l.contains('hindi')) return 'hindi';
    return 'english';
  }

  static const List<String> realisticPhotoUrls = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1501196354995-cbb51c65aaea?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1548142813-c348350df52b?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1543610892-0b1f7e6d8ac1?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1544717305-2782549b5136?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1517486808947-6468a487dd56?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1507152832244-10d45c7eda57?w=100&h=100&fit=crop&crop=faces&q=80',
    'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=100&h=100&fit=crop&crop=faces&q=80',
  ];

  static const List<String> _dynamicIndianUsernames = [
    'rohit_kumar_99', 'sneha.sharmaa', 'kabir_vlogs', 'priya.p_', 'its_aryan_07',
    'aman.verma.official', 'neha_singh22', 'rahul_fitness_', 'kavya__m', 'arjun_reddy_fan',
    'pooja_rani_', 'aditya_001', 'simran.kaur_', 'rajesh_sharma', 'muskan.shk',
    'yash_jain_', 'shreya_designs', 'sameer_khan_7', 'divya_p', 'harsh_gupta_',
    'ananya.r_', 'karan_malhotra', 'riya_sen_', 'tanya.d', 'mohit_sharma_',
    'deepak_yadav9', 'ishaan_verma', 'tanvi_kulkarni', 'abhishek_09', 'sonali.singh_',
    'varun_patel_', 'siddharth_m', 'khushi__24', 'manish_rawat', 'jyoti_kumari_',
    'nikhil_teja_', 'swati_k_', 'gaurav_sharma', 'zoya_mirza_', 'alok_kumar_',
    'sunita_verma', 'faizan_ahmed_', 'megha_gupta', 'tarun_singh_', 'rashmi_nair',
    'vishal_b', 'komal.sharma_', 'sachin_rajput', 'anmol_v', 'bhavna_patel',
    'roshan_jha', 'kareena_v', 'vivek_sharma9', 'ritu_yadav', 'chaitanya_v',
    'mayank_verma', 'prachi_singh', 'dev_patel_', 'akanksha_m', 'sunny_deol_fan',
    'vikas_m', 'palak_k', 'kartik_arya', 'nandini_r', 'ashish_chawla',
    'shweta_singh_', 'suraj_pandey', 'monika_jain', 'aravind_k', 'deepika_p_',
  ];

  static const List<Color> _dynamicAvatarColors = [
    Color(0xFF6C5CE7),
    Color(0xFF00B894),
    Color(0xFFE17055),
    Color(0xFFFD79A8),
    Color(0xFF0984E3),
    Color(0xFFE84393),
    Color(0xFF00CEC9),
    Color(0xFFF39C12),
    Color(0xFF27AE60),
    Color(0xFF8E44AD),
    Color(0xFFD63031),
    Color(0xFF2ED573),
  ];

  /// Returns an authentic, colloquial social media comment from a randomly selected profile
  static AiCommentEmission sampleEmission({String? streamLanguage}) {
    List<AiViewerProfile> pool = profiles;
    if (streamLanguage != null && streamLanguage.isNotEmpty) {
      final langKey = _resolveLanguageKey(streamLanguage);
      final matched = profiles.where((p) {
        final pref = p.preferredLanguage.toLowerCase();
        return pref.contains(langKey) || pref.contains('hinglish') || pref.contains('hindi') || pref.contains('english');
      }).toList();
      if (matched.isNotEmpty) {
        pool = matched;
      }
    }

    final roll = _random.nextInt(100);

    String message;
    if (roll < 28) {
      message = _authenticHypeMessages[_random.nextInt(_authenticHypeMessages.length)];
    } else if (roll < 54) {
      message = _authenticQuestionMessages[_random.nextInt(_authenticQuestionMessages.length)];
    } else if (roll < 74) {
      message = _authenticComplimentsAndObservations[_random.nextInt(_authenticComplimentsAndObservations.length)];
    } else if (roll < 88) {
      message = _authenticPureEmojis[_random.nextInt(_authenticPureEmojis.length)];
    } else if (roll < 95) {
      message = _authenticCityGreetings[_random.nextInt(_authenticCityGreetings.length)];
    } else {
      final p = pool[_random.nextInt(pool.length)];
      message = p.sampleComments[_random.nextInt(p.sampleComments.length)];
    }

    // Generate dynamic or catalog persona so senders change constantly
    AiViewerProfile profile;
    if (_random.nextInt(100) < 65) {
      // Pick from dynamic Indian Instagram handles
      final username = _dynamicIndianUsernames[_random.nextInt(_dynamicIndianUsernames.length)];
      final hasNoPhoto = _random.nextInt(100) < 35; // 35% have no profile photo (blank silhouette)
      final photo = hasNoPhoto ? null : realisticPhotoUrls[_random.nextInt(realisticPhotoUrls.length)];
      final color = _dynamicAvatarColors[_random.nextInt(_dynamicAvatarColors.length)];
      profile = AiViewerProfile(
        id: 'dyn_${_random.nextInt(9999)}',
        name: username,
        city: 'India',
        archetype: 'Viewer',
        preferredLanguage: streamLanguage ?? 'Hinglish',
        avatarColor: color,
        avatarUrl: photo,
        sampleComments: const [],
      );
    } else {
      profile = pool[_random.nextInt(pool.length)];
    }

    return AiCommentEmission(
      profile: profile,
      message: message,
    );
  }

  /// Generates a contextual comment from the 30 Indian personas reacting to host visual cues
  static AiCommentEmission sampleVisualReaction({
    required VisionEventType eventType,
    String? streamLanguage,
  }) {
    List<AiViewerProfile> pool = profiles;
    if (streamLanguage != null && streamLanguage.isNotEmpty) {
      final langKey = _resolveLanguageKey(streamLanguage);
      final matched = profiles.where((p) => p.preferredLanguage.toLowerCase().contains(langKey)).toList();
      if (matched.isNotEmpty) {
        pool = matched;
      }
    }
    final profile = pool[_random.nextInt(pool.length)];
    final langKey = _resolveLanguageKey(streamLanguage ?? profile.preferredLanguage);
    String message;

    switch (eventType) {
      case VisionEventType.highMotion:
        switch (langKey) {
          case 'kannada':
            message = [
              'ಬೆಂಕಿ ಮೂವ್ಸ್ ಬ್ರೋ! ವೇವಿಂಗ್ ಬ್ಯಾಕ್ 👋🔥',
              'ಫುಲ್ ಎನರ್ಜಿ ನಡೀತಿದೆ ಅಣ್ಣ ⚡',
              'ಏನ್ ಎನರ್ಜಿ ಬ್ರೋ ಇವತ್ತು ಸೂಪರ್! 🚀',
            ][_random.nextInt(3)];
            break;
          case 'urdu':
            message = [
              'بھائی کیا زبردست انرجی ہے! وائونگ بیک 👋🔥',
              'فل جوش میں ہیں بھائی آپ ⚡',
              'کمال کی اسپیڈ ہے بھائی ماشاءاللہ! 🚀',
            ][_random.nextInt(3)];
            break;
          case 'tamil':
            message = [
              'செம்ம மூவ்ஸ் தலைவா! வேவிங் பேக் 👋🔥',
              'மாஸ் எனர்ஜி ப்ரோ இன்னைக்கு ⚡',
              'வேற லெவல் வேகம் அண்ணா! 🚀',
            ][_random.nextInt(3)];
            break;
          case 'telugu':
            message = [
              'అదిరిపోయే ఎనర్జీ అన్నా! వేవింగ్ బ్యాక్ 👋🔥',
              'ఫుల్ జోష్ లో ఉన్నారు బ్రో ⚡',
              'కేక మూమెంట్స్ అన్నా సూపర్! 🚀',
            ][_random.nextInt(3)];
          case 'malayalam':
            message = [
              'കിടിലൻ എനർജി ബ്രോ! വേവിങ് ബാക്ക് 👋🔥',
              'മാസ്സ് മൂവ്സ് അളിയാ ഇന്ന് ⚡',
              'വേറെ ലെവൽ വൈബ്സ് ബ್ರೋ! 🚀',
            ][_random.nextInt(3)];
          case 'hindi':
            message = [
              'अरे भाई भाई क्या एनर्जी है! वेविंग बैक 👋🔥',
              'फुल जोश में हो भाई आज ⚡',
              'गज़ब मूवमेंट है भाई एकदम 🚀',
            ][_random.nextInt(3)];
          case 'hinglish':
            message = [
              'arre bhai bhai itni energy lol 😂',
              'waving back bhai! 👋👋',
              'bhai kya wave kiya style me 🔥',
              'full josh me ho aaj bhai ⚡',
              'heyy brother! 👋',
              'bhai full fire movements! 🔥',
            ][_random.nextInt(6)];
            break;
          case 'english':
          default:
            message = [
              'energy is insane today! 🔥',
              'huge wave back bro! 👋',
              'hyped up right now! 🚀',
              'full energy vibes! ✨',
            ][_random.nextInt(4)];
            break;
        }
        break;

      case VisionEventType.closeUpFocus:
        switch (langKey) {
          case 'kannada':
            message = [
              'ಕ್ಯಾಮರಾ ಹತ್ತಿರ ತಂದು ತೋರಿಸಿ ಬ್ರೋ 👀',
              'ಏನ್ ಐಟಂ ಇದು ಅಣ್ಣ? ಲುಕ್ ಸೂಪರ್ 👌',
              'ಕ್ಲಿಯರ್ ಆಗಿ ಕಾಣ್ತಿದೆ ಕಂಟಿನ್ಯೂ ಮಾಡಿ 🔍',
            ][_random.nextInt(3)];
            break;
          case 'urdu':
            message = [
              'کیمرے کے تھوڑا اور قریب لائیں بھائی 👀',
              'یہ کیا چیز ہے بھائی؟ لک بہت پریمیم ہے 👌',
              'بالکل صاف نظر آ رہا ہے کنٹینیو کریں 🔍',
            ][_random.nextInt(3)];
          case 'tamil':
            message = [
              'கேமரா பக்கத்துல காட்டுங்க தலைவா 👀',
              'இது என்ன பொருள் ப்ரோ? பாக்கவே செம்ம 👌',
              'தெளிவா தெரியுது கண்டினியூ பண்ணுங்க 🔍',
            ][_random.nextInt(3)];
          case 'telugu':
            message = [
              'కెమెరా దగ్గరికి తెచ్చి చూపించండి అన్నా 👀',
              'ఇది ఏమిటి అన్నా? లుక్ చాలా బాగుంది 👌',
              'క్లియర్‌గా కనిపిస్తుంది కంటిన్యూ చేయండి 🔍',
            ][_random.nextInt(3)];
          case 'malayalam':
            message = [
              'ക്യാമറയുടെ അടുത്തേക്ക് കൊണ്ടുവരൂ ബ്രോ 👀',
              'ഇതെന്താണ് സാധനം അളിയാ? സൂപ്പറായിട്ടുണ്ട് 👌',
              'വ്യക്തമായി കാണാം കണ്ടിന്യൂ ചെയ്യൂ 🔍',
            ][_random.nextInt(3)];
          case 'hindi':
            message = [
              'कैमरे के थोड़ा और पास लाओ भाई 👀',
              'ये क्या दिखा रहे हो भाई? लुक एकदम मस्त है 👌',
              'साफ दिख रहा है भाई कंटिन्यू करो 🔍',
            ][_random.nextInt(3)];
          case 'hinglish':
            message = [
              'bhai camera ke thoda aur paas laao 👀',
              'yeh kya dikha rhe ho bhai? mast h 👌',
              'clear dikh rha h bro continue 🔍',
              'arre waah kya cheez h yeh 🔥',
              'konsa brand h bhai? look to premium h 👌',
            ][_random.nextInt(5)];
            break;
          case 'english':
          default:
            message = [
              'show that closer to camera! 🔍',
              'looking super clean! 👌',
              'what model is that bro? 👀',
              'sharp focus on that view! ✨',
            ][_random.nextInt(4)];
            break;
        }
        break;

      case VisionEventType.lightingShift:
        switch (langKey) {
          case 'kannada':
            message = 'ಲೈಟಿಂಗ್ ಸೆಟಪ್ ಇವಾಗ ಸ್ಟುಡಿಯೋ ತರ ಆಯ್ತು! 💡';
            break;
          case 'urdu':
            message = 'لائٹنگ اسٹوڈیو والی ہو گئی بھائی اب! 💡';
            break;
          case 'tamil':
            message = 'லைட்டிங் இப்போ ஸ்டுடியோ மாதிரி ஆச்சு தலைவா! 💡';
            break;
          case 'telugu':
            message = 'లైటింగ్ ఇప్పుడు స్టూడియో లాగా మారింది అన్నా! 💡';
            break;
          case 'malayalam':
            message = 'ലൈറ്റിംഗ് സ്റ്റുഡിയോ പോലെയായിട്ടുണ്ട് ഇപ്പോൾ! 💡';
            break;
          case 'hindi':
            message = 'लाइटिंग एकदम स्टूडियो वाली हो गई अब! 💡';
            break;
          case 'hinglish':
            message = [
              'lighting ekdum studio wali ho gyi ab! 💡',
              'ab face pe glow aa rha h bhai ✨',
              'kya lighting setup h boss 🌟',
            ][_random.nextInt(3)];
            break;
          case 'english':
          default:
            message = [
              'lighting leveled up! looks crisp 💡',
              'nice lighting shift! ✨',
            ][_random.nextInt(2)];
            break;
        }
        break;

      case VisionEventType.idleOrAway:
        final idleRoll = _random.nextInt(100);
        if (idleRoll < 35) {
          message = _authenticComplimentsAndObservations[_random.nextInt(_authenticComplimentsAndObservations.length)];
        } else if (idleRoll < 60) {
          message = _authenticQuestionMessages[_random.nextInt(_authenticQuestionMessages.length)];
        } else if (idleRoll < 80) {
          message = _authenticPureEmojis[_random.nextInt(_authenticPureEmojis.length)];
        } else {
          switch (langKey) {
            case 'kannada':
              message = 'ಬ್ರೋ ನೀರು ಕುಡಿಯೋಕೆ ಹೋಗಿದ್ದಾರೆ ಅನ್ಸುತ್ತೆ 🙌';
              break;
            case 'urdu':
              message = 'پانی پینے گئے ہیں بھائی شاید آرام سے آئیں 🙌';
              break;
            case 'tamil':
              message = 'ப்ரோ தண்ணி குடிக்க போயிருக்காரு போல ரிலாக்ஸ் 🙌';
              break;
            case 'telugu':
              message = 'అన్నా నీళ్లు తాగడానికి వెళ్లినట్లున్నారు కూల్ 🙌';
              break;
            case 'malayalam':
              message = 'ബ്രോ വെള്ളം കുടിക്കാൻ പോയതാണെന്ന് തോന്നുന്നു റിലാക്സ് 🙌';
              break;
            case 'hindi':
              message = 'पानी पीने गए हैं भाई शायद, टेक योर टाइम 🙌';
              break;
            case 'hinglish':
              message = [
                'pani peene gye lagta h lol 💧',
                'koi na bhai take your time 🙌',
                'waiting right here bro! ✨',
                'quick water break haha 👍',
              ][_random.nextInt(4)];
              break;
            case 'english':
            default:
              message = [
                'take your time bro! waiting right here 🙌',
                'quick break haha! stream is smooth ✨',
              ][_random.nextInt(2)];
              break;
          }
        }
        break;

      case VisionEventType.personEntered:
        switch (langKey) {
          case 'kannada':
            message = [
              'ಅರೇ ಬ್ರೋ ಹಿಂದೆ ಯಾರೋ ಬಂದ್ರು ನೋಡಿ! 👀',
              'ಅಣ್ಣ ಹಿಂದಿರೋ ಫ್ರೆಂಡ್‌ಗೆ ಹಾಯ್ ಹೇಳಿ! 👋',
              'ಇಬ್ಬರೂ ಒಟ್ಟಿಗೆ ಫ್ರೇಮ್‌ನಲ್ಲಿ ಬನ್ನಿ ಬ್ರೋ! 🙌',
            ][_random.nextInt(3)];
            break;
          case 'urdu':
            message = [
              'ارے بھائی پیچھے کون آیا؟ 👀',
              'بھائی پیچھے دوست سے کہیں ہائے کریں! 👋',
              'دونوں بھائی ایک ساتھ فریم میں آئیں! 🙌',
            ][_random.nextInt(3)];
          case 'tamil':
            message = [
              'அட தலைவா பின்னாடி யாரு அது? 👀',
              'ப்ரோ பின்னாடி இருக்கிற நண்பர ஹாய் சொல்ல சொல்லுங்க! 👋',
              'ரெண்டு பேரும் ஒன்னா ஃபிரேம்ல வாங்க தலைவா! 🙌',
            ][_random.nextInt(3)];
          case 'telugu':
            message = [
              'అరే అన్నా వెనుక ఎవరు వచ్చారు? 👀',
              'బ్రదర్ వెనుక ఉన్న ఫ్రెండ్‌ని హాయ్ చెప్పమనండి! 👋',
              'ఇద్దరూ కలిసి ఫ్రేమ్‌లో రండి బ్రదర్స్! 🙌',
            ][_random.nextInt(3)];
          case 'malayalam':
            message = [
              'അളിയാ പിന്നിൽ ആരാണ് വന്നത്? 👀',
              'ബ്രോ പിന്നിലുള്ള ഫ്രണ്ടിനോട് ഹായ് പറയാൻ പറ! 👋',
              'രണ്ടുപേരും കൂടെ ഫ്രെയിമിൽ വന്ന് ലൈവ് ചെയ്യ്! 🙌',
            ][_random.nextInt(3)];
          case 'hindi':
            message = [
              'अरे भाई पीछे कौन आया? 👀',
              'भाई पीछे दोस्त से बोलो कैमरे पे हाय करे! 👋',
              'दोनों भाई फ्रेम में आओ साथ में! 🙌',
            ][_random.nextInt(3)];
          case 'hinglish':
            message = [
              'arre bhai peeche kaun aaya? 👀',
              'bhai peeche tumhara dost hai kya? introduce karo na!',
              'who is that in the background bro? 😂',
              'bhai peeche wale bhai ko bolo camera pe hi kare 👋',
              'dono bhai frame me aao sath me!',
            ][_random.nextInt(5)];
            break;
          case 'english':
          default:
            message = [
              'who\'s that in the background bro? 😂',
              'someone just joined behind you! introduce them!',
              'tell your friend in the back to say hi! 👋',
              'squad stream today! get them on camera!',
            ][_random.nextInt(4)];
            break;
        }
        break;

      case VisionEventType.normal:
        message = _authenticHypeMessages[_random.nextInt(_authenticHypeMessages.length)];
        break;
    }

    return AiCommentEmission(
      profile: profile,
      message: message,
    );
  }

  /// Look up an AI profile by name, or match first name, or fallback to deterministic profile
  static AiViewerProfile findProfile(String name) {
    return profiles.firstWhere(
      (p) => p.name.trim().toLowerCase() == name.trim().toLowerCase(),
      orElse: () => profiles.firstWhere(
        (p) => name.toLowerCase().contains(p.name.split(' ').first.toLowerCase()),
        orElse: () => profiles[_random.nextInt(profiles.length)],
      ),
    );
  }

  /// Generates an engaging Live Task / Challenge / Dare from audience personas in all 8 Indian languages
  static AiCommentEmission sampleLiveTask({
    String? streamLanguage,
    bool hasPersonInFrame = false,
  }) {
    List<AiViewerProfile> candidates = profiles;
    if (streamLanguage != null && streamLanguage.isNotEmpty) {
      final langKey = _resolveLanguageKey(streamLanguage);
      final matched = profiles
          .where((p) => p.preferredLanguage.toLowerCase().contains(langKey))
          .toList();
      if (matched.isNotEmpty) {
        candidates = matched;
      }
    }

    final profile = candidates[_random.nextInt(candidates.length)];
    final langKey = _resolveLanguageKey(streamLanguage ?? profile.preferredLanguage);

    final List<String> tasks;
    if (hasPersonInFrame) {
      switch (langKey) {
        case 'kannada':
          tasks = [
            '🎯 Live Task: ಹಿಂದಿರೋ ಫ್ರೆಂಡ್‌ಗೆ ಹೈ-ಫೈವ್ ಕೊಡಿ! 🙌',
            '🎯 Task: ಫ್ರೆಂಡ್‌ಗೆ ಕ್ಯಾಮೆರಾ ಮುಂದು ಬಂದು ಹಾಯ್ ಹೇಳೋಕೆ ಹೇಳಿ 😂',
            '🎯 Challenge: ಇಬ್ಬರೂ ಸೇರಿ 5 ಸೆಕೆಂಡ್ ಫನ್ನಿ ಪೋಸ್ ಕೊಡಿ 📸',
            '🎯 Task: ಫ್ರೆಂಡ್‌ ಹೆಸರು ಲೈವ್‌ನಲ್ಲಿ ಹೇಳಿ ಬ್ರೋ 🎙️',
          ];
          break;
        case 'urdu':
          tasks = [
            '🎯 Live Task: پیچھے دوست کے ساتھ ہائی فائیو کریں! 🙌',
            '🎯 Task: دوست سے کہیں کیمرے پہ آ کر ہائے کہیں 😂',
            '🎯 Challenge: دونوں بھائی 5 سیکنڈ کے لیے فنی پوز بنائیں 📸',
            '🎯 Task: پیچھے دوست کا نام بتائیں بھائی 🎙️',
          ];
          break;
        case 'tamil':
          tasks = [
            '🎯 Live Task: பின்னாடி இருக்கிற நண்பருக்கு ஹை-ஃபைவ் குடுங்க! 🙌',
            '🎯 Task: நண்பர கேமரா முன்னாடி வந்து ஹாய் சொல்ல சொல்லுங்க 😂',
            '🎯 Challenge: ரெண்டு பேரும் சேர்ந்து 5 செகண்ட் ஃபன்னி போஸ் குடுங்க 📸',
            '🎯 Task: நண்பரோட பேர லைவ்ல சொல்லுங்க தலைவா 🎙️',
          ];
          break;
        case 'telugu':
          tasks = [
            '🎯 Live Task: వెనుక ఉన్న ఫ్రెండ్‌తో హై-ఫైవ్ ఇవ్వండి! 🙌',
            '🎯 Task: ఫ్రెండ్‌ని స్క్రీన్ ముందుకు వచ్చి హాయ్ చెప్పమనండి 😂',
            '🎯 Challenge: ఇద్దరూ కలిసి 5 సెకన్లు ఫన్నీ పోజ్ ఇవ్వండి 📸',
            '🎯 Task: ఫ్రెండ్ పేరు చెప్పి పరిచయం చేయండి అన్నా 🎙️',
          ];
          break;
        case 'malayalam':
          tasks = [
            '🎯 Live Task: പിന്നിലുള്ള ഫ്രണ്ടിന് ഹൈ-ഫൈവ് കൊടുക്ക്! 🙌',
            '🎯 Task: ഫ്രണ്ടിനോട് ക്യാമറയ്ക്ക് മുന്നിൽ വന്ന് ഹായ് പറയാൻ പറ 😂',
            '🎯 Challenge: രണ്ടുപേരും ചേർന്ന് 5 സെക്കൻഡ് ഫണ്ണി പോസ് ചെയ്യൂ 📸',
            '🎯 Task: ഫ്രണ്ടിന്റെ പേര് ലൈവിൽ പറ അളിയാ 🎙️',
          ];
          break;
        case 'hindi':
          tasks = [
            '🎯 Live Task: पीछे वाले दोस्त के साथ हाई-फाइव करो! 🙌',
            '🎯 Task: पीछे दोस्त से बोलो कैमरे पे आके हाय करे 😂',
            '🎯 Challenge: दोनों भाई मिलके 5 सेकंड फनी पोज़ बनाओ 📸',
            '🎯 Task: पीछे वाले दोस्त का नाम बताओ लाइव में 🎙️',
          ];
          break;
        case 'hinglish':
          tasks = [
            '🎯 Live Task: Peeche wale bhai ke sath high five karo! 🙌',
            '🎯 Task: Peeche dost se bolo screen pe aake wave kare 😂',
            '🎯 Challenge: Dono bhai milke 5 seconds tak funny pose banao 📸',
            '🎯 Task: Peeche wale bhai ko bolo apna naam live me bataye 🎙️',
            '🎯 Dare: Dono bhai ek sath shoutout do audience ko! 🔥',
          ];
          break;
        case 'english':
        default:
          tasks = [
            '🎯 Live Task: Give a high-five to the person behind you! 🙌',
            '🎯 Task: Ask your friend to come in front and say hi! 👋',
            '🎯 Challenge: Strike a funny pose together for 5 seconds! 📸',
            '🎯 Task: Introduce the person behind you on stream! 🎙️',
          ];
          break;
      }
    } else {
      switch (langKey) {
        case 'kannada':
          tasks = [
            '🎯 Task: ಒಂದು ಫೇವರಿಟ್ ಕನ್ನಡ ಹಾಡು ಹಾಡಿ ಪ್ಲೀಸ್ 🎵',
            '🎯 Challenge: 10 ಸೆಕೆಂಡ್ ನಗದೆ ಇರೋ ಚಾಲೆಂಜ್ 😁',
            '🎯 Dare: ನಿಮ್ಮ ರೂಮ್ / ಸ್ಟುಡಿಯೋ 360 ವ್ಯೂವ್ ತೋರಿಸಿ 🔄',
            '🎯 Task: ಕೆಜಿಎಫ್ ಅಥವಾ ಕಾಂತಾರ ಮಾಸ್ ಡೈಲಾಗ್ ಹೇಳಿ! 🎬',
            '🎯 Dare: ಲೈವ್‌ನಲ್ಲಿ 5 ಪುಷ್-ಅಪ್ಸ್ ಮಾಡಿ ಬ್ರೋ 💪',
          ];
          break;
        case 'urdu':
          tasks = [
            '🎯 Task: کوئی پسندیدہ غزل یا گانا گائیں 🎵',
            '🎯 Challenge: 10 سیکنڈ تک بغیر ہنسے مسکرانے کا چیلنج 😁',
            '🎯 Dare: اپنے کمرے کا 360 ویو دکھائیں 🔄',
            '🎯 Task: کوئی زبردست فلمی ڈائیلاگ سنائیں 🎬',
            '🎯 Dare: 5 پش اپس لگا کر دکھائیں بھائی 💪',
          ];
          break;
        case 'tamil':
          tasks = [
            '🎯 Task: ஒரு தமிழ் பாட்டு பாடுங்க ப்ரோ 🎵',
            '🎯 Challenge: 10 செகண்ட் சிரிக்காம இருக்கிற சேலஞ்ச் 😁',
            '🎯 Dare: உங்க ரூம் / ஸ்டுடியோவ 360 டிகிரி சுத்தி காட்டுங்க 🔄',
            '🎯 Task: ஒரு ரஜினி அல்லது விஜய் மாஸ் டயலாக் பேசுங்க! 🎬',
            '🎯 Dare: லைவ்ல 5 புஷ்-அப்ஸ் பண்ணி காட்டுங்க 💪',
          ];
          break;
        case 'telugu':
          tasks = [
            '🎯 Task: మీకు ఇష్టమైన తెలుగు పాట పాడండి 🎵',
            '🎯 Challenge: 10 సెకన్లు నవ్వకుండా ఉండే ఛాలెంజ్ 😁',
            '🎯 Dare: మీ రూమ్ 360 వ్యూ చూపించండి 🔄',
            '🎯 Task: ఒక మాస్ తెలుగు సినిమా డైలాగ్ చెప్పండి! 🎬',
            '🎯 Dare: లైవ్‌లో 5 పుష్-అప్స్ చేసి చూపించండి అన్నా 💪',
          ];
          break;
        case 'malayalam':
          tasks = [
            '🎯 Task: ഒരു ഇഷ്ടപ്പെട്ട മലയാളം പാട്ട് പാടൂ 🎵',
            '🎯 Challenge: 10 സെക്കൻഡ് ചിരിക്കാതെ നിൽക്കുന്ന ചാലഞ്ച് 😁',
            '🎯 Dare: റൂമിന്റെ 360 വ്യൂ കാണിക്കൂ 🔄',
            '🎯 Task: ഒരു മോഹൻലാൽ അല്ലെങ്കിൽ മമ്മൂട്ടി മാസ് ഡയലോഗ് പറയൂ! 🎬',
            '🎯 Dare: ലൈവിൽ 5 പുഷ്-അപ്സ് എടുത്തു കാണിക്കൂ 💪',
          ];
          break;
        case 'hindi':
          tasks = [
            '🎯 Task: एक पसंदीदा हिंदी गाना गा दो ना प्लीज 🎵',
            '🎯 Challenge: 10 सेकंड लगातार बिना हँसे स्माइल चैलेंज 😁',
            '🎯 Dare: अपने रूम या स्टूडियो का 360 व्यू दिखाओ 🔄',
            '🎯 Task: कोई फेमस बॉलीवुड डायलॉग बोलके दिखाओ फुल स्टाइल में! 🎬',
            '🎯 Dare: 5 पुशअप्स लगा के दिखाओ लाइव पे अगर दम है 💪',
          ];
          break;
        case 'hinglish':
          tasks = [
            '🎯 Task: Ek favorite Hindi gaana gaa do na please 🎵',
            '🎯 Challenge: 10 second continuous smile challenge bina hase 😁',
            '🎯 Dare: Apna room ya studio ka 360 view dikhao stream pe 🔄',
            '🎯 Task: Koi famous Bollywood dialogue bolke dikhao full attitude me! 🎬',
            '🎯 Dare: 5 pushups laga ke dikhao live pe agar dum h 💪',
            '🎯 Challenge: Phone ka back camera switch karke view dikhao! 📱',
            '🎯 Task: Chat me top 3 commenters ke naam leke shoutout do 🎙️',
          ];
          break;
        case 'english':
        default:
          tasks = [
            '🎯 Task: Sing a few lines of your favorite song! 🎵',
            '🎯 Challenge: Do a 10-second no-laughing smile challenge! 😁',
            '🎯 Dare: Do a quick 360 spin of your room or setup! 🔄',
            '🎯 Task: Say your favorite movie dialogue with full drama! 🎬',
            '🎯 Dare: Drop 5 pushups on camera right now! 💪',
            '🎯 Challenge: Flip to the back camera and show the view! 📱',
            '🎯 Task: Shout out the top 3 commenters in the chat! 🎙️',
          ];
          break;
      }
    }

    final chosenTask = tasks[_random.nextInt(tasks.length)];
    return AiCommentEmission(
      profile: profile,
      message: chosenTask,
    );
  }
}

class AiCommentEmission {
  final AiViewerProfile profile;
  final String message;

  const AiCommentEmission({
    required this.profile,
    required this.message,
  });
}
