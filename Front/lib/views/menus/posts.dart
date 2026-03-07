import 'dart:convert';

import 'package:carisma_flutter/models/post.dart';
import 'package:carisma_flutter/util/commons.dart';
import 'package:carisma_flutter/util/functions.dart';
import 'package:carisma_flutter/util/http_connection.dart';
import 'package:carisma_flutter/widgets/post.dart';
import 'package:flutter/material.dart';

class PostsView extends StatefulWidget {
  const PostsView({super.key});

  @override
  State<PostsView> createState() => _PostsViewState();
}

class _PostsViewState extends State<PostsView> {
  final api = HttpConnection(urlString);
  final ScrollController scrollController = ScrollController();

  bool isLoading = false;

  List<PostInfo> posts = [];

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
    return Expanded(
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
                return PostView(
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
    );
  }
}
