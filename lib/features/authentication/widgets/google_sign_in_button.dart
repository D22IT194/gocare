import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.text = 'Continue with Google',
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF172033),
          side: const BorderSide(color: Color(0xFFE4E7EC), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const GoogleLogo(size: 22),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF172033),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 24.0});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;
    final Rect rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final double strokeWidth = size.width * 0.22;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    // Red (Top)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -2.35, 1.3, false, paint);

    // Yellow (Left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, -3.92, 1.2, false, paint);

    // Green (Bottom)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.78, 1.4, false, paint);

    // Blue (Right & Bar)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.7, 1.3, false, paint);

    // Fill center bar for Google 'G'
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final RRect barRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - strokeWidth * 0.2, cy - strokeWidth / 2, r * 1.05, strokeWidth),
      Radius.circular(strokeWidth * 0.2),
    );
    canvas.drawRRect(barRRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
