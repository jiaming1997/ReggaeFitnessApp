import 'package:flutter/cupertino.dart';

import 'class_description.dart';

class CustomList extends StatelessWidget {
  const CustomList({
    Key? key,
    required this.thumbnail,
    required this.class_name,
    required this.class_date,
    required this.start_time,
    required this.end_time,
    required this.class_capacity,
  }) : super(key: key);

  final Widget thumbnail;
  final String class_name;
  final String class_date;
  final String start_time;
  final String end_time;
  final String class_capacity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child:ClipRRect(
                borderRadius:
                const BorderRadius.all(Radius.circular(16.0)),
                  child:AspectRatio(
                    aspectRatio: 1.0,
                    child: thumbnail,
                  ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0),
                child: ClassDescription(
                  class_name: class_name,
                  class_date: class_date,
                  start_time: start_time,
                  end_time: end_time,
                  class_capacity: class_capacity,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}