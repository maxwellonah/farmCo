import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    const List<String> languages = <String>[
      'English',
      'Pidgin (Phase 2)',
      'Hausa (Phase 2)',
      'Yoruba (Phase 2)',
      'Igbo (Phase 2)',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Language Selection')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text('Language can be changed later in settings'),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.8,
                children: languages
                    .map(
                      (String language) => Card(
                        child: Center(
                          child: Text(
                            language,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            FilledButton(
              onPressed: onContinue,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
