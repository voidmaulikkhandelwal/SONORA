import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final grey = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  'icons/sonora_nobg.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'SONORA',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Version 1.1.0',
                style: TextStyle(fontSize: 16, color: grey),
              ),
              const SizedBox(height: 32),
              Text(
                'Developed by',
                style: TextStyle(fontSize: 14, color: grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'Maulik Khandelwal',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 28),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Text(
                  'SONORA is free software released under the GNU GPL v3. '
                  'It is derived from the open-source Echo Music project, '
                  'whose original copyright and license notices are kept in '
                  'the LICENSE and NOTICE files shipped with the source.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: grey, height: 1.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
