import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'dataModel.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'appbar.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({required this.DSearch});

  final Future<Database> DSearch;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int TotaL = 0;
  List<Transactions> TransList = [];

  TextEditingController _searchController = TextEditingController();

  Future<List<Transactions>> _searchTransaction(String searchTerm) async {
    final Database db = await widget.DSearch;
    final List<Transactions> searchResults = [];

    // Define your SQL query to search for transactions based on the "items" column
    final String query = '''
    SELECT * FROM transact
    WHERE item LIKE ?
  ''';

    // Execute the query and pass the search term as a parameter
    final List<Map<String, dynamic>> results =
        await db.rawQuery(query, ['%$searchTerm%']);

    // Process the results and populate the searchResults list
    for (final Map<String, dynamic> row in results) {
      final transaction = Transactions(
        id: row['id'],
        operator: row['operator'],
        item: row['item'],
        amount: row['amount'],
        DTime: row['DTime'],
      );
      searchResults.add(transaction);
    }

    setState(() {
      TransList = searchResults; // Update TransList with search results
    });
    // Calculate the sum of amounts
    int sum = 0;
    for (final transaction in searchResults) {
      sum += transaction.amount;
    }
    setState(() {
      TotaL = sum;
    });

    print('Sum of amounts: $sum');
    return searchResults;
  }

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
    return SafeArea(
      child: Scaffold(
         backgroundColor: themeProvider.isDarkMode
              ? Color.fromRGBO(34,34,34, 1)
              : Color.fromRGBO(199,199,204,1),
        body: Stack(
          children: [
//AppBar
            Column(
              children: [
                AppBarr(Bal: TotaL),
                //Transactions
                Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  height: 50,
                  width:double.maxFinite,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? Colors.black
                        : Color.fromRGBO(242, 242, 247, 1),
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Transactions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.blue,
                    ),
                  ),
                ),
                //List
                Expanded(
                  child: ListView.builder(
                    itemCount: TransList.length,
                    itemBuilder: (context, index) {
                      final transList = TransList[index];
                     return Container(
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: themeProvider.isDarkMode
                              ? Colors.black
                              : Colors.white,
                        ),
                        height: 75,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.all(15),
                              child: Text(
                                transList.item,
                                style: TextStyle(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        transList.operator,
                                        style: TextStyle(
                                            color: themeProvider.isDarkMode
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    ),
                                    Text(
                                      transList.amount.toString(),
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                    transList.DTime,
                                    style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ],
        ),
        bottomNavigationBar: Container(
          height: 70,
          padding:EdgeInsets.all(10),
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
           color: themeProvider.isDarkMode ? Colors.black : Color.fromRGBO(242,242,247,1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                //labelText: 'item',
                hintText: 'search...',
                hintStyle: TextStyle(color: Colors.blue),
                border: InputBorder.none,
              ),
              style: TextStyle(color: Colors.blue),
              onChanged: (text) {
                _searchTransaction(text);
              },
            ),
          ),
        ),
      ),
    );
  }
}
