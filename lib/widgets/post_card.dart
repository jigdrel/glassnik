import 'package:flutter/material.dart';

import '../models/post.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    final displayedLikes =
        isLiked ? widget.post.likes + 1 : widget.post.likes;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: _buildProfileImage(),
            title: Text(
              widget.post.username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(Icons.more_vert),
          ),

          AspectRatio(
            aspectRatio: 4 / 5,
            child: _buildPostImage(),
          ),

          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isLiked = !isLiked;
                  });
                },
                icon: Icon(
                  isLiked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: isLiked ? Colors.red : null,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.comment_outlined),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share_outlined),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_border),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Text(
              '$displayedLikes likes',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              4,
            ),
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: '${widget.post.username} ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: widget.post.caption,
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16,
            ),
            child: Text(
              'View all ${widget.post.comments} comments',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    final profileImage = widget.post.profileImage.trim();

    if (profileImage.isEmpty) {
      return const CircleAvatar(
        child: Icon(Icons.person),
      );
    }

    return CircleAvatar(
      backgroundColor: Colors.grey.shade300,
      child: ClipOval(
        child: Image.network(
          profileImage,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          webHtmlElementStrategy:
              WebHtmlElementStrategy.prefer,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return const Icon(Icons.person);
          },
        ),
      ),
    );
  }

  Widget _buildPostImage() {
    final postImage = widget.post.postImage.trim();

    if (postImage.isEmpty) {
      return Container(
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: const Text(
          'No image available',
        ),
      );
    }

    return Image.network(
      postImage,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,

      // Important for Firebase Storage on Flutter Web.
      webHtmlElementStrategy:
          WebHtmlElementStrategy.prefer,

      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return Container(
          color: Colors.grey.shade300,
          alignment: Alignment.center,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 50,
              ),
              SizedBox(height: 8),
              Text('Unable to load image'),
            ],
          ),
        );
      },
    );
  }
}