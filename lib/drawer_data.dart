// lib/data/drawer_data.dart

/// ንናይ ድሮወር (Drawer) ካታጎሪታት ዝምልከት ዳታ።
/// እዚ ን home_page.dart ንፁር ንኽኸውን ይሕግዝ።
library;


// --- ንናይ ካታጎሪታት መለለዪ ቁልፊታት (Keys for Categories) ---
const String homeSectionKey = 'Home';
const String hymnsSectionKey = 'Hymns';
const String prayerSectionKey = 'Prayer';
const String mebaetaSectionKey = 'MebaetaTimhirtiKristos';
const String saintsHistorySectionKey = 'SaintsHistory';
const String rosaryCategoryKey = 'RosaryCategory';
const String fnotMsqelCategoryKey = 'FnotMsqel';
const String internalAllHymnsKey = 'All Hymns';


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
    'ናይ ደስታ ምስጢር',
    'ናይ ብርሃን ምስጢር',
    'ናይ ሕማም ምስጢር',
    'ናይ ክብሪ ምስጢር',
  ],
  mebaetaSectionKey: [
    'መእተዊ', 'አቡነ ዘበሰማያት (ብግእዝ)', 'ፀሎት ሃይማኖት', 'ናይ ሃይማኖት ስራሕ', 'ናይ ተስፋ ስራሕ',
    'ናይ ፍቅሪ ስራሕ', 'ናይ ንስሓ ስራሕ', 'እእመን ኃጥያተይ', 'ተኣምኖተ ኃጢኣት', 'ናይ ነፍሲ ኣማሕፅኖት',
    'ምእንቲ ምውታን', 'እግዚአብሔር መን ፈጠረና?','ምስጢረ ሥላሴ','ምስጢረ ሥጋዌ', 'ቤተክርስትያን', 'ናይ እግዚኣብሔር ትእዛዛት',
    'ናይ ቤተክርስትያን ትእዛዛት','ኃጥያት', 'ዓበይቲ በዓላት',
    '7 ኣርእስቲ ኃጥያት ምስ ፈውሱ', 'ምስጢራት', 'ናይ ሰብ መፈፀምታታት',
    'ቅዱስ መፅሓፍ', 'ፀሎት', 'ናይ ንጉሆ ፀሎት', 'ናይ ምሸት ፀሎት',
    'ፀሎት መኣዲ', 'ፀሎት ቅዱስ ፍራንቸኮስ', 'ዝተፈላለዩ ክንፈልጦም ዝግብኡና', 'ሓፀርቲ ፀሎታት',
  ],
  saintsHistorySectionKey: ['መእተዊ','ቅዱስ ያዕቆብ', 'ቅድስት ትሬዛ "ዘካልካታ"' , 'ቅዱስ ኣንጦንዮስ ናይ ፓድዋ', 'ቅዱስ ኣውጎስጢኖስ', 'ቅዱስ ኣንጦንዮስ “ዓቢይ”'],
};