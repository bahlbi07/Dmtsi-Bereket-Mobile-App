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
    {'title': 'ፀሎት መቑፀርያ', 'key': rosaryCategoryKey},
    {'title': 'ፍኖተ መስቀል', 'key': fnotMsqelCategoryKey},
    'ፀሎት መቑፀርያ መንፈስ ቅዱስ',
    'ፀሎት ናብ መለኮታዊ ምሕረት',
    'ፀሎት ናብ ልቢ እየሱስ',
    'መቑፀርያ ቅዱስ ልቢ',
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
    'ፀሎት ሃይማኖት',
    'ናይ ሃይማኖት ስራሕ',
    'ናይ ተስፋ ስራሕ',
    'ናይ ፍቅሪ ስራሕ',
    'ናይ ንስሓ ስራሕ',
    'እእመን ኃጥያተይ',
    'ተኣምኖተ ኃጢኣት',
    'ናይ ነፍሲ ኣማሕፅኖት',
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
    'ናይ ሰብ መፈፀምታታት',
    'ቅዱስ መፅሓፍ',
    'ፀሎት',
    'ናይ ንጉሆ ፀሎት',
    'ናይ ምሸት ፀሎት',
    'ፀሎት መኣዲ',
    'ፀሎት ቅዱስ ፍራንቸኮስ',
    'ዝተፈላለዩ ክንፈልጦም ዝግብኡና',
    'ሓፀርቲ ፀሎታት',
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
