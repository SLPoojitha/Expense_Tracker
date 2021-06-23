//import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final double amount;
  @HiveField(2)
  final String date;
  Transaction(this.title,this.amount,this.date);
}