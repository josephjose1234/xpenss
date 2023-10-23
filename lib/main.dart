import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Open or create the database when the app starts.
  final database = openDatabase(
    join(await getDatabasesPath(), 'transact.db'),
    onCreate: (db, version) {
      // Create the 'transact' table if it doesn't exist.
      return db.execute(
        'CREATE TABLE transact(id INTEGER PRIMARY KEY AUTOINCREMENT , operator text, item TEXT,amount INTEGER, DTime TEXT )',
      );
    },
    version: 1,
  );
  runApp(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      builder: (context, _) => MyApp(
        DBase: database,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({required this.DBase});
  final Future<Database> DBase;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Set system overlay style based on the selected theme
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        // statusBarBrightness:
        //     themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false, //DebugBanner
      home: SafeArea(
        child: Scaffold(
          body: HomePage(
            DHome: DBase,
          ),
          backgroundColor: themeProvider.isDarkMode
              ? Color.fromRGBO(34,34,34, 1)
              : Color.fromRGBO(199,199,204,1)
        ),
      ),
    );
  }
}
