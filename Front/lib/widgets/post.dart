import 'package:flutter/material.dart';

class Post extends StatelessWidget {
  final String? img;
  final String title;

  final int likes;
  final int dislikes;
  final int comments;

  const Post({
    super.key,
    this.img,
    required this.title,
    required this.likes,
    required this.dislikes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = TextStyle(fontSize: 20);
    final TextStyle titleStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => {},
              icon: Icon(Icons.face),
              style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text("u/UsuarioGenerico"),
            ),
            Spacer(),
            TextButton(child: const Text("Join"), onPressed: () => {}),
          ],
        ),
        Text(title, style: titleStyle),
        if (img != null) Image.network(img!),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              IconButton(
                onPressed: () => {},
                icon: Icon(Icons.check_rounded),
                style: IconButton.styleFrom(
                  padding: EdgeInsets.only(right: 5),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
              ),
              Text(likes.toString(), style: textStyle),
              IconButton(
                onPressed: () => {},
                icon: Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                    padding: EdgeInsets.only(left: 10, right: 5),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
              ),
              Text(dislikes.toString(), style: textStyle),
              Spacer(),
              IconButton(
                onPressed: () => {},
                icon: Icon(Icons.messenger_outline_rounded),
                style: IconButton.styleFrom(
                    padding: EdgeInsets.only(right: 5),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
              ),
              Text(comments.toString(), style: textStyle),
              IconButton(
                onPressed: () => {},
                icon: Icon(Icons.share_rounded),
                style: IconButton.styleFrom(
                    padding: EdgeInsets.only(left: 10),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
