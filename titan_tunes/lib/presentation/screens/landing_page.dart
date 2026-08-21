import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  Widget _buildLoadingCard(BuildContext context, bool isDark) {
    final logoAsset = isDark ? 'assets/logos/titan_bleu_tunes.png' : 'assets/logos/titan_orange_tunes.png';

    return Container(
      width: 240,
      height: 430,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Loading',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: Center(
                child: Image.asset(
                  logoAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.music_note, size: 82, color: isDark ? Colors.blue : Colors.orange);
                  },
                ),
              ),
            ),
            const Text(
              'Powered by NITCH-Corp',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0B1F3A), const Color(0xFF102A4A)]
                : [const Color(0xFFFFF3E0), const Color(0xFFFFF8E1)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: _buildLoadingCard(context, isDark),
          ),
        ),
      ),
    );
  }
}
