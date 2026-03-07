import 'package:flutter/material.dart';

class PostView extends StatelessWidget {
  final String? img;
  final String title;
  final String user;

  final int likes;
  final int dislikes;
  final int comments;

  const PostView({
    super.key,
    this.img,
    required this.title,
    required this.user,
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
              child: Text(user),
            ),
            Spacer(),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 17, 70, 90),
                backgroundColor: Color.fromARGB(255, 126, 201, 230),
                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(50)),
                padding: EdgeInsets.all(0),
              ),
              child: const Text("Join"),
              onPressed: () => {},
            ),
          ],
        ),
        Text(title, style: titleStyle),
        if (img != null) Image.network(img!),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(right: 5),
                child: IconButton(
                  onPressed: () => {},
                  icon: Icon(Icons.check_rounded),
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.all(0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                  ),
                ),
              ),
              Text(likes.toString(), style: textStyle),
              Container(
                margin: EdgeInsets.only(left: 10, right: 5),
                child: IconButton(
                  onPressed: () => {},
                  icon: Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                      padding: EdgeInsets.all(0),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap
                  ),
                ),
              ),
              Text(dislikes.toString(), style: textStyle),
              Spacer(),
              Container(
                margin: EdgeInsets.only(right: 5),
                child: IconButton(
                  onPressed: () => {},
                  icon: Icon(Icons.messenger_outline_rounded),
                  style: IconButton.styleFrom(
                      padding: EdgeInsets.all(0),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap
                  ),
                ),
              ),
              Text(comments.toString(), style: textStyle),
              Container(
                margin: EdgeInsets.only(left: 10),
                child: IconButton(
                  onPressed: () => {},
                  icon: Icon(Icons.share_rounded),
                  style: IconButton.styleFrom(
                      padding: EdgeInsets.all(0),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
