import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/provider/user_provider.dart';
import 'package:instagram/resources/firestore_methods.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/models/user.dart';
import 'package:instagram/widgets/comments_card.dart';
import 'package:provider/provider.dart';

class CommentsScreen extends StatefulWidget {
  final snap;

  const CommentsScreen({Key? key, required this.snap}) : super(key: key);

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    TextEditingController _commentController = TextEditingController();

    Future<void> onSubmitted() async {
      FirestoreMethods().postComment(
        widget.snap['postId'],
        _commentController.text,
        user.uid,
        user.username,
        user.photoUrl,
        null,
      );
      setState(() {
        _commentController.text = '';
      });
    }

    @override
    void dispose() {
      super.dispose();
      _commentController.dispose();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('Comments'),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.snap['postId'])
            .collection('comments')
            .orderBy(
              'datePublished',
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List commentList = (snapshot.data! as dynamic).docs;
          return ListView.builder(
            itemCount: commentList.length,
            itemBuilder: (context, index) => CommentCard(
              snap: commentList[index].data(),
              postId: widget.snap['postId'],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          padding: const EdgeInsets.only(
            left: 16,
            right: 8,
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user.photoUrl),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 8,
                  ),
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Comment as username',
                      border: InputBorder.none,
                    ),
                    autocorrect: false,
                    onSubmitted: (value) async {
                      onSubmitted();
                    },
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  onSubmitted();
                  setState(() {
                    _commentController.text = '';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text(
                    'Posts',
                    style: TextStyle(
                      color: blueColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
