import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/blog_provider.dart';
import '../widgets/blog_card.dart';
import 'blog_detail_screen.dart';

class BlogsScreen extends StatelessWidget {
  const BlogsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<BlogProvider>();

    final blogs = provider.blogs;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Health Blogs',
        ),
        centerTitle: true,
      ),

      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: blogs.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final blog = blogs[index];

          return BlogCard(
            blog: blog,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      BlogDetailScreen(
                    blog: blog,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
