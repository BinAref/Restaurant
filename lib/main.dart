import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'providers/cart_provider.dart';
import 'screens/language_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحميل متغيرات البيئة
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('خطأ في تحميل ملف .env: $e');
  }

  runApp(const RestaurantOrderingApp());
}

class RestaurantOrderingApp extends StatelessWidget {
  const RestaurantOrderingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Restaurant Ordering',
        debugShowCheckedModeBanner: false,

        // دعم الترجمة
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // الإنجليزية
          Locale('ar', ''), // العربية
          Locale('tr', ''), // التركية
        ],

        // استخدام الثيم المحدث
        theme: AppTheme.getTheme(),

        home: const LanguageSelectionScreen(),
      ),
    );
  }
}
