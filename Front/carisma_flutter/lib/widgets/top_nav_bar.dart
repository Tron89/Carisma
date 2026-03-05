import 'package:flutter/material.dart';

class TopNavBar extends StatelessWidget {
    final void Function() onLogout;
  const TopNavBar({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.menu), onPressed: () => {}),
          const Spacer(),
          IconButton(icon: Icon(Icons.search), onPressed: () => {}),
          IconButton(icon: Icon(Icons.face), onPressed: onLogout),
        ],
      ),
    );
  }
}
