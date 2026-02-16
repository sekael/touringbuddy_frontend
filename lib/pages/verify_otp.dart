import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:touringbuddy_frontend/components/error_snackbar.dart';
import 'package:touringbuddy_frontend/core/logging/app_logger.dart';
import 'package:touringbuddy_frontend/main.dart';
import 'package:touringbuddy_frontend/pages/auth_gate.dart';
import 'package:touringbuddy_frontend/providers/user_service.dart';
import 'package:touringbuddy_frontend/supabase.dart';

class OtpVerifyPage extends StatefulWidget {
  final String email;
  const OtpVerifyPage({super.key, required this.email});

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final _codeCtrl = TextEditingController();
  bool _validating = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    rootMessengerKey.currentState?.showSnackBar(
      ErrorSnackbar(message: msg).build(),
    );
  }

  Future<void> _verify() async {
    if (_validating) return;
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;

    setState(() => _validating = true);

    try {
      logger.i('Verifying code');
      final response = await verifyOtp(widget.email, code);

      final session = response.session;
      if (session != null) {
        if (!mounted) return;

        // Refresh profile and return to the main app
        await context.read<UserService>().refreshProfile();

        // Pop auth flow pages
        if (!mounted) return;
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AuthGate()));
      } else {
        if (!mounted) return;
        _codeCtrl.clear();
        _showError(
          'We could not log you in because email verification failed.',
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      _codeCtrl.clear();
      _showError('Code verification failed: ${e.message}');
    } catch (_) {
      if (!mounted) return;
      _codeCtrl.clear();
      _showError('Something went wrong');
    } finally {
      if (mounted) setState(() => _validating = false);
    }
  }

  Future<void> _resend() async {
    try {
      await sendEmailOtp(widget.email);
      if (!mounted) return;
      rootMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Code resent')),
      );
    } catch (err) {
      if (!mounted) return;
      rootMessengerKey.currentState?.showSnackBar(
        ErrorSnackbar(message: 'Could not resend code: $err').build(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify code')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Enter the code we sent to ${widget.email}.'),
              const SizedBox(height: 16),
              TextField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 8,
                decoration: const InputDecoration(
                  labelText: 'Verification code',
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _verify(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _validating ? null : _verify,
                child: Text(_validating ? 'Verifying…' : 'Verify'),
              ),
              TextButton(
                onPressed: _validating ? null : _resend,
                child: const Text('Resend code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
