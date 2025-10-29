// ===============================================
// 1. Image Paths
// ===============================================

const Map<String, String> prayerImagePaths = {
  // ... (ናይ ጸሎት ስእልታት መንገዲ) ...
};

const Map<String, List<String>> saintsImagePaths = {
  // ... (ናይ ቅዱሳን ስእልታት መንገዲ) ...
};

const Map<String, String> singerImagePaths = {
  // ... (ናይ ዘመርቲ ስእልታት መንገዲ) ...
};


// ===============================================
// 2. Drawer and Category Data
// ===============================================

// --- ንናይ ካታጎሪታት መለለዪ ቁልፊታት ---
const String homeSectionKey = 'Home';
const String hymnsSectionKey = 'Hymns';
const String prayerSectionKey = 'Prayer';
const String mebaetaSectionKey = 'MebaetaTimhirtiKristos';
const String saintsHistorySectionKey = 'SaintsHistory';
const String rosaryCategoryKey = 'RosaryCategory';
const String fnotMsqelCategoryKey = 'FnotMsqel';
const String internalAllHymnsKey = 'All Hymns';

// --- ንናይ ድሮወር ትሕዝቶ ዝምልከት ዳታ ---
final Map<String, List<dynamic>> drawerSubCategoriesData = {
  homeSectionKey: [],
  hymnsSectionKey: [
    internalAllHymnsKey, 'ኣምልኾ', 'መንፈስ ቅዱስ', 'ምስጋና',
    {'በዓላት': ['ልደት', 'ጥምቀት', 'ሆሳዕና', 'ትንሳኤ', 'ሓድሽ ዓመት']},
    'ቅዱስ ቁርባን', 'ማርያም', 'ቅዱሳን', 'ልመና', 'ንስሓ', 'ሕማማት', 'ፀዋዕታ',
    'መዓልቲ ምውታን', 'ምፅኣት', 'ወረብ', 'ቃልኪዳን', 'ቅድስት ስድራ', 'ዝተፈላለዩ',
  ],
  prayerSectionKey: [
    {'title': 'መባእታ ናይ ትምህርቲ ክርስቶስ', 'key': mebaetaSectionKey},
    {'title': 'ፀሎት መቑፀርያ', 'key': rosaryCategoryKey},
    {'title': 'ፍኖተ መስቀል', 'key': fnotMsqelCategoryKey},
    'ፀሎት መቑፀርያ መንፈስ ቅዱስ',
    'ፀሎት ናብ መለኮታዊ ምሕረት',
    'ፀሎት ናብ ልቢ እየሱስ',
    'መቑፀርያ ቅዱስ ልቢ',
  ],
  rosaryCategoryKey: [
    'ናይ ደስታ ምስጢር', 'ናይ ብርሃን ምስጢር', 'ናይ ሕማም ምስጢር', 'ናይ ክብሪ ምስጢር',
  ],
  mebaetaSectionKey: [
    'መእተዊ', 'አቡነ ዘበሰማያት (ብግእዝ)', 'ፀሎት ሃይማኖት', /* ... etc ... */
  ],
  saintsHistorySectionKey: ['መእተዊ','ቅዱስ ያዕቆብ', 'ማዘር ትሬዛ' , /* ... etc ... */],
};