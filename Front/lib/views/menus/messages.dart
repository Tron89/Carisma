import 'dart:math';
import 'dart:convert';

import 'package:carisma_flutter/models/post.dart';
import 'package:carisma_flutter/util/commons.dart';
import 'package:carisma_flutter/util/functions.dart';
// import 'package:carisma_flutter/util/app_data.dart';
import 'package:carisma_flutter/util/http_connection.dart';
import 'package:carisma_flutter/widgets/bottom_nav_bar.dart';
import 'package:carisma_flutter/widgets/post.dart';
import 'package:carisma_flutter/widgets/top_nav_bar.dart';
import 'package:flutter/material.dart';

class MessagesView extends StatefulWidget {
  const MessagesView({super.key});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(

      )
    );
  }
}
