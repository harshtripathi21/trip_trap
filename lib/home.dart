import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trip_trap/addExpense.dart';
import 'calc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final calc = Calc();
  final _namesFormKey = GlobalKey<FormState>();

  String getExpenseInfo(Expense expense) {
    return "Amount: ${expense.amount.toString()}   Paid By: ${expense.paidBy!.name}\nPortions: ${expense.portions.keys.map((e) => "${e.name} : ${expense.portions[e]}").toList().reduce((value, element) => '$value, $element')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text(
            'Trip Tracker',
            style: TextStyle(
              fontSize: 26.0,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Color.fromARGB(255, 1, 65, 117),
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'People:',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      calc.persons.add(Profile());
                    });
                  },
                  icon: const Icon(Icons.person_add),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 4,
              child: (calc.persons.isEmpty)
                  ? const Center(
                      child: Text(
                        'Add a person by using the button on the top left',
                      ),
                    )
                  : Form(
                      key: _namesFormKey,
                      child: ListView.builder(
                        itemCount: calc.persons.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Person Name',
                                ),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty)
                                    return null;
                                  return "Please enter a name";
                                },
                                onChanged: (value) {
                                  _namesFormKey.currentState!.validate();
                                  setState(() {
                                    calc.persons[index].name = value;
                                  });
                                },
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  setState(() {
                                    calc.persons.removeAt(index);
                                  });
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Expenses:',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                AddExpenseButton(
                  profiles: calc.persons,
                  onSubmit: (expense) {
                    setState(() {
                      calc.expenses.add(expense);
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: (calc.expenses.isEmpty)
                  ? Center(
                      child: Text(
                        (calc.persons.isNotEmpty &&
                                    (_namesFormKey.currentState != null)
                                ? _namesFormKey.currentState!.validate()
                                : false)
                            ? 'Add an expense by using the button on the top left'
                            : 'Add some people first',
                      ),
                    )
                  : ListView.builder(
                      itemCount: calc.expenses.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(calc.expenses[index].title),
                            subtitle:
                                Text(getExpenseInfo(calc.expenses[index])),
                            trailing: IconButton(
                              onPressed: () {
                                setState(() {
                                  calc.expenses.removeAt(index);
                                });
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            FilledButton(
              onPressed: (calc.expenses.isEmpty)
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          calc.calculateDues();
                          return Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SizedBox(
                                width: min(500,
                                    MediaQuery.of(context).size.width * 0.95),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                        Text(
                                          'Dues',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                        const SizedBox(height: 30),
                                      ] +
                                      calc.dues.entries
                                          .map(
                                            (e) => ListTile(
                                              title: Text(e.key.name +
                                                  ((e.value > 0)
                                                      ? " gets "
                                                      : " gives ") +
                                                  e.value.abs().toString()),
                                            ),
                                          )
                                          .toList() +
                                      [
                                        const SizedBox(height: 15),
                                        ListTile(
                                          title: Text(
                                            "Total Amount: ${calc.expenses.map((e) => e.amount).reduce((v, e) => v + e)}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                        ),
                                      ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calculate),
                    Text('Calculate Dues'),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Text("~ Made by Harsh Tripathi"),
          ],
        ),
      ),
    );
  }
}
