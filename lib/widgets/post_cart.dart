import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:instagram_clone_flutter/providers/user_provider.dart';
import 'package:instagram_clone_flutter/resources/firestore_methods.dart';
import 'package:instagram_clone_flutter/screens/comments_screen.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';
import 'package:instagram_clone_flutter/widgets/like_animations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

class PostCart extends StatefulWidget {
  final snap;
  const PostCart({Key? key, required this.snap}) : super(key: key);

  @override
  State<PostCart> createState() => _PostCartState();
}

class _PostCartState extends State<PostCart> {
  Uint8List? _file;
  bool isLikeAnimating = false;

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<UserProvider>(context).getUser;
    return user == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : _file == null
            ? Container(
                color: mobileBackgroundColor,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    // HEADER SECTION
                    Container(
                      padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 16)
                          .copyWith(right: 0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage:
                                NetworkImage(widget.snap['profImage']),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.snap['username'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onDoubleTap: () async {
                        await FirestoreMethods().likePost(widget.snap['postId'],
                            user.uid, widget.snap['likes']);
                        setState(() {
                          isLikeAnimating = true;
                        });
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.35,
                            width: double.infinity,
                            child: Image.network(
                              widget.snap['postUrl'],
                              fit: BoxFit.cover,
                            ),
                          ),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isLikeAnimating ? 1 : 0,
                            child: LikeAnimation(
                              isAnimating: isLikeAnimating,
                              duration: const Duration(
                                milliseconds: 400,
                              ),
                              onEnd: () {
                                setState(() {
                                  isLikeAnimating = false;
                                });
                              },
                              child: const Icon(
                                Icons.favorite,
                                size: 100,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    //LIKE COMMENT SECTION
                    Row(
                      children: [
                        LikeAnimation(
                          isAnimating: widget.snap['likes'].contains(user.uid),
                          child: IconButton(
                              onPressed: () async {
                                await FirestoreMethods().likePost(
                                    widget.snap['postId'],
                                    user.uid,
                                    widget.snap['likes']);
                                setState(() {
                                  isLikeAnimating = true;
                                });
                              },
                              icon: widget.snap['likes'].contains(user.uid)
                                  ? const Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                    )
                                  : const Icon(
                                      Icons.favorite_border,
                                    )),
                        ),
                        IconButton(
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => CommentsScreen())),
                            icon: const Icon(
                              Icons.comment_outlined,
                            )),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.send,
                            )),
                        Expanded(
                            child: Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            icon: const Icon(Icons.bookmark_border),
                            onPressed: () {},
                          ),
                        )),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            DefaultTextStyle(
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(fontWeight: FontWeight.w800),
                                child: Text(
                                  '${widget.snap['likes'].length} likes',
                                  style: Theme.of(context).textTheme.bodyText2,
                                )),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(
                                top: 8,
                              ),
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: primaryColor),
                                  children: [
                                    TextSpan(
                                      text: widget.snap['username'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' ${widget.snap['description']}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: const Text(
                                  'View all 200 comments',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: secondaryColor,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                DateFormat.yMMMMd().format(
                                    widget.snap['datePublished'].toDate()),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: secondaryColor,
                                ),
                              ),
                            ),
                          ]),
                    )
                  ],
                ),
              )
            : CircularProgressIndicator();
  }
}
