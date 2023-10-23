import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'appbar.dart';
import 'transactionHead.dart';
import 'dataModel.dart';
import 'theme.dart';

class HomePage extends StatefulWidget {
  HomePage({required this.DHome});
  final Future<Database> DHome;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Icon OPr = Icon(Icons.add, size: 30, color: Colors.blue);
  List<Transactions> TransList = [];
  String opR = '+';
  int total = 0;

  TextEditingController _amountController = TextEditingController();
  TextEditingController _itemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

// Balance
// EXtractingBalance
  Future<int> getLastBal(Database db) async {
    final List<Map<String, dynamic>>? results =
        await db.query('transact', columns: ['operator', 'amount']);
    if (results == null) {
      return 0; // or some default value
    }

    // Create two lists to store 'operator' and 'amount'
    List<String> os = [];
    List<int> as = [];
    for (int i = 0; i < results.length; i++) {
      final String operator = results[i]['operator'] as String;
      final int amount = results[i]['amount'] as int;
      // Append the values to their respective lists
      os.add(operator);
      as.add(amount);
    }
    total = 0;
    for (int i = 0; i < os.length; i++) {
      if (os[i] == '+') {
        total = total + as[i];
      } else if (os[i] == '-') {
        total = total - as[i];
      }
    }
    ;
    print(os);
    print(as);
    return total;
  }

  // READ operation
  Future<void> _loadTransactions() async {
    final db = await widget.DHome; //getting Database
    final List<Map<String, dynamic>> maps = await db.query('transact');
    print(maps.toString());

    setState(() {
      TransList = List.generate(maps.length, (index) {
        return Transactions(
          id: maps[index]['id'],
          operator: maps[index]['operator'],
          item: maps[index]['item'],
          amount: maps[index]['amount'],
          DTime: maps[index]['DTime'],
        );
      });
    });

    total = await getLastBal(db);
    setState(() {});
  }

// CREATE operation
  Future<void> _insertTransaction(Transactions transaction) async {
    final db = await widget.DHome;
    await db.insert(
      'transact',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _loadTransactions();
  }

// DELETE operation
  Future<void> _deleteTransaction(int index) async {
    final Database db = await widget.DHome;
    final transToDelete = TransList[index];
    await db.delete(
      'transact',
      where: 'id = ?',
      whereArgs: [transToDelete.id],
    );
    await _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Set system overlay style based on the selected theme
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    return Stack(children: [
      Container(
        margin: EdgeInsets.only(bottom: 80),
        child: Column(
          children: [
            //AppBar
            AppBarr(Bal: total),
            //Search

            //TransactionsHead
            TransactionHead(DTHead: widget.DHome),
            //Transactions
            Expanded(
              child: ListView.builder(
                itemCount: TransList.length,
                itemBuilder: (context, index) {
                  final transList = TransList[index];
                  return GestureDetector(
                    onLongPress: () {
                      //DeleteDialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor:
                                const Color.fromARGB(255, 63, 62, 62),
                            title: Icon(
                              Icons.delete,
                              size: 50,
                              color: Colors.red,
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Icon(Icons.close_sharp, size: 30),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Delete the transaction here
                                  _deleteTransaction(index);
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Icon(Icons.check_rounded, size: 30),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
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
                                color: transList.operator == '+'
                                    ? Colors.green
                                    : Colors.red,
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
                                        color: transList.operator == '+'
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    transList.amount.toString(),
                                    style: TextStyle(
                                      color: transList.operator == '+'
                                          ? Colors.green
                                          : Colors.red,
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
                                      color: transList.operator == '+'
                                            ? Colors.green
                                            : Colors.red,),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
            //AddItems
          ],
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          height: 70,
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? Colors.black
                : Color.fromRGBO(242, 242, 247, 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 100,
                width: 40,
                margin: const EdgeInsets.all(5),
                child: Center(
                  child: GestureDetector(
                    child: OPr,
                    onTap: () {
                      setState(() {
                        opR == '+'
                            ? {
                                opR = '-',
                                OPr = Icon(Icons.remove, color: Colors.blue)
                              }
                            : {
                                opR = '+',
                                OPr = Icon(Icons.add, color: Colors.blue)
                              };
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: TextField(
                    controller: _itemController,
                    decoration: InputDecoration(
                      //labelText: 'item',
                      hintText: 'itmes',
                      hintStyle: TextStyle(color: Colors.blue),
                    ),
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '₹₹₹₹',
                      hintStyle: TextStyle(color: Colors.blue),
                      labelStyle: TextStyle(color: Colors.blue),
                    ),
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () async {
                    if (_amountController.text.isNotEmpty ||
                        _itemController.text.isNotEmpty) {
                      // Get the current date and time as a DateTime object
                      DateTime currentDateTime = DateTime.now();
                      // Create a DateFormat with the desired format
                      final dateFormat = DateFormat('MMM,d,y');
                      // Format the DateTime object as a string
                      String formattedDateTime =
                          dateFormat.format(currentDateTime);
                      int amtInt = int.parse(
                          _amountController.text); //converting text to INT
                      final newTransaction = Transactions(
                        operator: opR,
                        item: _itemController.text,
                        amount: amtInt,
                        DTime: formattedDateTime,
                        //find previous balance here???
                      );
                      setState(() {
                        _insertTransaction(newTransaction);
                        _loadTransactions();
                        _amountController.clear();
                        _itemController.clear();
                      });
                    }
                  },
                  child: const Icon(Icons.send_sharp, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}
