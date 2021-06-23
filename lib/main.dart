import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import './transaction.dart';

const String box1 = 'pooji';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  Hive.registerAdapter(TransactionAdapter());
  await Hive.openBox<Transaction>(box1);
  runApp(MyHome());
}

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Box<Transaction> x;
  TextEditingController a = new TextEditingController();
  TextEditingController b = new TextEditingController();
  String selectedDate;
  double finalSum;

  void _dateSelect() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2022),
    ).then((value) {
      if (value == null) return;
      setState(() {
        selectedDate = DateFormat.yMMMd().format(value);
      });
    });
  }

  List<Map<String, Object>> func(Box<Transaction> d) {
    finalSum = 0.0;
    final dayStart = DateTime.now().subtract(
      (Duration(days: 6)),
    );
    List<Transaction> u = d.values.toList().cast<Transaction>();
    return List.generate(7, (index) {
      var day = dayStart.add(
        Duration(days: index),
      );
      var fday = DateFormat.yMMMd().format(day);
      double totalSum = 0.0;
      for (var i = 0; i < u.length; i++) {
        if (u[i].date == fday) {
          totalSum += u[i].amount;
        }
      }
      finalSum += totalSum;
      return {
        'days': DateFormat.E().format(day),
        'amount': totalSum,
      };
    });
  }

  void _reset(String u, double v, String w) {
    Transaction obj = Transaction(u, v, w);
    x.add(obj);
  }

  void _poup(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Card(
            elevation: 4,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Title',
                    ),
                    controller: a,
                    keyboardType: TextInputType.text,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Amount',
                    ),
                    controller: b,
                    keyboardType: TextInputType.number,
                  ),
                  Container(
                      height: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Text(selectedDate == null
                                ? 'No Date Choosen'
                                : selectedDate),
                          ),
                          RaisedButton(
                            child: Text(
                              'Choose Date',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: _dateSelect,
                            textColor: Color.fromRGBO(88, 214, 141, 1),
                          ),
                        ],
                      )),
                  RaisedButton(
                    child: Text('Add Transaction'),
                    onPressed: () {
                      if (selectedDate != null && b != null) {
                        _reset(a.text, double.parse(b.text), selectedDate);
                        a.clear();
                        b.clear();
                        selectedDate = null;
                        Navigator.of(context).pop();
                      }
                    },
                    color: Color.fromRGBO(88, 214, 141, 0.7),
                    textColor: Colors.white,
                  ),
                ],
              ),
            ));
      },
    );
  }

  @override
  void initState() {
    super.initState();
    x = Hive.box<Transaction>(box1);
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
        backgroundColor: Color.fromRGBO(88, 214, 141, 0.7),
      ),
      body: ValueListenableBuilder(
          valueListenable: x.listenable(),
          builder: (context, Box<Transaction> s, _) {
            List<Map<String, Object>> res = func(s);
            List<int> keys = s.keys.cast<int>().toList();
            return Container(
              child: Column(
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.all(15),
                      child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Card(
                            elevation: 7,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: res.map((v) {
                                return Column(
                                  children: <Widget>[
                                    Text('\$' + v['amount'].toString()),
                                    SizedBox(height: 5),
                                    Container(
                                      height: 80,
                                      width: 14,
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(220, 220, 200, 1),
                                        border: Border.all(
                                            color: Color.fromRGBO(
                                                220, 220, 200, 1),
                                            width: 1),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: FractionallySizedBox(
                                        heightFactor: finalSum == 0.0
                                            ? 0
                                            : double.parse(
                                                    v['amount'].toString()) /
                                                finalSum,
                                        widthFactor: 1,
                                        alignment: Alignment.bottomLeft,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(
                                                222, 49, 99, 0.5),
                                            border: Border.all(
                                                color: Color.fromRGBO(
                                                    220, 220, 200, 1),
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(v['days']),
                                  ],
                                );
                              }).toList(),
                            ),
                          ))),
                  (keys.length == 0)
                      ? Text(
                          'No Transactions added yet!!',
                          style: TextStyle(fontSize: 17),
                        )
                      : Container(
                          height: 500,
                          child: SingleChildScrollView(
                              child: ListView.separated(
                            itemBuilder: (_, index) {
                              final Transaction t = s.get(keys[index]);
                              return ListTile(
                                leading: Container(
                                  child: Text(
                                    '\$' + t.amount.toStringAsFixed(2),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color:
                                            Color.fromRGBO(222, 49, 99, 0.5)),
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color.fromRGBO(222, 49, 99, 0.5),
                                      width: 2,
                                    ),
                                  ),
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(7),
                                ),
                                title: Container(
                                  child: t.title == null
                                      ? Text('null')
                                      : Text(
                                          t.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                                subtitle: Container(
                                  child: Text(
                                    t.date,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Color.fromRGBO(222, 49, 99, 0.5),
                                  ),
                                  onPressed: () {
                                    s.delete(keys[index]);
                                  },
                                ),
                              );
                            },
                            separatorBuilder: (_, index) => Divider(),
                            itemCount: keys.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                          )))
                ],
              ),
            );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color.fromRGBO(88, 214, 141, 0.7),
          child: Icon(Icons.add),
          onPressed: () => _poup(context)),
    ));
  }

  /*@override
  void dispose() {
    Hive.close();
    super.dispose();
  }*/
}
