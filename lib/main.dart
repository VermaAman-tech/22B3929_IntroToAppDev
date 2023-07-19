import 'package:flutter/material.dart';
import 'ExpenseScreen.dart';

void main() => runApp(MaterialApp(
  home: BudgetTracker(),
  routes: {
    '/expense': (context) => ExpenseScreen(
      updateTotalAmount: (totalAmount) {
        // Update the total amount in BudgetTrackerBody
        BudgetTrackerBody.totalAmount = totalAmount;
      },
    ),
  },
  theme: ThemeData(
    primarySwatch: Colors.deepPurple,
    textTheme: TextTheme(
      headline6: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyText2: TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
    ),
  ),
));

class BudgetTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Budget Tracker App',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[400],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            // Handle back button press here
            // Implement your logic to go back or navigate to a previous screen
          },
        ),
      ),
      body: BudgetTrackerBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle floating action button press here
          // Navigate to the "Add Expense" screen
          Navigator.pushNamed(context, '/expense');
        },
        backgroundColor: Colors.deepPurple[400],
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: Colors.deepPurple[100],
    );
  }
}

class BudgetTrackerBody extends StatefulWidget {
  static double totalAmount = 0.0;

  @override
  _BudgetTrackerBodyState createState() => _BudgetTrackerBodyState();
}

class _BudgetTrackerBodyState extends State<BudgetTrackerBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ScaleTransition(
          scale: _animation,
          child: Column(
            children: <Widget>[
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurple,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.4),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 80,
                ),
              ),
              SizedBox(height: 16),
              Column(
                children: <Widget>[
                  Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Text(
                    'Back!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Card(
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: [
                    Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(width: 8),
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Text(
                          '\$${(_animation.value * BudgetTrackerBody.totalAmount).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          // Handle link to the "Expense" screen
                          Navigator.pushNamed(context, '/expense');
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.deepPurple[400],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
