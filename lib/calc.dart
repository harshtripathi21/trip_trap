import 'dart:io';
import 'dart:math';

class Profile {
  String name = '';
  int amtGive = 0;
  int portion = 0;
  int compRefund = 0;
  int totalAmt = 0;
}

class Expense {
  String title = '';
  Profile? paidBy;
  int amount = 0;
  Map<Profile, int> portions = {};
}

class Calc {
  final List<Profile> persons = [];
  final List<Expense> expenses = [];
  final Map<Profile, int> dues = {};

  void calculateDues() {
    var amtGive = <Profile, int>{};
    var compRefund = <Profile, int>{};
    for (var p in persons) {
      amtGive[p] = 0;
      compRefund[p] = 0;
    }
    for (var e in expenses) {
      amtGive[e.paidBy!] = amtGive[e.paidBy!]! + e.amount;
      e.portions.forEach((key, value) {
        compRefund[key] = compRefund[key]! + value;
      });
    }
    for (var p in persons) {
      dues[p] = amtGive[p]! - compRefund[p]!;
    }
  }
}

void mainFunc() {
  stdout.write("Enter the number of friends going on the trip: ");
  final n = int.parse(stdin.readLineSync()!);
  final List<Profile> profiles = List.generate(n, (_) => Profile());

  print("Enter the names of friends:");
  for (int i = 0; i < n; i++) {
    profiles[i].name = stdin.readLineSync()!;
  }

  for (int i = 0; i < n; i++) {
    profiles[i].compRefund = 0;
    profiles[i].totalAmt = 0;
  }

  int c = 0;
  String s;
  while (true) {
    stdout.write("Enter a friend's name (or 'end' to finish): ");
    s = stdin.readLineSync()!;
    if (s == 'end') break;

    for (int i = 0; i < n; i++) {
      if (s == profiles[i].name) {
        c = i;
        stdout.write("Enter the amount given by ${profiles[c].name}: ");
        profiles[c].amtGive = int.parse(stdin.readLineSync()!);
        profiles[i].totalAmt += profiles[i].amtGive;

        for (int i = 0; i < n; i++) {
          stdout.write("Enter the portion for ${profiles[i].name}: ");
          profiles[i].portion = int.parse(stdin.readLineSync()!);
          profiles[i].compRefund += profiles[i].portion;
        }
      }
    }
  }

  // stdout.write("Choose an option: (1) Next payment or (2) End: ");
  // final b = int.parse(stdin.readLineSync()!);
  for (int i = 0; i < n; i++) {
    print(
        "${profiles[i].name} owes: ${profiles[i].totalAmt - profiles[i].compRefund}");
  }
}
