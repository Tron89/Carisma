import 'package:flutter/material.dart';

class TopNavBar extends StatelessWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.menu), onPressed: () => {}),
          const Spacer(),
          IconButton(icon: Icon(Icons.search), onPressed: () => {}),
          IconButton(icon: Icon(Icons.face), onPressed: () => {}),
        ],
      ),
    );
  }
}
