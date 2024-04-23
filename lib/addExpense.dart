import 'package:flutter/material.dart';
import 'package:trip_tracker/calc.dart';

class AddExpenseButton extends StatefulWidget {
  const AddExpenseButton({
    super.key,
    required this.profiles,
    required this.onSubmit,
  });

  final List<Profile> profiles;
  final Function(Expense) onSubmit;

  @override
  State<AddExpenseButton> createState() => _AddExpenseButtonState();
}

class _AddExpenseButtonState extends State<AddExpenseButton>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: (widget.profiles.isNotEmpty &&
              widget.profiles.every((e) => e.name.isNotEmpty))
          ? () {
              showModalBottomSheet<dynamic>(
                isScrollControlled: true,
                showDragHandle: true,
                context: context,
                builder: (context) {
                  return AddExpenseForm(
                    profiles: widget.profiles,
                    onSubmit: widget.onSubmit,
                  );
                },
              );
            }
          : null,
      icon: const Icon(Icons.person_add),
    );
  }
}

class AddExpenseForm extends StatefulWidget {
  const AddExpenseForm({
    super.key,
    required this.profiles,
    required this.onSubmit,
  });

  final List<Profile> profiles;
  final Function(Expense) onSubmit;

  @override
  State<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<AddExpenseForm> {
  var expense = Expense();
  var portionList = <MapEntry<Profile?, int>>[];
  final _formKey = GlobalKey<FormState>();

  int getPortionSum() {
    return (portionList.isNotEmpty)
        ? portionList.map((e) => e.value).toList().reduce((v, e) => v + e)
        : 0;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 1,
      minChildSize: 0.5,
      builder: (context, scrollCtl) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Add Expense',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 25),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtl,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Expense Title',
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) return null;
                            return "Please enter a title";
                          },
                          onChanged: (value) {
                            expense.title = value;
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        DropdownButtonFormField(
                          items: widget.profiles
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            expense.paidBy = value;
                          },
                          validator: (value) {
                            if (value == null) return "Please select a person";
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Amount Paid',
                          ),
                          validator: (value) {
                            if (value != null && int.tryParse(value) != null) {
                              return null;
                            }
                            return "Please enter a valid integer";
                          },
                          onChanged: (value) {
                            int? amount = int.tryParse(value);
                            if (amount != null) {
                              setState(() {
                                expense.amount = amount;
                              });
                            }
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Portions:'),
                            IconButton(
                              onPressed:
                                  (portionList.length == widget.profiles.length)
                                      ? null
                                      : () {
                                          setState(() {
                                            portionList
                                                .add(const MapEntry(null, 0));
                                          });
                                        },
                              icon: const Icon(Icons.person_add),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 500,
                          child: (portionList.isEmpty)
                              ? const Center(
                                  child: Text(
                                    'Please add a portion the button on the top left',
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: portionList.length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      child: ListTile(
                                        title: Column(
                                          children: [
                                            DropdownButtonFormField(
                                              items: widget.profiles
                                                  .where((e) {
                                                    for (var p in portionList) {
                                                      if (p.key != null &&
                                                          p.key == e &&
                                                          e !=
                                                              portionList[index]
                                                                  .key) {
                                                        return false;
                                                      }
                                                    }
                                                    return true;
                                                  })
                                                  .map(
                                                    (e) => DropdownMenuItem(
                                                      value: e,
                                                      child: Text(e.name),
                                                    ),
                                                  )
                                                  .toList(),
                                              onChanged: (value) {
                                                portionList[index] = MapEntry(
                                                    value,
                                                    portionList[index].value);
                                              },
                                              validator: (value) {
                                                if (value == null) {
                                                  return "Please select a person";
                                                }
                                              },
                                            ),
                                            TextFormField(
                                              decoration: const InputDecoration(
                                                labelText: 'Amount',
                                              ),
                                              validator: (value) {
                                                if (value != null &&
                                                    int.tryParse(value) !=
                                                        null) {
                                                  return null;
                                                }
                                                return "Please enter a valid integer";
                                              },
                                              onChanged: (value) {
                                                if (int.tryParse(value) !=
                                                    null) {
                                                  setState(() {
                                                    portionList[index] =
                                                        MapEntry(
                                                            portionList[index]
                                                                .key,
                                                            int.parse(value));
                                                  });
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                        trailing: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              portionList.removeAt(index);
                                            });
                                          },
                                          icon: const Icon(Icons.delete),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${getPortionSum()} / ${expense.amount}',
                    style: TextStyle(
                        color: (getPortionSum() == expense.amount)
                            ? Colors.green
                            : Colors.red),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (getPortionSum() != expense.amount) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "The Amount and Portions don't add up!",
                                      ),
                                      Text(
                                        '${getPortionSum()} / ${expense.amount}',
                                        style: TextStyle(
                                            color: (getPortionSum() ==
                                                    expense.amount)
                                                ? Colors.green
                                                : Colors.red),
                                      ),
                                      const SizedBox(height: 25),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          for (var e in portionList) {
                            expense.portions[e.key!] = e.value;
                          }
                          widget.onSubmit(expense);
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Add Expense'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
