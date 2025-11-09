/// Service for mapping Bible book names between English and Spanish
class BookNameService {
  // English to Spanish mapping
  static const Map<String, String> _englishToSpanish = {
    // Old Testament
    'Genesis': 'Génesis',
    'Exodus': 'Éxodo',
    'Leviticus': 'Levítico',
    'Numbers': 'Números',
    'Deuteronomy': 'Deuteronomio',
    'Joshua': 'Josué',
    'Judges': 'Jueces',
    'Ruth': 'Rut',
    '1 Samuel': '1 Samuel',
    '2 Samuel': '2 Samuel',
    '1 Kings': '1 Reyes',
    '2 Kings': '2 Reyes',
    '1 Chronicles': '1 Crónicas',
    '2 Chronicles': '2 Crónicas',
    'Ezra': 'Esdras',
    'Nehemiah': 'Nehemías',
    'Esther': 'Ester',
    'Job': 'Job',
    'Psalms': 'Salmos',
    'Proverbs': 'Proverbios',
    'Ecclesiastes': 'Eclesiastés',
    'Song of Solomon': 'Cantares',
    'Isaiah': 'Isaías',
    'Jeremiah': 'Jeremías',
    'Lamentations': 'Lamentaciones',
    'Ezekiel': 'Ezequiel',
    'Daniel': 'Daniel',
    'Hosea': 'Oseas',
    'Joel': 'Joel',
    'Amos': 'Amós',
    'Obadiah': 'Abdías',
    'Jonah': 'Jonás',
    'Micah': 'Miqueas',
    'Nahum': 'Nahúm',
    'Habakkuk': 'Habacuc',
    'Zephaniah': 'Sofonías',
    'Haggai': 'Hageo',
    'Zechariah': 'Zacarías',
    'Malachi': 'Malaquías',

    // New Testament
    'Matthew': 'Mateo',
    'Mark': 'Marcos',
    'Luke': 'Lucas',
    'John': 'Juan',
    'Acts': 'Hechos',
    'Romans': 'Romanos',
    '1 Corinthians': '1 Corintios',
    '2 Corinthians': '2 Corintios',
    'Galatians': 'Gálatas',
    'Ephesians': 'Efesios',
    'Philippians': 'Filipenses',
    'Colossians': 'Colosenses',
    '1 Thessalonians': '1 Tesalonicenses',
    '2 Thessalonians': '2 Tesalonicenses',
    '1 Timothy': '1 Timoteo',
    '2 Timothy': '2 Timoteo',
    'Titus': 'Tito',
    'Philemon': 'Filemón',
    'Hebrews': 'Hebreos',
    'James': 'Santiago',
    '1 Peter': '1 Pedro',
    '2 Peter': '2 Pedro',
    '1 John': '1 Juan',
    '2 John': '2 Juan',
    '3 John': '3 Juan',
    'Jude': 'Judas',
    'Revelation': 'Apocalipsis',
  };

  // Spanish to English mapping (generated from reverse)
  static final Map<String, String> _spanishToEnglish = {
    for (var entry in _englishToSpanish.entries) entry.value: entry.key,
  };

  /// Convert English book name to Spanish
  static String toSpanish(String englishName) {
    return _englishToSpanish[englishName] ?? englishName;
  }

  /// Convert Spanish book name to English
  static String toEnglish(String spanishName) {
    return _spanishToEnglish[spanishName] ?? spanishName;
  }

  /// Get book name based on language preference
  static String getBookName(String bookName, String language) {
    if (language == 'es') {
      return toSpanish(bookName);
    }
    return bookName; // Default to English
  }

  /// Check if a book name is in Spanish
  static bool isSpanish(String bookName) {
    return _spanishToEnglish.containsKey(bookName);
  }

  /// Check if a book name is in English
  static bool isEnglish(String bookName) {
    return _englishToSpanish.containsKey(bookName);
  }
}
