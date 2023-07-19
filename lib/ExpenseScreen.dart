import 'package:flutter/material.dart';

class ExpenseScreen extends StatefulWidget {
  final Function(double) updateTotalAmount;

  ExpenseScreen({required this.updateTotalAmount});

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<Map<String, dynamic>> transactions = [
    {
      'title': 'Groceries',
      'amount': 50.0,
      'isExpense': true,
    },
    {
      'title': 'Salary',
      'amount': 1000.0,
      'isExpense': false,
    },
  ];

  double getTotalAmount() {
    double total = 0;
    for (var transaction in transactions) {
      if (transaction['isExpense']) {
        total -= transaction['amount'];
      } else {
        total += transaction['amount'];
      }
    }
    return total;
  }

  void addTransaction(String title, double amount, bool isExpense) {
    setState(() {
      transactions.add({
        'title': title,
        'amount': amount,
        'isExpense': isExpense,
      });
    });
    double newTotalAmount = getTotalAmount();
    widget.updateTotalAmount(newTotalAmount);
  }

  void deleteTransaction(int index) {
    setState(() {
      transactions.removeAt(index);
    });
    double newTotalAmount = getTotalAmount();
    widget.updateTotalAmount(newTotalAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expense Tracker',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Total:',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  '\$${getTotalAmount().toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: transaction['isExpense']
                        ? Icon(Icons.remove, color: Colors.red)
                        : Icon(Icons.add, color: Colors.green),
                    title: Text(transaction['title']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${transaction['amount'].toStringAsFixed(2)}',
                          style: TextStyle(
                            color: transaction['isExpense'] ? Colors.red : Colors.green,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            deleteTransaction(index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddTransactionModal(
              onTransactionAdded: addTransaction,
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddTransactionModal extends StatefulWidget {
  final Function(String, double, bool) onTransactionAdded;

  AddTransactionModal({required this.onTransactionAdded});

  @override
  _AddTransactionModalState createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  late String title;
  late double amount;
  late bool isExpense;

  @override
  void initState() {
    super.initState();
    title = '';
    amount = 0;
    isExpense = true;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                labelText: 'Title',
              ),
              onChanged: (value) {
                setState(() {
                  title = value;
                });
              },
            ),
            SizedBox(height: 16),
            Row(
              children: <Widget>[
                Text('Type: '),
                SizedBox(width: 8),
                ToggleButtons(
                  children: <Widget>[
                    Text('Expense'),
                    Text('Income'),
                  ],
                  isSelected: [isExpense, !isExpense],
                  onPressed: (index) {
                    setState(() {
                      isExpense = index == 0;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
              ),
              onChanged: (value) {
                setState(() {
                  amount = double.parse(value);
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: title.isEmpty || amount <= 0
                  ? null
                  : () {
                widget.onTransactionAdded(title, amount, isExpense);
                Navigator.of(context).pop();
              },
              child: Text('Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
