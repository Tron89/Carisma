import 'package:flutter/material.dart';

class Post extends StatelessWidget {
  const Post({super.key});

  static double iconsSize = 50;
  static TextStyle _textStyle = TextStyle(fontSize: 20);
  static TextStyle _titleStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 20, height: 20, color: Colors.blue),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text("u/UsuarioGenerico"),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text("Titulo generico de la publicacion", style: _titleStyle,),
        ),
        Row(
          children: [
            Container(width: iconsSize, height: iconsSize, color: Colors.green),
            Text("100", style: _textStyle,),
            Container(width: iconsSize, height: iconsSize, color: Colors.red),
            Container(
              width: iconsSize,
              height: iconsSize,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }
}
