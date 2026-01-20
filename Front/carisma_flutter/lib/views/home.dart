import 'dart:math';
import 'dart:convert';

import 'package:carisma_flutter/models/post_info.dart';
// import 'package:carisma_flutter/util/app_data.dart';
import 'package:carisma_flutter/util/http_connection.dart';
import 'package:carisma_flutter/widgets/bottom_nav_bar.dart';
import 'package:carisma_flutter/widgets/post.dart';
import 'package:carisma_flutter/widgets/top_nav_bar.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final Random rng = Random();
  final ScrollController scrollController = ScrollController();
  final api = HttpConnection('http://10.0.2.2:8000/v1/');

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
          (imgUrl == null || imgUrl.isEmpty) ? null : imgUrl,
          post['title'] ?? 'No Title',
          rng.nextInt(1000), // Likes aleatorios
          rng.nextInt(1000), // Dislikes aleatorios
          rng.nextInt(500),  // Comments aleatorios
        );
      }).toList();

      setState(() {
        posts.addAll(fetchedPosts);
      });
      return;
    } else {
      print("Error fetching posts: ${response.statusCode}");
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
      backgroundColor: Color.fromARGB(255, 207, 207, 207),
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
      bottomNavigationBar: BottomNavBar(
        selectedIndex: currentIndex,
        onItemTapped: onItemTapped,
      ),
    );
  }
}
