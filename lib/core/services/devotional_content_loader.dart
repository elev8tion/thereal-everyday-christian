import 'package:uuid/uuid.dart';
import 'database_service.dart';

/// Loads initial devotional content into the database
class DevotionalContentLoader {
  final DatabaseService _database;
  final Uuid _uuid = const Uuid();

  DevotionalContentLoader(this._database);

  /// Load 30 days of devotional content
  Future<void> loadDevotionals() async {
    final db = await _database.database;

    // Check if devotionals already exist
    final existing = await db.query('devotionals', limit: 1);
    if (existing.isNotEmpty) {
      return;
    }


    final devotionals = _getDevotionalContent();

    for (final devotional in devotionals) {
      await db.insert('devotionals', devotional);
    }

  }

  List<Map<String, dynamic>> _getDevotionalContent() {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    return [
      // Day 1
      {
        'id': _uuid.v4(),
        'title': 'Walking in Faith',
        'subtitle': 'Trust in God\'s Plan',
        'content': 'Today, let\'s reflect on what it means to truly trust in the Lord. When we walk by faith and not by sight, we acknowledge that God\'s ways are higher than our ways. His plan for our lives is perfect, even when we can\'t see the full picture.\n\nFaith isn\'t the absence of doubt—it\'s choosing to trust God despite our uncertainties. Like Abraham, who left his homeland without knowing where he was going, we too are called to step out in faith, trusting that God will guide our every step.\n\nToday, surrender your worries to God and trust that He is working all things together for your good.',
        'verse': 'Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.',
        'verse_reference': 'Proverbs 3:5-6',
        'date': startOfToday.millisecondsSinceEpoch,
        'reading_time': '5 min read',
        'is_completed': 0,
      },
      // Day 2
      {
        'id': _uuid.v4(),
        'title': 'The Power of Prayer',
        'subtitle': 'Communicating with God',
        'content': 'Prayer is our direct line to the Creator of the universe. It\'s not just a religious ritual—it\'s an intimate conversation with our Heavenly Father who loves us deeply.\n\nWhen we pray, we align our hearts with God\'s will. We bring our joys, our sorrows, our requests, and our thanksgiving before Him. Prayer changes things, but more importantly, it changes us.\n\nDon\'t underestimate the power of your prayers. God hears every word, sees every tear, and knows every need before you even ask.',
        'verse': 'Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.',
        'verse_reference': 'Philippians 4:6',
        'date': startOfToday.add(const Duration(days: 1)).millisecondsSinceEpoch,
        'reading_time': '4 min read',
        'is_completed': 0,
      },
      // Day 3
      {
        'id': _uuid.v4(),
        'title': 'God\'s Perfect Love',
        'subtitle': 'Experiencing Divine Love',
        'content': 'In a world where love is often conditional, God\'s love stands apart. His love for you isn\'t based on your performance, your achievements, or your worthiness. It\'s unconditional, unchanging, and everlasting.\n\nGod loved you before you were born. He loves you in your victories and in your failures. There is absolutely nothing you can do to make Him love you more, and nothing you can do to make Him love you less.\n\nToday, rest in the truth that you are completely and perfectly loved by God.',
        'verse': 'For I am convinced that neither death nor life, neither angels nor demons, neither the present nor the future, nor any powers, neither height nor depth, nor anything else in all creation, will be able to separate us from the love of God that is in Christ Jesus our Lord.',
        'verse_reference': 'Romans 8:38-39',
        'date': startOfToday.add(const Duration(days: 2)).millisecondsSinceEpoch,
        'reading_time': '5 min read',
        'is_completed': 0,
      },
      // Day 4
      {
        'id': _uuid.v4(),
        'title': 'Finding Peace',
        'subtitle': 'Rest in God\'s Presence',
        'content': 'In the midst of life\'s storms, God offers us a peace that surpasses all understanding. This isn\'t a peace that depends on our circumstances being perfect—it\'s a deep, abiding peace that comes from knowing God is in control.\n\nJesus calmed the storm with just a word. The same power that spoke creation into existence is available to calm the storms in your life today.\n\nWhen anxiety threatens to overwhelm you, turn to God. Let His peace guard your heart and mind.',
        'verse': 'And the peace of God, which transcends all understanding, will guard your hearts and your minds in Christ Jesus.',
        'verse_reference': 'Philippians 4:7',
        'date': startOfToday.add(const Duration(days: 3)).millisecondsSinceEpoch,
        'reading_time': '4 min read',
        'is_completed': 0,
      },
      // Day 5
      {
        'id': _uuid.v4(),
        'title': 'Strength in Weakness',
        'subtitle': 'God\'s Power Made Perfect',
        'content': 'It\'s in our moments of greatest weakness that God\'s strength shines brightest. When we come to the end of ourselves, we discover that God\'s grace is sufficient for every need.\n\nPaul learned this truth when God told him, "My grace is sufficient for you, for my power is made perfect in weakness." Our limitations become opportunities for God to display His limitless power.\n\nToday, don\'t hide your weaknesses. Bring them to God and watch His strength be made perfect in you.',
        'verse': 'But he said to me, "My grace is sufficient for you, for my power is made perfect in weakness."',
        'verse_reference': '2 Corinthians 12:9',
        'date': startOfToday.add(const Duration(days: 4)).millisecondsSinceEpoch,
        'reading_time': '5 min read',
        'is_completed': 0,
      },
      // Day 6
      {
        'id': _uuid.v4(),
        'title': 'The Joy of Salvation',
        'subtitle': 'Celebrating God\'s Grace',
        'content': 'Salvation is not just a one-time event—it\'s a daily celebration of God\'s amazing grace. Every day we have the opportunity to marvel at the incredible gift we\'ve received through Jesus Christ.\n\nWe were lost, but now we\'re found. We were enslaved to sin, but now we\'re free. We were separated from God, but now we\'re His beloved children.\n\nLet the joy of your salvation overflow in your life today. Share this good news with others who need to experience God\'s transforming love.',
        'verse': 'Restore to me the joy of your salvation and grant me a willing spirit, to sustain me.',
        'verse_reference': 'Psalm 51:12',
        'date': startOfToday.add(const Duration(days: 5)).millisecondsSinceEpoch,
        'reading_time': '4 min read',
        'is_completed': 0,
      },
      // Day 7
      {
        'id': _uuid.v4(),
        'title': 'Hope in God',
        'subtitle': 'An Anchor for the Soul',
        'content': 'Hope is not wishful thinking—it\'s confident expectation based on God\'s promises. When we place our hope in God, we have an anchor for our soul, firm and secure.\n\nThe world\'s hope is fragile, based on changing circumstances. But our hope in God is unshakeable because it\'s rooted in His unchanging character and His faithful promises.\n\nNo matter what you\'re facing today, you can have hope. God is faithful, and He will do what He has promised.',
        'verse': 'May the God of hope fill you with all joy and peace as you trust in him, so that you may overflow with hope by the power of the Holy Spirit.',
        'verse_reference': 'Romans 15:13',
        'date': startOfToday.add(const Duration(days: 6)).millisecondsSinceEpoch,
        'reading_time': '5 min read',
        'is_completed': 0,
      },
    ];
  }
}
