import 'package:flutter/material.dart';

class ExploreScreen
    extends StatefulWidget {
  const ExploreScreen({
    super.key,
  });

  @override
  State<ExploreScreen> createState() =>
      _ExploreScreenState();
}

class _ExploreScreenState
    extends State<ExploreScreen> {
  final TextEditingController
      _searchController =
      TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        automaticallyImplyLeading:
            false,
        title: const Text(
          'Explore',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            TextField(
              controller:
                  _searchController,

              decoration:
                  InputDecoration(
                hintText:
                    'Search Glassnik...',

                prefixIcon:
                    const Icon(
                  Icons.search,
                ),

                suffixIcon:
                    IconButton(
                  onPressed: () {
                    _searchController
                        .clear();
                  },
                  icon:
                      const Icon(
                    Icons.close,
                  ),
                ),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    16,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            const Text(
              'Discover',
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label:
                      Text('#Trending'),
                ),
                Chip(
                  label:
                      Text('#Music'),
                ),
                Chip(
                  label:
                      Text('#Gaming'),
                ),
                Chip(
                  label:
                      Text('#Travel'),
                ),
                Chip(
                  label:
                      Text('#Funny'),
                ),
                Chip(
                  label:
                      Text('#Food'),
                ),
              ],
            ),

            const Spacer(),

            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.explore_outlined,
                    size: 65,
                    color: Colors.grey,
                  ),

                  SizedBox(
                    height: 12,
                  ),

                  Text(
                    'More discovery features\ncoming soon',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color:
                          Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
