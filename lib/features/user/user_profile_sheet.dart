import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:touringbuddy_frontend/components/error_snackbar.dart';
import 'package:touringbuddy_frontend/core/logging/app_logger.dart';
import 'package:touringbuddy_frontend/features/user/user_service.dart';
import 'package:touringbuddy_frontend/main.dart';

enum _AuthStep { login, signup, upgradeAnon, checkEmail }

class AuthSheetContent extends StatefulWidget {
  const AuthSheetContent({super.key});

  @override
  State<AuthSheetContent> createState() => _AuthSheetContentState();
}

class _AuthSheetContentState extends State<AuthSheetContent> {
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  _AuthStep _step = _AuthStep.login;
  bool _submitting = false;
  bool _obscure = true;

  static final _emailRegExp = RegExp(
    r"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$",
    caseSensitive: false,
  );

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  String get _email => _emailCtrl.text.trim();
  String get _password => _passwordCtrl.text;

  Future<void> _upgradeAnonymous() async {
    if (_submitting) return;

    final valid = _signupFormKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => _submitting = true);

    try {
      final userService = context.read<UserService>();
      if (!userService.isAnonymous) {
        _showError('You are not an anonymous user.');
        return;
      }

      logger.i('Upgrading anonymous user: link email first');

      // 1) Link email identity to the current anonymous user
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(email: _email),
      );

