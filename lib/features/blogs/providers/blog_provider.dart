import 'package:flutter/foundation.dart';

import '../models/blog_model.dart';

class BlogProvider extends ChangeNotifier {
  final List<BlogModel> _blogs = [
    const BlogModel(
      id: '1',
      title:
          'What to do during a medical emergency?',
      description:
          'Learn the important steps you should take when someone needs immediate medical assistance.',
      category: 'Emergency',
      readTime: '4 min read',
    ),
    const BlogModel(
      id: '2',
      title:
          '5 first aid steps everyone should know',
      description:
          'Simple first aid techniques that can help you respond confidently before professional help arrives.',
      category: 'First Aid',
      readTime: '5 min read',
    ),
    const BlogModel(
      id: '3',
      title:
          'How to prepare for an emergency',
      description:
          'Build an emergency plan and keep important information ready when you need it most.',
      category: 'Safety',
      readTime: '6 min read',
    ),
    const BlogModel(
      id: '4',
      title:
          'Finding healthcare near you',
      description:
          'Learn how to quickly find hospitals, clinics and pharmacies when healthcare is needed.',
      category: 'Healthcare',
      readTime: '3 min read',
    ),
  ];

  List<BlogModel> get blogs =>
      List.unmodifiable(_blogs);
}