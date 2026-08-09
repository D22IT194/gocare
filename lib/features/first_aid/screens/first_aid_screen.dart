import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/first_aid_model.dart';
import '../providers/first_aid_provider.dart';
import '../widgets/first_aid_card.dart';
import 'first_aid_detail_screen.dart';

class FirstAidScreen extends StatefulWidget {
  const FirstAidScreen({
    super.key,
  });

  @override
  State<FirstAidScreen> createState() =>
      _FirstAidScreenState();
}

class _FirstAidScreenState
    extends State<FirstAidScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<FirstAidProvider>();

    final categories = [
      'All',
      ...provider.categories,
    ];

    final List<FirstAidModel> items =
        _selectedCategory == 'All'
            ? provider.items
            : provider.byCategory(
                _selectedCategory,
              );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'First Aid',
        ),
        centerTitle: true,
      ),

      body: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              4,
            ),
            child: Text(
              'How can we help?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF172B4D),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Text(
              'Quick first aid information for common emergencies.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF667085),
              ),
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category =
                    categories[index];

                final selected =
                    category == _selectedCategory;

                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory =
                          category;
                    });
                  },
                  selectedColor:
                      const Color(0xFF1976D2),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected
                        ? Colors.white
                        : const Color(0xFF475467),
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: selected
                        ? const Color(0xFF1976D2)
                        : const Color(0xFFEAECF0),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                24,
              ),
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];

                return FirstAidCard(
                  item: item,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FirstAidDetailScreen(
                          item: item,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
