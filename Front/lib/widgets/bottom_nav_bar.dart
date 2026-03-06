import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Color.fromARGB(255, 69, 69, 69),
      unselectedItemColor: Color.fromARGB(128, 69, 69, 69),
      backgroundColor: Color.fromARGB(255, 207, 207, 207),
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Color.fromARGB(128, 69, 69, 69)),
          label: "Casa",
          activeIcon: Icon(Icons.home, color: Color.fromARGB(255, 69, 69, 69)),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.search_rounded,
            color: Color.fromARGB(128, 69, 69, 69),
          ),
          label: "Buscar",
          activeIcon: Icon(
            Icons.search_rounded,
            color: Color.fromARGB(255, 69, 69, 69),
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.messenger_outline_rounded,
            color: Color.fromARGB(128, 69, 69, 69),
          ),
          label: "Mensajes",
          activeIcon: Icon(
            Icons.messenger,
            color: Color.fromARGB(255, 69, 69, 69),
          ),
        ),
      ],
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed,
    );
  }
}
