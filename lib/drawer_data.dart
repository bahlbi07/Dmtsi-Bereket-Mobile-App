/// ንናይ ድሮወር (Drawer) ካታጎሪታት ዝምልከት ዳታ።
library;

// --- መዛሙር ዝብል ጠፊኡ ኣሎ ---
const String homeSectionKey = 'Home';
const String prayerSectionKey = 'Prayer';
const String mebaetaSectionKey = 'MebaetaTimhirtiKristos';
const String saintsHistorySectionKey = 'SaintsHistory';
const String rosaryCategoryKey = 'RosaryCategory';
const String fnotMsqelCategoryKey = 'FnotMsqel';

final Map<String, List<dynamic>> drawerSubCategoriesData = {
  homeSectionKey: [],
  prayerSectionKey: [
    {'title': 'መባእታ ናይ ትምህርቲ ክርስቶስ', 'key': mebaetaSectionKey},
    {'title': 'ጸሎት መቑጸርያ', 'key': rosaryCategoryKey},
    {'title': 'ፍኖተ መስቀል', 'key': fnotMsqelCategoryKey},
    'ጸሎት መቑጸርያ መንፈስ ቅዱስ',
    'ጸሎት ናብ መለኮታዊ ምሕረት',
    'ጸሎት ናብ ልቢ እየሱስ',
    'መቑጸርያ ቅዱስ ልቢ',
  ],
  rosaryCategoryKey: [
    'ናይ ደስታ ምስጢር',
    'ናይ ብርሃን ምስጢር',
    'ናይ ሕማም ምስጢር',
    'ናይ ክብሪ ምስጢር',
  ],
  mebaetaSectionKey: [
    'መእተዊ',
    'አቡነ ዘበሰማያት (ብግእዝ)',
    'ጸሎት ሃይማኖት',
    'ናይ ሃይማኖት ስራሕ',
    'ናይ ተስፋ ስራሕ',
    'ናይ ፍቅሪ ስራሕ',
    'ናይ ንስሓ ስራሕ',
    'እእመን ኃጥያተይ',
    'ተኣምኖተ ኃጢኣት',
    'ናይ ነፍሲ ኣማሕጽኖት',
    'ምእንቲ ምውታን',
    'እግዚአብሔር መን ፈጠረና?',
    'ምስጢረ ሥላሴ',
    'ምስጢረ ሥጋዌ',
    'ቤተክርስትያን',
    'ናይ እግዚኣብሔር ትእዛዛት',
    'ናይ ቤተክርስትያን ትእዛዛት',
    'ኃጥያት',
    'ዓበይቲ በዓላት',
    '7 ኣርእስቲ ኃጥያት ምስ ፈውሱ',
    'ምስጢራት',
    'ናይ ሰብ መፈጸምታታት',
    'ቅዱስ መጽሓፍ',
    'ጸሎት',
    'ናይ ንጉሆ ጸሎት',
    'ናይ ምሸት ጸሎት',
    'ጸሎት መኣዲ',
    'ጸሎት ቅዱስ ፍራንቸኮስ',
    'ዝተፈላለዩ ክንፈልጦም ዝግብኡና',
    'ሓጸርቲ ጸሎታት',
  ],
  saintsHistorySectionKey: [
    'መእተዊ',
    'ቅዱስ ያዕቆብ',
    'ቅድስት ትሬዛ "ዘካልካታ"',
    'ቅዱስ ኣንጦንዮስ ናይ ፓድዋ',
    'ቅዱስ ኣውጎስጢኖስ',
    'ቅዱስ ኣንጦንዮስ “ዓቢይ”'
  ],
};
