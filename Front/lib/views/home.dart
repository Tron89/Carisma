import 'dart:math';

import 'package:carisma_flutter/views/menus/posts.dart';
import 'package:carisma_flutter/widgets/bottom_nav_bar.dart';
import 'package:carisma_flutter/widgets/top_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:carisma_flutter/views/menus/search.dart';

class HomeView extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;
  const HomeView({super.key, required this.token, required this.user});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final Random rng = Random();

  int currentIndex = 0;

  void onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            TopNavBar(),
            switch (currentIndex) {
              0 => PostsView(),
              1 => SearchView(),
              2 => PostsView(),
              3 => PostsView(),
              // TODO: Handle this case.
              int() => throw UnimplementedError(),
            },
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: currentIndex,
        onItemTapped: onItemTapped,
      ),
    );
  }
}
