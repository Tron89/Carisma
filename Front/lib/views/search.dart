import 'dart:math';
import 'dart:convert';

import 'package:carisma_flutter/models/post_info.dart';
import 'package:carisma_flutter/util/commons.dart';
import 'package:carisma_flutter/util/functions.dart';
// import 'package:carisma_flutter/util/app_data.dart';
import 'package:carisma_flutter/util/http_connection.dart';
import 'package:carisma_flutter/widgets/bottom_nav_bar.dart';
import 'package:carisma_flutter/widgets/post.dart';
import 'package:carisma_flutter/widgets/top_nav_bar.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;
  const HomeView({super.key, required this.token, required this.user});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final Random rng = Random();
  final ScrollController scrollController = ScrollController();
  final api = HttpConnection(urlString);

  int currentIndex = 0;
  bool isLoading = false;

  List<PostInfo> posts = [];

  void onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    getPosts(); // carga inicial

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        onReachEnd();
      }
    });
  }

  Future<void> getPosts() async {
    final response = await api.get('posts');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<PostInfo> fetchedPosts = data.map((post) {
        String? imgUrl = post['image_url']?.toString();
        return PostInfo(
          (imgUrl == null || imgUrl.trim().isEmpty) ? null : imgUrl,
          post['title'] ?? 'No Title',
          post['likes'] ?? 0, // Likes
          post['dislikes'] ?? 0, // Dislikes
          post['comments'] ?? 0, // Comments
          post['author']['username'] ?? "Unknown User",
        );
      }).toList();

      setState(() {
        posts.addAll(fetchedPosts);
      });
      return;
    } else {
      Functions.showDebug(
        "Error fetching posts: ${response.statusCode}",
        tag: 'register',
      );
      return;
    }
  }

  Future<void> onReachEnd() async {
    if (isLoading) return;

    isLoading = true;
    await getPosts();
    isLoading = false;
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 25, 191, 255),
      body: SafeArea(
        child: Column(
          children: [
            TopNavBar(),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: RefreshIndicator(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final data = posts[index];
                        return Post(
                          img: data.img,
                          title: data.title,
                          user: data.user,
                          likes: data.likes,
                          dislikes: data.dislikes,
                          comments: data.comments,
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                    ),
                    onRefresh: () async {
                      posts.clear();
                      await getPosts();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          BottomNavBar(selectedIndex: currentIndex, onItemTapped: onItemTapped),
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
                      color: Colors.white,
                      blurRadius: 0,
                      spreadRadius: 4,
                      offset: Offset(0, 0)
                    )
                  ]
                ),
                child: FloatingActionButton(
                  onPressed: () => {},
                  elevation: 0,
                  highlightElevation: 0,
                  backgroundColor: Color.fromARGB(255, 126, 201, 230),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(30)),
                  child: Icon(Icons.add_rounded, color: Color.fromARGB(
                      255, 6, 69, 92), size: 40,)
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
