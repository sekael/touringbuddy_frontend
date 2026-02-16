import 'package:flutter/material.dart';
import 'package:touringbuddy_frontend/components/body_text.dart';
import 'package:touringbuddy_frontend/components/title_text.dart';
import 'package:touringbuddy_frontend/pages/email_entry.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TitleText(titleText: 'Welcome to TouringBuddy'),
                    CenterAlignedBodyText(
                      bodyText:
                          'TouringBuddy helps you plan and coordinate your adventures outdoors.',
                    ),
                    CenterAlignedBodyText(
                      bodyText:
                          'Please sign in to start using TouringBuddy, have fun!',
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EmailEntryPage(),
                            ),
                          );
                        },
                        child: const Text('Sign In'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