      // 2) Set password
      // In many setups, password can only be set AFTER the email is verified.
      // So this may throw an AuthException telling you to verify first.
      try {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: _password),
        );

        await userService.refreshProfile();
        if (mounted) Navigator.of(context).pop();
      } on AuthException catch (e) {
        // Typical when email confirmation / verification is required before setting password
        logger.w('Password update requires verification: ${e.message}');
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Check your email to confirm. Then come back to set your password.',
            ),
          ),
        );

        setState(() => _step = _AuthStep.checkEmail);
      }
    } on AuthException catch (e) {
      if (!mounted) return;

      final msg = e.message.toLowerCase();
      if (msg.contains('already registered') ||
          msg.contains('user already exists') ||
          msg.contains('duplicate')) {
        _showError('That email already has an account. Log in instead.');
        setState(() => _step = _AuthStep.login);
      } else {
        _showError('Could not upgrade account: ${e.message}');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _buildCheckEmailStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Confirm your email'),
        const SizedBox(height: 12),
        Text('We sent a confirmation link to:\n$_email'),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _submitting
              ? null
              : () => setState(() => _step = _AuthStep.upgradeAnon),
          child: const Text('I confirmed — set password'),
        ),
      ],
    );
  }

  void _showError(String msg) {
    rootMessengerKey.currentState?.showSnackBar(
      ErrorSnackbar(message: msg).build(),
    );
  }

  Future<void> _login() async {
    if (_submitting) return;

    final valid = _loginFormKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => _submitting = true);

    try {
      logger.i('Signing in with password for $_email');
      context.read<UserService>().loginWithPassword(_email, _password);
      logger.i('Successfully signed in user $_email');
      if (mounted) Navigator.of(context).pop();
    } on AuthException catch (e) {
      logger.w('Login failed: ${e.message}');

      final msg = e.message.toLowerCase();
      if (msg.contains('email not confirmed') ||
          msg.contains('not confirmed')) {
        _showError('Please confirm your email address before logging in.');
      } else {
        _showError('Invalid email or password');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _signup() async {
    if (_submitting) return;

    final valid = _signupFormKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => _submitting = true);

    try {
      final us = context.read<UserService>();
      logger.i('Signing up with email and password for $_email');
      await us.signUpWithEmailPassword(_email, _password);

      if (us.isLoggedIn) {
        if (mounted) Navigator.of(context).pop();
      } else {
        rootMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Account created. Please confirm your email.'),
          ),
        );
        setState(() {
          _step = _AuthStep.login;
        });
      }
    } on AuthException catch (e) {
      final msgLower = e.message.toLowerCase();
      if (msgLower.contains('already registered') ||
          msgLower.contains('user already exists')) {
        _showError('An account with this email already exists. Please log in.');
        setState(() => _step = _AuthStep.login);
      } else {
        _showError('Could not create account: ${e.message}');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Something went wrong: $e');
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
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    String label = 'Password',
  }) {
    return TextFormField(
      controller: controller,
      autofillHints: const [AutofillHints.password],
      obscureText: _obscure,
      textInputAction: TextInputAction.done,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          tooltip: _obscure ? 'Show' : 'Hide',
          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      validator: (value) {
        final v = value ?? '';
        if (v.isEmpty) return 'Please enter a password';
        if (v.length < 8) return 'Password must be at least 8 characters';
        return null;
      },
      onFieldSubmitted: (_) {
        if (_step == _AuthStep.login) {
          _login();
        } else {
          _signup();
        }
      },
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
          const SizedBox(height: 12),
          _passwordField(controller: _passwordCtrl),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _login,
              child: Text(_submitting ? 'Logging in…' : 'Log in'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _submitting
                ? null
                : () {
                    setState(() {
                      _step = _AuthStep.signup;
                      _confirmPasswordCtrl.clear();
                    });
                  },
            child: const Text("Don’t have an account? Create one"),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupStep(BuildContext context) {
    return Form(
      key: _signupFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back to login',
                onPressed: _submitting
                    ? null
                    : () => setState(() => _step = _AuthStep.login),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              const Expanded(child: Text('Create account')),
            ],
          ),
          const SizedBox(height: 8),
          _emailField(),
          const SizedBox(height: 12),
          _passwordField(controller: _passwordCtrl, label: 'New password'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmPasswordCtrl,
            obscureText: _obscure,
            decoration: const InputDecoration(
              labelText: 'Confirm password',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              final v = value ?? '';
              if (v.isEmpty) return 'Please confirm your password';
              if (v != _passwordCtrl.text) return 'Passwords do not match';
              return null;
            },
            onFieldSubmitted: (_) => _signup(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _signup,
              child: Text(_submitting ? 'Creating…' : 'Create account'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeAnonStep(BuildContext context) {
    return Form(
      key: _signupFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Create your account'),
          const SizedBox(height: 8),
          const Text(
            'You are currently using a guest account. Add email + password to keep your data.',
          ),
          const SizedBox(height: 16),
          _emailField(),
          const SizedBox(height: 12),
          _passwordField(controller: _passwordCtrl, label: 'New password'),
          const SizedBox(height: 12),
          // confirm password as you already have
          TextFormField(
            controller: _confirmPasswordCtrl,
            obscureText: _obscure,
            decoration: const InputDecoration(
              labelText: 'Confirm password',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              final v = value ?? '';
              if (v.isEmpty) return 'Please confirm your password';
              if (v != _passwordCtrl.text) return 'Passwords do not match';
              return null;
            },
            onFieldSubmitted: (_) => _upgradeAnonymous(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _upgradeAnonymous,
              child: Text(_submitting ? 'Saving…' : 'Save account'),
            ),
          ),

          // Optional: allow switching to login (this will lose the anonymous user id/session)
          TextButton(
            onPressed: _submitting
                ? null
                : () {
                    setState(() => _step = _AuthStep.login);
                  },
            child: const Text('I already have an account (log in instead)'),
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

    // If user is anonymous, force upgrade flow
    if (userService.isAnonymous) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: switch (_step) {
          _AuthStep.login => _buildLoginStep(context),
          _AuthStep.checkEmail => _buildCheckEmailStep(),
          _ => _buildUpgradeAnonStep(context),
        },
      );
    }

    // Non-authenticated (or signed out) users
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: (_step == _AuthStep.login)
          ? _buildLoginStep(context)
          : _buildSignupStep(context),
    );
  }
}
