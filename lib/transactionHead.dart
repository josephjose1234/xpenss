import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'theme.dart';
import 'package:provider/provider.dart';
import 'searchScreen.dart';

class TransactionHead extends StatefulWidget {
  final Future<Database> DTHead;
  const TransactionHead({required this.DTHead});

  @override
  State<TransactionHead> createState() => _TransactionHeadState();
}

class _TransactionHeadState extends State<TransactionHead> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      height: 50,
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.black
            : Color.fromRGBO(242, 242, 247, 1),
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Transactions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.blue,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    DSearch: widget.DTHead,
                  ),
                ),
              );
            },
            child: Icon(
              Icons.search_sharp,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
