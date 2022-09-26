import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ClassDescription extends StatelessWidget {
  const ClassDescription({
    Key? key,
    required this.class_name,
    required this.class_date,
    required this.start_time,
    required this.end_time,
    required this.class_capacity,
  }) : super(key: key);

  final String class_name;
  final String class_date;
  final String start_time;
  final String end_time;
  final String class_capacity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                class_name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,fontSize: 16,
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Text(
                class_date,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Time: "+
                '$start_time - $end_time',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black87,
                ),
              ),
              Text("Capacity: "+
                class_capacity,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}