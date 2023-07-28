import 'package:flutter/material.dart';
import 'package:expensetracker/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ExpenseScreen.dart'; // Import the ExpenseScreen class

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  final User? user = Auth().currentuser;
  Future<void> signOut(BuildContext context) async {
    await Auth().signOut();
  }

  Widget _title() {
    return Text(
      'Expense Tracker',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _userUid() {
    return Text(
      user?.email ?? 'User email',
      style: TextStyle(
        fontSize: 18,
        color: Colors.white,
      ),
    );
  }

  Widget _signOutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => signOut(context), // Pass the context to signOut method
      child: const Text(
        'Sign Out',
        style: TextStyle(fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        primary: Colors.red, // Use red color for the sign-out button
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        centerTitle: true,
        elevation: 0, // Remove shadow from the app bar
        actions: [
          _signOutButton(context), // Add the signOut button to the AppBar
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5A57CA),
              Color(0xFF2C2978),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.account_circle,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              _userUid(),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExpenseScreen(
                        updateTotalAmount: (totalAmount) {
                          // This function is not used in this version of HomePage
                        },
                      ),
                    ),
                  );
                },
                child: Icon(Icons.arrow_forward, size: 32),
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(20),
                  primary: Colors.deepPurple,
                  elevation: 4,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'View Expenses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
