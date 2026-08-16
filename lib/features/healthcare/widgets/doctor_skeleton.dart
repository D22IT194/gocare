import 'package:flutter/material.dart';

class DoctorSkeleton extends StatelessWidget {
  const DoctorSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEAECF0),
        ),
      ),
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _box(
            width: 72,
            height: 72,
            radius: 18,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _box(
                  width: 170,
                  height: 17,
                ),
                const SizedBox(height: 9),
                _box(
                  width: 110,
                  height: 13,
                ),
                const SizedBox(height: 9),
                _box(
                  width: 140,
                  height: 11,
                ),
                const SizedBox(height: 14),
                _box(
                  width: double.infinity,
                  height: 11,
                ),
                const SizedBox(height: 9),
                _box(
                  width: 120,
                  height: 11,
                ),
                const Spacer(),
                _box(
                  width: double.infinity,
                  height: 38,
                  radius: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _box({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius:
            BorderRadius.circular(radius),
      ),
    );
  }
}