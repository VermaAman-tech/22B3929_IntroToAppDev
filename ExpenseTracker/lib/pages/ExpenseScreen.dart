import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseScreen extends StatefulWidget {
  final Function(double) updateTotalAmount;

  ExpenseScreen({required this.updateTotalAmount});

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<Map<String, dynamic>> transactions = [];
  bool isAscending = true; // Track the sorting order
  bool showExpenses = true; // Track the visibility of expense transactions
  bool showIncomes = true; // Track the visibility of income transactions

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _transactionsCollection =
  FirebaseFirestore.instance.collection('transactions');

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

  @override
  void initState() {
    super.initState();
    // Retrieve data from Cloud Firestore when the app starts
    _transactionsCollection.get().then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          transactions = querySnapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            data['docId'] = doc.id;
            return data;
          }).toList();
        });
        double newTotalAmount = getTotalAmount();
        widget.updateTotalAmount(newTotalAmount);
      }
    });
  }

  void addTransaction(String title, double amount, bool isExpense, String notes) {
    final newTransaction = {
      'title': title,
      'amount': amount,
      'isExpense': isExpense,
      'notes': notes, // Add this line to include notes
    };

    // Update the local list of transactions first
    setState(() {
      transactions.add(newTransaction);
    });

    // Save the new transaction to Cloud Firestore
    _transactionsCollection.add(newTransaction).then((DocumentReference docRef) {
      newTransaction['docId'] = docRef.id;
      double newTotalAmount = getTotalAmount();
      widget.updateTotalAmount(newTotalAmount);
    });
  }

  void deleteTransaction(int index) {
    // Get the Firestore document ID of the transaction to be deleted
    final String docId = transactions[index]['docId'];

    // Remove the transaction from Cloud Firestore using its ID
    _transactionsCollection.doc(docId).delete().then((_) {
      setState(() {
        transactions.removeAt(index);
      });
      double newTotalAmount = getTotalAmount();
      widget.updateTotalAmount(newTotalAmount);
    });
  }

  // Function to sort the transactions based on the selected order
  void sortTransactions() {
    setState(() {
      if (isAscending) {
        transactions.sort((a, b) => a['amount'].compareTo(b['amount']));
      } else {
        transactions.sort((a, b) => b['amount'].compareTo(a['amount']));
      }
    });
  }

  // Function to toggle between ascending and descending order
  void toggleSortOrder() {
    setState(() {
      isAscending = !isAscending;
      sortTransactions();
    });
  }

  // Function to filter transactions based on their type (expense or income)
  List<Map<String, dynamic>> filterTransactions() {
    if (showExpenses && showIncomes) {
      return transactions; // Show all transactions
    } else if (showExpenses) {
      return transactions.where((transaction) => transaction['isExpense']).toList();
    } else if (showIncomes) {
      return transactions.where((transaction) => !transaction['isExpense']).toList();
    } else {
      return []; // No transactions to show
    }
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
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(
              isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: Colors.white,
            ),
            onPressed: toggleSortOrder,
          ),
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                if (value == 'expenses') {
                  showExpenses = !showExpenses;
                } else if (value == 'incomes') {
                  showIncomes = !showIncomes;
                }
              });
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                value: 'expenses',
                checked: showExpenses,
                child: Text('Show Expenses'),
              ),
              CheckedPopupMenuItem(
                value: 'incomes',
                checked: showIncomes,
                child: Text('Show Incomes'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
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
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filterTransactions().length, // Use the filtered transactions
              itemBuilder: (context, index) {
                final transaction = filterTransactions()[index]; // Use the filtered transactions
                return Dismissible(
                  key: Key(transaction['docId']),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    deleteTransaction(index);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: transaction['isExpense']
                          ? Icon(Icons.remove, color: Colors.red, size: 36)
                          : Icon(Icons.add, color: Colors.green, size: 36),
                      title: Text(
                        transaction['title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: transaction['notes'] != null
                          ? Text(
                        transaction['notes'],
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      )
                          : null, // Show the notes as a subtitle
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '\$${transaction['amount'].toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              color: transaction['isExpense'] ? Colors.red : Colors.green,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            transaction['isExpense'] ? 'Expense' : 'Income',
                            style: TextStyle(
                              fontSize: 14,
                              color: transaction['isExpense'] ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
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
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}

class AddTransactionModal extends StatefulWidget {
  final Function(String, double, bool, String) onTransactionAdded; // Update this line

  AddTransactionModal({required this.onTransactionAdded});

  @override
  _AddTransactionModalState createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  late String title;
  late double amount;
  late bool isExpense;
  late String notes; // Add this line

  @override
  void initState() {
    super.initState();
    title = '';
    amount = 0;
    isExpense = true;
    notes = ''; // Add this line
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
            Text(
              'Add Transaction',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(fontSize: 18),
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
                Text('Type:', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                ToggleButtons(
                  children: <Widget>[
                    Text('Expense', style: TextStyle(fontSize: 16)),
                    Text('Income', style: TextStyle(fontSize: 16)),
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
                labelStyle: TextStyle(fontSize: 18),
              ),
              onChanged: (value) {
                setState(() {
                  amount = double.parse(value);
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              // Add this TextField for the notes
              decoration: InputDecoration(
                labelText: 'Notes', // Change the label text as desired
                labelStyle: TextStyle(fontSize: 18),
              ),
              onChanged: (value) {
                setState(() {
                  notes = value;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: title.isEmpty || amount <= 0
                  ? null
                  : () {
                widget.onTransactionAdded(title, amount, isExpense, notes); // Include notes in the callback
                Navigator.of(context).pop();
              },
              child: Text(
                'Add Transaction',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.deepPurple,
                textStyle: TextStyle(color: Colors.white),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}