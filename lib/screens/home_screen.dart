import 'package:flutter/material.dart';

import '../models/demo_video_post.dart';
import '../services/demo_post_store.dart';
import '../widgets/video_post_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text(
          'Glassnik',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),

      body:
          ValueListenableBuilder<
              List<DemoVideoPost>>(
        valueListenable:
            DemoPostStore.posts,

        builder: (
          context,
          posts,
          child,
        ) {
          if (posts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library_outlined,
                    size: 60,
                  ),

                  SizedBox(
                    height: 16,
                  ),

                  Text(
                    'No videos yet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(
                    height: 8,
                  ),

                  Padding(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 30,
                    ),
                    child: Text(
                      'Tap Upload below to add your first video.',
                      textAlign:
                          TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),

            itemCount: posts.length,

            itemBuilder: (
              context,
              index,
            ) {
              final post =
                  posts[index];

              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 16,
                ),
                child: VideoPostCard(
                  post: post,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
