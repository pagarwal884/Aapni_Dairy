import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'app_title': 'AAPNI DAIRY',
      'welcome': 'Welcome',
      'login': 'Login',
      'logout': 'Logout',
      'settings': 'Settings',
      'about_us': 'About Us',
      'language': 'Language',
      'english': 'English',
      'hindi': 'हिंदी',
      'punjabi': 'ਪੰਜਾਬੀ',
      'customer_registration': 'Customer Registration',
      'milk_entry': 'Milk Entry',
      'edit_delete_entries': 'Edit/Delete Entries',
      'edit_rate': 'Edit Rate',
      'daily_summary': 'Daily Summary',
      'customer_summary_pdf': 'Customer Summary PDF',
      'export_total_pdf': 'Export Total PDF',
      'total_summary_pdf': 'Total Summary PDF',
      'export_customer_pdf': 'Export Customer PDF',
      'edit_dairy_details': 'Edit Dairy Details',
      'dairy_name': 'Dairy Name',
      'owner_name': 'Owner Name',
      'mobile_number': 'Mobile Number',
      'save_settings': 'Save Settings',
      'settings_saved': 'Settings saved successfully',
      'enter_dairy_name': 'Please enter dairy name',
      'enter_owner_name': 'Please enter owner name',
      'enter_mobile_number': 'Please enter mobile number',
      'enter_valid_mobile': 'Please enter valid 10-digit mobile number',
      'about_us_title': '🤝 About Us: Aapni Dairy',
      'about_us_content1':
          'Welcome to \'Aapni Dairy\'—an app born not from theory, but from the solid, real-world experience of 15 years in dairy management by HRB Dairy, Kheda Rampura.',
      'about_us_content2':
          'We created this app to eliminate the common headaches of manual collection and accounting, making the entire dairy process simple, transparent, and accurate.',
      'expertise_title': '🌟 Our Expertise and Trust',
      'expertise_content':
          '\'Aapni Dairy\' is built on practical needs and proven reliability:',
      'bullet1':
          '15 Years of Experience: The app is a result of HRB Dairy\'s deep, 15-year understanding of the dairy collection ecosystem.',
      'bullet2':
          'Tested Reliability: It has been successfully operating across 10-12 HRB Dairy centers for the past 6 months, ensuring accuracy and saving significant time.',
      'bullet3':
          'Pinpoint Accuracy: It makes all milk calculations (FAT, SNF, payments) precise, drastically reducing errors.',
      'name_explanation':
          'Why the Name \'Aapni Dairy\'?: We named it \'Aapni Dairy\' (Your Own Dairy) because we want every user to feel empowered to store and manage their dairy data securely and conveniently, just like it\'s their very own setup.',
      'goal':
          'Our goal is simple: To provide a digital solution you can trust, proven by our own extensive operational experience.',
      'team_title': 'HRB Dairy Kheda Rampura Team',
      'team_content':
          'HRB Dairy Team:\nPannaramji Yadav\nMahesh Kumar Yadav (10+ years experience)\nSuresh Kumar Yadav (Marketing Head)\n\nOnline Marketing Team:\nRamesh Kumar Yadav\nRahul Yadav\nNitin Yadav',
      'follow_us': 'Follow Our Journey:',

      'initializing': 'Initializing AAPNI DAIRY...',
      'data_warning':
          '<Your data will remain with you only. This is a serverless app that works completely offline. If your app gets uninstalled, complete data will be lost. The company will not be responsible for this.>',
      'pdf_details': 'These details will appear on all PDF exports',
      'instagram': 'Instagram',
      'facebook': 'Facebook',
      'whatsapp': 'WhatsApp',
      'how_to_use': 'How to Use',
    },
    'hi': {
      'app_title': 'आपनी डेयरी',
      'welcome': 'स्वागत है',
      'login': 'लॉगिन',
      'logout': 'लॉगआउट',
      'settings': 'सेटिंग्स',
      'about_us': 'हमारे बारे में',
      'language': 'भाषा',
      'english': 'English',
      'hindi': 'हिंदी',
      'punjabi': 'ਪੰਜਾਬੀ',
      'customer_registration': 'ग्राहक पंजीकरण',
      'milk_entry': 'दूध प्रवेश',
      'edit_delete_entries': 'प्रविष्टियाँ संपादित/हटाएं',
      'edit_rate': 'दर संपादित करें',
      'daily_summary': 'दैनिक सारांश',
      'customer_summary_pdf': 'ग्राहक सारांश PDF',
      'export_total_pdf': 'कुल PDF निर्यात करें',
      'total_summary_pdf': 'कुल सारांश PDF',
      'export_customer_pdf': 'ग्राहक PDF निर्यात करें',
      'edit_dairy_details': 'डेयरी विवरण संपादित करें',
      'dairy_name': 'डेयरी का नाम',
      'owner_name': 'मालिक का नाम',
      'mobile_number': 'मोबाइल नंबर',
      'save_settings': 'सेटिंग्स सहेजें',
      'settings_saved': 'सेटिंग्स सफलतापूर्वक सहेजी गईं',
      'enter_dairy_name': 'कृपया डेयरी का नाम दर्ज करें',
      'enter_owner_name': 'कृपया मालिक का नाम दर्ज करें',
      'enter_mobile_number': 'कृपया मोबाइल नंबर दर्ज करें',
      'enter_valid_mobile': 'कृपया मान्य 10-अंकीय मोबाइल नंबर दर्ज करें',
      'about_us_title': '🤝 हमारे बारे में: आपनी डेयरी',
      'about_us_content1':
          'आपनी डेयरी में आपका स्वागत है—यह ऐप सिद्धांत से नहीं बना है, बल्कि खेड़ा रमपुरा के एचआरबी डेयरी द्वारा 15 साल के ठोस, वास्तविक दुनिया के डेयरी प्रबंधन अनुभव से बना है।',
      'about_us_content2':
          'हमने यह ऐप मैन्युअल संग्रहण और लेखांकन की सामान्य समस्याओं को खत्म करने के लिए बनाया है, जिससे पूरी डेयरी प्रक्रिया सरल, पारदर्शी और सटीक हो जाती है।',
      'expertise_title': '🌟 हमारी विशेषज्ञता और विश्वास',
      'expertise_content':
          'आपनी डेयरी व्यावहारिक आवश्यकताओं और सिद्ध विश्वसनीयता पर बनाई गई है:',
      'bullet1':
          '15 साल का अनुभव: यह ऐप एचआरबी डेयरी के डेयरी संग्रहण पारिस्थितिकी तंत्र की 15 साल की गहरी समझ का परिणाम है।',
      'bullet2':
          'परीक्षणित विश्वसनीयता: यह पिछले 6 महीनों में 10-12 एचआरबी डेयरी केंद्रों में सफलतापूर्वक संचालित हो रहा है, सटीकता सुनिश्चित करते हुए और काफी समय बचाते हुए।',
      'bullet3':
          'सटीक सटीकता: यह सभी दूध गणनाओं (FAT, SNF, भुगतान) को सटीक बनाता है, जिससे त्रुटियों में काफी कमी आती है।',
      'name_explanation':
          'नाम \'आपनी डेयरी\' क्यों?: हमने इसे \'आपनी डेयरी\' (Your Own Dairy) नाम दिया क्योंकि हम चाहते हैं कि हर उपयोगकर्ता अपनी डेयरी डेटा को सुरक्षित और सुविधाजनक रूप से संग्रहीत और प्रबंधित करने में सशक्त महसूस करे, जैसे कि यह उनका अपना सेटअप हो।',
      'goal':
          'हमारा लक्ष्य सरल है: अपनी व्यापक परिचालन अनुभव द्वारा सिद्ध एक विश्वसनीय डिजिटल समाधान प्रदान करना।',
      'team_title': 'एचआरबी डेयरी खेड़ा रमपुरा टीम',
      'team_content':
          'एचआरबी डेयरी टीम:\nपन्नारामजी यादव\nमहेश कुमार यादव (10+ साल का अनुभव)\nसुरेश कुमार यादव (मार्केटिंग हेड)\n\nऑनलाइन मार्केटिंग टीम:\nरमेश कुमार यादव\nराहुल यादव\nनितिन यादव',
      'follow_us': 'हमारी यात्रा का अनुसरण करें:',
      'initializing': 'आपनी डेयरी प्रारंभ हो रहा है...',
      'data_warning':
          '<आपका डेटा केवल आपके साथ रहेगा। यह एक सर्वर रहित ऐप है जो पूरी तरह से ऑफलाइन काम करता है। यदि ऐप अनइंस्टॉल हो जाता है, तो पूरा डेटा खो जाएगा। कंपनी इसके लिए जिम्मेदार नहीं होगी।>',
      'pdf_details': 'ये विवरण सभी PDF निर्यात में दिखाई देंगे',
      'instagram': 'इंस्टाग्राम',
      'facebook': 'फेसबुक',
      'whatsapp': 'व्हाट्सएप',
      'how_to_use': 'कैसे इस्तेमाल करें',
    },
    'pa': {
      'app_title': 'ਆਪਣੀ ਡੇਅਰੀ',
      'welcome': 'ਸਵਾਗਤ ਹੈ',
      'login': 'ਲੌਗਇਨ',
      'logout': 'ਲੌਗਆਉਟ',
      'settings': 'ਸੈਟਿੰਗਜ਼',
      'about_us': 'ਸਾਡੇ ਬਾਰੇ',
      'language': 'ਭਾਸ਼ਾ',
      'english': 'English',
      'hindi': 'हिंदी',
      'punjabi': 'ਪੰਜਾਬੀ',
      'customer_registration': 'ਗਾਹਕ ਰਜਿਸਟ੍ਰੇਸ਼ਨ',
      'milk_entry': 'ਦੁੱਧ ਦਾਖਲਾ',
      'edit_delete_entries': 'ਦਾਖਲੇ ਸੰਪਾਦਿਤ/ਮਿਟਾਓ',
      'edit_rate': 'ਦਰ ਸੰਪਾਦਿਤ ਕਰੋ',
      'daily_summary': 'ਰੋਜ਼ਾਨਾ ਸੰਖੇਪ',
      'customer_summary_pdf': 'ਗਾਹਕ ਸੰਖੇਪ PDF',
      'export_total_pdf': 'ਕੁਲ PDF ਨਿਰਯਾਤ ਕਰੋ',
      'total_summary_pdf': 'ਕੁਲ ਸੰਖੇਪ PDF',
      'export_customer_pdf': 'ਗਾਹਕ PDF ਨਿਰਯਾਤ ਕਰੋ',
      'edit_dairy_details': 'ਡੇਅਰੀ ਵੇਰਵੇ ਸੰਪਾਦਿਤ ਕਰੋ',
      'dairy_name': 'ਡੇਅਰੀ ਦਾ ਨਾਮ',
      'owner_name': 'ਮਾਲਕ ਦਾ ਨਾਮ',
      'mobile_number': 'ਮੋਬਾਇਲ ਨੰਬਰ',
      'save_settings': 'ਸੈਟਿੰਗਜ਼ ਸੰਭਾਲੋ',
      'settings_saved': 'ਸੈਟਿੰਗਜ਼ ਸਫਲਤਾਪੂਰਵਕ ਸੰਭਾਲੀਆਂ ਗਈਆਂ',
      'enter_dairy_name': 'ਕਿਰਪਾ ਕਰਕੇ ਡੇਅਰੀ ਦਾ ਨਾਮ ਦਰਜ ਕਰੋ',
      'enter_owner_name': 'ਕਿਰਪਾ ਕਰਕੇ ਮਾਲਕ ਦਾ ਨਾਮ ਦਰਜ ਕਰੋ',
      'enter_mobile_number': 'ਕਿਰਪਾ ਕਰਕੇ ਮੋਬਾਇਲ ਨੰਬਰ ਦਰਜ ਕਰੋ',
      'enter_valid_mobile': 'ਕਿਰਪਾ ਕਰਕੇ ਵੈਧ 10-ਅੰਕੀ ਮੋਬਾਇਲ ਨੰਬਰ ਦਰਜ ਕਰੋ',
      'about_us_title': '🤝 ਸਾਡੇ ਬਾਰੇ: ਆਪਣੀ ਡੇਅਰੀ',
      'about_us_content1':
          'ਆਪਣੀ ਡੇਅਰੀ ਵਿੱਚ ਤੁਹਾਡਾ ਸਵਾਗਤ ਹੈ—ਇਹ ਐਪ ਸਿਧਾਂਤ ਤੋਂ ਨਹੀਂ ਬਣਿਆ ਹੈ, ਬਲਕਿ ਖੇੜਾ ਰਮਪੁਰਾ ਦੇ ਐਚਆਰਬੀ ਡੇਅਰੀ ਦੁਆਰਾ 15 ਸਾਲ ਦੇ ਮਜ਼ਬੂਤ, ਅਸਲੀ ਦੁਨਿਆ ਦੇ ਡੇਅਰੀ ਪ੍ਰਬੰਧਨ ਦੇ ਅਨੁਭਵ ਤੋਂ ਬਣਿਆ ਹੈ।',
      'about_us_content2':
          'ਅਸੀਂ ਇਹ ਐਪ ਮੈਨੁਅਲ ਸੰਗ੍ਰਹਿ ਅਤੇ ਲੇਖਾਕਾਰੀ ਦੀਆਂ ਆਮ ਸਮੱਸਿਆਵਾਂ ਨੂੰ ਖਤਮ ਕਰਨ ਲਈ ਬਣਾਇਆ ਹੈ, ਜਿਸ ਨਾਲ ਪੂਰੀ ਡੇਅਰੀ ਪ੍ਰਕਿਰਿਆ ਸਧਾਰਨ, ਪਾਰਦਰਸ਼ੀ ਅਤੇ ਸਹੀ ਹੋ ਜਾਂਦੀ ਹੈ।',
      'expertise_title': '🌟 ਸਾਡੀ ਮੁਹਾਰਤ ਅਤੇ ਭਰੋਸਾ',
      'expertise_content':
          'ਆਪਣੀ ਡੇਅਰੀ ਵਿਹਾਰਕ ਲੋੜਾਂ ਅਤੇ ਸਾਬਿਤ ਹੋਈ ਭਰੋਸੇਯੋਗਤਾ \'ਤੇ ਬਣਾਈ ਗਈ ਹੈ:',
      'bullet1':
          '15 ਸਾਲ ਦਾ ਅਨੁਭਵ: ਇਹ ਐਪ ਐਚਆਰਬੀ ਡੇਅਰੀ ਦੇ ਡੇਅਰੀ ਸੰਗ੍ਰਹਿ ਪ੍ਰਣਾਲੀ ਦੀ 15 ਸਾਲ ਦੀ ਡੂੰਘੀ ਸਮਝ ਦਾ ਨਤੀਜਾ ਹੈ।',
      'bullet2':
          'ਟੈਸਟ ਕੀਤੀ ਭਰੋਸੇਯੋਗਤਾ: ਇਹ ਪਿਛਲੇ 6 ਮਹੀਨਿਆਂ ਵਿੱਚ 10-12 ਐਚਆਰਬੀ ਡੇਅਰੀ ਸੈਂਟਰਾਂ ਵਿੱਚ ਸਫਲਤਾਪੂਰਵਕ ਚੱਲ ਰਿਹਾ ਹੈ, ਸਹੀ ਹੋਣ ਨੂੰ ਯਕੀਨੀ ਬਣਾਉਂਦਾ ਹੈ ਅਤੇ ਮਹੱਤਵਪੂਰਨ ਸਮਾਂ ਬਚਾਉਂਦਾ ਹੈ।',
      'bullet3':
          'ਸਟਿੱਕ ਸਹੀ ਹੋਣ: ਇਹ ਸਾਰੀਆਂ ਦੁੱਧ ਗਣਨਾਵਾਂ (FAT, SNF, ਭੁਗਤਾਨ) ਨੂੰ ਸਟਿੱਕ ਬਣਾਉਂਦਾ ਹੈ, ਗਲਤੀਆਂ ਨੂੰ ਮਹੱਤਵਪੂਰਨ ਰੂਪ ਵਿੱਚ ਘਟਾਉਂਦਾ ਹੈ।',
      'name_explanation':
          'ਨਾਮ \'ਆਪਣੀ ਡੇਅਰੀ\' ਕਿਉਂ?: ਅਸੀਂ ਇਸ ਨੂੰ \'ਆਪਣੀ ਡੇਅਰੀ\' (Your Own Dairy) ਨਾਮ ਦਿੱਤਾ ਕਿਉਂਕਿ ਅਸੀਂ ਚਾਹੁੰਦੇ ਹਾਂ ਕਿ ਹਰ ਉਪਭੋਗਤਾ ਆਪਣੇ ਡੇਅਰੀ ਡੇਟਾ ਨੂੰ ਸੁਰੱਖਿਅਤ ਅਤੇ ਸੌਖ ਨਾਲ ਸਟੋਰ ਅਤੇ ਮੈਨੇਜ ਕਰਨ ਵਿੱਚ ਸ਼ਕਤੀਸ਼ਾਲੀ ਮਹਿਸੂਸ ਕਰੇ, ਜਿਵੇਂ ਕਿ ਇਹ ਉਸਦਾ ਆਪਣਾ ਸੈੱਟਅੱਪ ਹੋਵੇ।',
      'goal':
          'ਸਾਡਾ ਟੀਚਾ ਸਧਾਰਨ ਹੈ: ਆਪਣੇ ਵਿਆਪਕ ਓਪਰੇਸ਼ਨਲ ਅਨੁਭਵ ਦੁਆਰਾ ਸਾਬਿਤ ਇੱਕ ਭਰੋਸੇਯੋਗ ਡਿਜ਼ੀਟਲ ਹੱਲ ਪ੍ਰਦਾਨ ਕਰਨਾ।',
      'team_title': 'ਐਚਆਰਬੀ ਡੇਅਰੀ ਖੇੜਾ ਰਮਪੁਰਾ ਟੀਮ',
      'team_content':
          'ਐਚਆਰਬੀ ਡੇਅਰੀ ਟੀਮ:\nਪੰਨਾਰਾਮਜੀ ਯਾਦਵ\nਮਹੇਸ਼ ਕੁਮਾਰ ਯਾਦਵ (10+ ਸਾਲ ਦਾ ਅਨੁਭਵ)\nਸੁਰੇਸ਼ ਕੁਮਾਰ ਯਾਦਵ (ਮਾਰਕੇਟਿੰਗ ਹੈੱਡ)\n\nਆਨਲਾਈਨ ਮਾਰਕੇਟਿੰਗ ਟੀਮ:\nਰਮੇਸ਼ ਕੁਮਾਰ ਯਾਦਵ\nਰਾਹੁਲ ਯਾਦਵ\nਨਿਤਿਨ ਯਾਦਵ',
      'follow_us': 'ਸਾਡੀ ਯਾਤਰਾ ਦਾ ਪਾਲਣ ਕਰੋ:',
      'initializing': 'ਆਪਣੀ ਡੇਅਰੀ ਸ਼ੁਰੂ ਹੋ ਰਿਹਾ ਹੈ...',
      'data_warning':
          '<ਤੁਹਾਡਾ ਡੇਟਾ ਸਿਰਫ਼ ਤੁਹਾਡੇ ਨਾਲ ਰਹੇਗਾ। ਇਹ ਇੱਕ ਸਰਵਰ ਰਹਿਤ ਐਪ ਹੈ ਜੋ ਪੂਰੀ ਤਰ੍ਹਾਂ ਆਫਲਾਈਨ ਕੰਮ ਕਰਦੀ ਹੈ। ਜੇ ਐਪ ਅਨਇੰਸਟਾਲ ਹੋ ਜਾਂਦੀ ਹੈ, ਤਾਂ ਪੂਰਾ ਡੇਟਾ ਗੁੰਮ ਹੋ ਜਾਵੇਗਾ। ਕੰਪਨੀ ਇਸ ਲਈ ਜ਼ਿੰਮੇਵਾਰ ਨਹੀਂ ਹੋਵੇਗੀ।>',
      'pdf_details': 'ਇਹ ਵੇਰਵੇ ਸਾਰੇ PDF ਨਿਰਯਾਤ ਵਿੱਚ ਦਿਖਾਈ ਦੇਣਗੇ',
      'instagram': 'ਇੰਸਟਾਗ੍ਰਾਮ',
      'facebook': 'ਫੇਸਬੁੱਕ',
      'whatsapp': 'ਵਟਸਐਪ',
      'how_to_use': 'ਕਿਵੇਂ ਵਰਤੋਂ',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['app_title']!;
  String get welcome => _localizedValues[locale.languageCode]!['welcome']!;
  String get login => _localizedValues[locale.languageCode]!['login']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get aboutUs => _localizedValues[locale.languageCode]!['about_us']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get hindi => _localizedValues[locale.languageCode]!['hindi']!;
  String get punjabi => _localizedValues[locale.languageCode]!['punjabi']!;
  String get customerRegistration =>
      _localizedValues[locale.languageCode]!['customer_registration']!;
  String get milkEntry => _localizedValues[locale.languageCode]!['milk_entry']!;
  String get editDeleteEntries =>
      _localizedValues[locale.languageCode]!['edit_delete_entries']!;
  String get editRate => _localizedValues[locale.languageCode]!['edit_rate']!;
  String get dailySummary =>
      _localizedValues[locale.languageCode]!['daily_summary']!;
  String get customerSummaryPdf =>
      _localizedValues[locale.languageCode]!['customer_summary_pdf']!;
  String get exportTotalPdf =>
      _localizedValues[locale.languageCode]!['export_total_pdf']!;
  String get totalSummaryPdf =>
      _localizedValues[locale.languageCode]!['total_summary_pdf']!;
  String get exportCustomerPdf =>
      _localizedValues[locale.languageCode]!['export_customer_pdf']!;
  String get editDairyDetails =>
      _localizedValues[locale.languageCode]!['edit_dairy_details']!;
  String get dairyName => _localizedValues[locale.languageCode]!['dairy_name']!;
  String get ownerName => _localizedValues[locale.languageCode]!['owner_name']!;
  String get mobileNumber =>
      _localizedValues[locale.languageCode]!['mobile_number']!;
  String get saveSettings =>
      _localizedValues[locale.languageCode]!['save_settings']!;
  String get settingsSaved =>
      _localizedValues[locale.languageCode]!['settings_saved']!;
  String get enterDairyName =>
      _localizedValues[locale.languageCode]!['enter_dairy_name']!;
  String get enterOwnerName =>
      _localizedValues[locale.languageCode]!['enter_owner_name']!;
  String get enterMobileNumber =>
      _localizedValues[locale.languageCode]!['enter_mobile_number']!;
  String get enterValidMobile =>
      _localizedValues[locale.languageCode]!['enter_valid_mobile']!;
  String get aboutUsTitle =>
      _localizedValues[locale.languageCode]!['about_us_title']!;
  String get aboutUsContent1 =>
      _localizedValues[locale.languageCode]!['about_us_content1']!;
  String get aboutUsContent2 =>
      _localizedValues[locale.languageCode]!['about_us_content2']!;
  String get expertiseTitle =>
      _localizedValues[locale.languageCode]!['expertise_title']!;
  String get expertiseContent =>
      _localizedValues[locale.languageCode]!['expertise_content']!;
  String get bullet1 => _localizedValues[locale.languageCode]!['bullet1']!;
  String get bullet2 => _localizedValues[locale.languageCode]!['bullet2']!;
  String get bullet3 => _localizedValues[locale.languageCode]!['bullet3']!;
  String get nameExplanation =>
      _localizedValues[locale.languageCode]!['name_explanation']!;
  String get goal => _localizedValues[locale.languageCode]!['goal']!;
  String get teamTitle => _localizedValues[locale.languageCode]!['team_title']!;
  String get teamContent =>
      _localizedValues[locale.languageCode]!['team_content']!;
  String get followUs => _localizedValues[locale.languageCode]!['follow_us']!;

  String get initializing =>
      _localizedValues[locale.languageCode]!['initializing']!;
  String get dataWarning =>
      _localizedValues[locale.languageCode]!['data_warning']!;
  String get pdfDetails =>
      _localizedValues[locale.languageCode]!['pdf_details']!;
  String get instagram => _localizedValues[locale.languageCode]!['instagram']!;
  String get facebook => _localizedValues[locale.languageCode]!['facebook']!;
  String get whatsapp => _localizedValues[locale.languageCode]!['whatsapp']!;
  String get howToUse => _localizedValues[locale.languageCode]!['how_to_use']!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'hi', 'pa'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
