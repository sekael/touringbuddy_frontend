import 'package:flutter/material.dart';

class AuthSheetContent extends StatefulWidget {
  const AuthSheetContent({super.key});

  @override
  State<AuthSheetContent> createState() => _AuthSheetContentState();
}

class _AuthSheetContentState extends State<AuthSheetContent> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _useMagicLink = true;

  // TODO: only implement OTP login
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle for swiping
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isSignUp ? 'Create Account' : 'Welcome Back',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _useMagicLink
                ? 'We will send a code to your email.'
                : 'Enter your credentials to continue.',
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          if (!_useMagicLink) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              _handleLogin();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(_isSignUp ? 'Sign Up' : 'Sign In'),
          ),

          TextButton(
            onPressed: () => setState(() => _useMagicLink = !_useMagicLink),
            child: Text(
              _useMagicLink
                  ? 'Use Password instead'
                  : 'Send me a Magic Link instead',
            ),
          ),

          const Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isSignUp
                    ? "Already have an account?"
                    : "Don't have an account?",
              ),
              TextButton(
                onPressed: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(_isSignUp ? 'Login' : 'Create one'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
