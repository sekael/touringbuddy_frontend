import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:touringbuddy_frontend/components/error_snackbar.dart';
import 'package:touringbuddy_frontend/components/text/button.dart';
import 'package:touringbuddy_frontend/core/config/theme.dart';
import 'package:touringbuddy_frontend/core/logging/app_logger.dart';
import 'package:touringbuddy_frontend/main.dart';
import 'package:touringbuddy_frontend/pages/verify_otp.dart';
import 'package:touringbuddy_frontend/supabase.dart';

class EmailEntryPage extends StatefulWidget {
  const EmailEntryPage({super.key});

  @override
  State<EmailEntryPage> createState() => _EmailEntryPageState();
}

class _EmailEntryPageState extends State<EmailEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _submitting = false;

  static final _emailRegExp = RegExp(
    r"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$",
    caseSensitive: false,
  );

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    rootMessengerKey.currentState?.showSnackBar(
      ErrorSnackbar(message: msg).build(),
    );
  }

  Future<void> _sendLoginCode() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim();
    setState(() => _submitting = true);

    try {
      logger.i('Sending email containing verification code');
      await sendEmailOtp(email);
      if (!mounted) return;

      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => OtpVerifyPage(email: email)));
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError('Error occurred when authenticating: ${e.message}');
    } catch (_) {
      if (!mounted) return;
      _showError('Could not send verification code. Please try again');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(touringBuddySpacings.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: touringBuddySpacings.sm),
                const Text('Enter your email and we’ll send you a login code.'),
                SizedBox(height: touringBuddySpacings.sm),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    hintText: 'you@example.com',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final v = (value ?? '').trim();
                    if (v.isEmpty) return 'Please enter your email';
                    if (!_emailRegExp.hasMatch(v)) return 'Enter a valid email';
                    return null;
                  },
                  onFieldSubmitted: (_) =>
                      _submitting ? null : _sendLoginCode(),
                ),
                SizedBox(height: touringBuddySpacings.md),
                ElevatedButton(
                  onPressed: _submitting ? null : _sendLoginCode,
                  child: ButtonText(
                    buttonText: _submitting ? 'Sending…' : 'Send login code',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
