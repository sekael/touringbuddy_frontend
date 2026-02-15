import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:touringbuddy_frontend/components/error_snackbar.dart';
import 'package:touringbuddy_frontend/core/logging/app_logger.dart';
import 'package:touringbuddy_frontend/features/user/user_service.dart';
import 'package:touringbuddy_frontend/main.dart';
import 'package:touringbuddy_frontend/supabase.dart';

enum _AuthStep { login, verify }

class AuthSheetContent extends StatefulWidget {
  const AuthSheetContent({super.key});

  @override
  State<AuthSheetContent> createState() => _AuthSheetContentState();
}

class _AuthSheetContentState extends State<AuthSheetContent> {
  _AuthStep _step = _AuthStep.login;
  final _loginFormKey = GlobalKey<FormState>();
  final _verificationFormKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _verificationCodeControl = TextEditingController();
  bool _isValid = false;
  bool _submitting = false;

  // Simple RFC5322-ish email regex (good enough for UI validation)
  static final _emailRegExp = RegExp(
    r"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$",
    caseSensitive: false,
  );

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    final valid = _emailRegExp.hasMatch(_emailCtrl.text.trim());
    if (valid != _isValid) {
      setState(() {
        _isValid = valid;
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _verificationCodeControl.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    rootMessengerKey.currentState?.showSnackBar(
      ErrorSnackbar(message: msg).build(),
    );
  }

  Future<void> _sendLoginCode() async {
    final String email = _emailCtrl.text.trim();
    try {
      logger.i('Sending email containing verification code');
      await sendEmailOtp(email);
      if (!mounted) return;
      logger.i(
        'Successfully sent email with verification code, continuing with verification',
      );
      setState(() {
        _step = _AuthStep.verify;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError('Error occurred when authenticating: ${e.message}');
    } catch (_) {
      if (!mounted) return;
      _showError('Could not send verification code. Please try again');
    }
  }

  Future<void> _verify(String email) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      // Verify OTP verification code
      logger.i('Verifying code');
      final response = await verifyOtp(
        email,
        _verificationCodeControl.text.trim(),
      );
      logger.i('Successfully verified code');

      final session = response.session;
      if (session != null) {
        if (!mounted) return;
        logger.i('Session is now active');
        Navigator.of(context).pop();
      } else {
        if (!mounted) return;
        _verificationCodeControl.clear();
        _showError(
          'We could not log you in because email verification failed.',
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      _verificationCodeControl.clear();
      _showError('Code verification failed: ${e.message}');
    } catch (_) {
      if (!mounted) return;
      _verificationCodeControl.clear();
      _showError('Something went wrong');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _buildProfileView(BuildContext context) {
    final userService = context.watch<UserService>();

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
            child: const Text('Sign out'),
            onPressed: () async {
              await userService.handleSignOut();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      textInputAction: TextInputAction.next,
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
      onFieldSubmitted: (_) {
        _isValid ? () => _sendLoginCode() : null;
      },
    );
  }

  Widget _codeField() {
    return TextField(
      controller: _verificationCodeControl,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 8,
      style: TextStyle(color: Theme.of(context).colorScheme.primary),
      decoration: const InputDecoration(
        labelText: 'Verification code',
        counterText: '',
        border: OutlineInputBorder(),
      ),
      onSubmitted: (_) => _verify(_emailCtrl.text.trim()),
    );
  }

  Widget _buildLoginStep(BuildContext context) {
    return Form(
      key: _loginFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Log in'),
          const SizedBox(height: 16),
          _emailField(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _sendLoginCode,
              child: Text(
                _submitting ? 'Send Login Code' : 'Sending Login Code ...',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyStep(BuildContext context) {
    return Form(
      key: _verificationFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Verify Email Code'),
          const SizedBox(height: 16),
          _codeField(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting
                  ? null
                  : () => _verify(_emailCtrl.text.trim()),
              child: Text(_submitting ? 'Verify Code' : 'Verifying Code ...'),
            ),
          ),
          TextButton(
            onPressed: () {
              sendEmailOtp(_emailCtrl.text.trim())
                  .then(
                    (_) => rootMessengerKey.currentState?.showSnackBar(
                      const SnackBar(content: Text('Code resent')),
                    ),
                  )
                  .catchError(
                    (err) => rootMessengerKey.currentState?.showSnackBar(
                      ErrorSnackbar(
                        message: 'Could not resend code because of error: $err',
                      ).build(),
                    ),
                  );
            },
            child: Text('Resend Code'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();

    if (userService.isPermanentUser) {
      return _buildProfileView(context);
    }

    // Non-authenticated (or signed out) users
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: switch (_step) {
        _AuthStep.login => _buildLoginStep(context),
        _AuthStep.verify => _buildVerifyStep(context),
      },
    );
  }
}
