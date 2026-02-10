import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:touringbuddy_frontend/components/error_snackbar.dart';
import 'package:touringbuddy_frontend/core/logging/app_logger.dart';
import 'package:touringbuddy_frontend/features/user/user_service.dart';

enum _AuthStep { email, otp, registration }

class AuthSheetContent extends StatefulWidget {
  const AuthSheetContent({super.key});

  @override
  State<AuthSheetContent> createState() => _AuthSheetContentState();
}

class _AuthSheetContentState extends State<AuthSheetContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  _AuthStep _step = _AuthStep.email;
  bool _submitting = false;

  // Your validator regexp (reuse your existing one if you have it)
  // Simple RFC5322-ish email regex (good enough for UI validation)
  static final _emailRegExp = RegExp(
    r"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$",
    caseSensitive: false,
  );

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  bool get _isValidEmail => _emailRegExp.hasMatch(_emailCtrl.text.trim());

  Future<void> _sendLoginCode() async {
    if (_submitting) return;

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => _submitting = true);
    final email = _emailCtrl.text.trim();

    try {
      logger.i('Sending OTP code to $email');

      await Supabase.instance.client.auth.signInWithOtp(email: email);

      if (!mounted) return;
      setState(() => _step = _AuthStep.otp);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorSnackbar(message: 'Could not send code: ${e.message}').build(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorSnackbar(message: 'Something went wrong: $e').build(),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final email = _emailCtrl.text.trim();
    final token = _otpCtrl.text.trim();

    try {
      logger.i('Verifying OTP code for $email');

      final AuthResponse response = await Supabase.instance.client.auth
          .verifyOTP(type: OtpType.email, token: token, email: email);

      final session = response.session;

      if (session == null) {
        _otpCtrl.clear();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          ErrorSnackbar(
            message:
                'We could not log you in because email verification failed.',
          ).build(),
        );
        return;
      }

      // At this point, user is authenticated.
      // Let your UserService refresh profile data (recommended).
      if (!mounted) return;

      await context.read<UserService>().refreshProfile();

      // Close the bottom sheet after success
      if (mounted) Navigator.of(context).pop();
    } on AuthException catch (e) {
      _otpCtrl.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorSnackbar(
          message: 'Code verification failed: ${e.message}',
        ).build(),
      );
    } catch (e) {
      _otpCtrl.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorSnackbar(message: 'Something went wrong: $e').build(),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resendCode() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final email = _emailCtrl.text.trim();

    try {
      await Supabase.instance.client.auth.signInWithOtp(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Code resent')));
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorSnackbar(message: 'Could not resend code: ${e.message}').build(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorSnackbar(message: 'Could not resend code: $e').build(),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _buildProfileView(BuildContext context) {
    final userService = context.watch<UserService>();

    // Adjust these field names to match your UserService model
    final firstName = userService.profileData?.firstName ?? '';
    final lastName = userService.profileData?.lastName ?? '';
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Your profile'),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.badge_outlined),
          title: Text(
            '$firstName $lastName'.trim().isEmpty
                ? '—'
                : '$firstName $lastName',
          ),
          subtitle: const Text('Name'),
        ),
        ListTile(
          leading: const Icon(Icons.email_outlined),
          title: Text(email.isEmpty ? '—' : email),
          subtitle: const Text('Email'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            child: Text('Sign out'),
            onPressed: () async {
              await userService.handleSignOut();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmailStep(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Welcome!'),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.done,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
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
            onFieldSubmitted: (_) => _isValidEmail ? _sendLoginCode() : null,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sendLoginCode,
              child: Text('Send Login Code'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep(BuildContext context) {
    final email = _emailCtrl.text.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Back',
              onPressed: _submitting
                  ? null
                  : () {
                      setState(() {
                        _otpCtrl.clear();
                        _step = _AuthStep.email;
                      });
                    },
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 8),
            const Expanded(child: Text('Verification')),
          ],
        ),
        const SizedBox(height: 8),
        Text('We emailed an 8-digit code to\n$email'),
        const SizedBox(height: 16),
        TextField(
          controller: _otpCtrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 8,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
          decoration: const InputDecoration(
            labelText: 'Verification code',
            counterText: '',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _verifyOtp(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _verifyOtp,
            child: Text('Verify Code'),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _resendCode,
            child: Text('Resend Code'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<UserService>().isLoggedIn;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: isLoggedIn
          ? _buildProfileView(context)
          : (_step == _AuthStep.email
                ? _buildEmailStep(context)
                : _buildOtpStep(context)),
    );
  }
}
