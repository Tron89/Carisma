import 'package:carisma_flutter/util/colors.dart';
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
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        BottomNavigationBar(
          selectedItemColor: AppColors.selected.color, // Text clor
          unselectedItemColor: AppColors.unselected.color, // Text color
          backgroundColor: Colors.white,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_rounded,
                color: AppColors.unselected.color,
              ),
              label: "Inicio",
              activeIcon: Icon(
                Icons.home_rounded,
                color: AppColors.selected.color,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search_rounded,
                color: AppColors.unselected.color,
              ),
              label: "Buscar",
              activeIcon: Icon(
                Icons.search_rounded,
                color: AppColors.selected.color,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.add_rounded,
                color: AppColors.unselected.color,
              ),
              label: "",
              activeIcon: Icon(
                Icons.add_rounded,
                color: AppColors.selected.color,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.supervised_user_circle_rounded,
                color: AppColors.unselected.color,
              ),
              label: "Comunidades",
              activeIcon: Icon(
                Icons.supervised_user_circle_rounded,
                color: AppColors.selected.color,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.messenger_outline_rounded,
                color: AppColors.unselected.color,
              ),
              label: "Mensajes",
              activeIcon: Icon(
                Icons.messenger,
                color: AppColors.selected.color,
              ),
            ),
          ],
          currentIndex: selectedIndex,
          onTap: onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
        Positioned(
          top: -6,
          child: SizedBox(
            width: 60,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromARGB(255, 225, 225, 225),
                        blurRadius: 2,
                        spreadRadius: 4,
                        offset: Offset(0, 0)
                    )
                  ]
              ),
              child: FloatingActionButton(
                  onPressed: () => {},
                  elevation: 0,
                  highlightElevation: 0,
                  backgroundColor: AppColors.buttonPrimary.color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(30)),
                  child: Icon(Icons.add_rounded, color: AppColors.buttonSecondary.color, size: 40,)
              ),
            ),
          ),
        ),
      ],
    );
  }
}
