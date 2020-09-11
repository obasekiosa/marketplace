import 'package:flutter/material.dart';
import 'package:marketplace/widgets/widgets.dart';
import 'package:marketplace/screens/screens.dart';

class PostTile extends StatelessWidget {

  final Post post;

  PostTile({this.post});

  showPost(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostScreen(postId: this.post.postId, userId: this.post.ownerId,),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
