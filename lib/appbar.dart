import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';

class AppBarr extends StatefulWidget {
  final int Bal;
  const AppBarr({required this.Bal});

  @override
  State<AppBarr> createState() => _AppBarrState();
}

class _AppBarrState extends State<AppBarr> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      width: double.maxFinite,
      height: 100,
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? Colors.black : Color.fromRGBO(242,242,247,1),
          borderRadius: BorderRadius.circular(50)),
      child: Center(
        child: Text(
          
          '${widget.Bal.toString()}',
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ),
    );
  }
}
