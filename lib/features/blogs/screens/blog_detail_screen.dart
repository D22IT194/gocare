import 'package:flutter/material.dart';

import '../models/blog_model.dart';

class BlogDetailScreen extends StatelessWidget {
  const BlogDetailScreen({
    super.key,
    required this.blog,
  });

  final BlogModel blog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Health Blog',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.article_outlined,
                size: 80,
                color: Color(0xFF1976D2),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              blog.category,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1976D2),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              blog.title,
              style: const TextStyle(
                fontSize: 28,
                height: 1.2,
                fontWeight: FontWeight.w700,
                color: Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              blog.readTime,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF98A2B3),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              blog.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.7,
                color: Color(0xFF475467),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'About this topic',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'GoCare provides health and emergency information to help you understand important safety steps. Always seek professional medical assistance when an emergency requires it.',
              style: TextStyle(
                fontSize: 15,
                height: 1.7,
                color: Color(0xFF475467),
              ),
            ),
          ],
        ),
      ),
    );
  }
}