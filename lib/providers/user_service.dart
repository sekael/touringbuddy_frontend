import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:touringbuddy_frontend/components/error_snackbar.dart';
import 'package:touringbuddy_frontend/core/exceptions/unauthenticated_user_exception.dart';
import 'package:touringbuddy_frontend/core/logging/app_logger.dart';
import 'package:touringbuddy_frontend/features/user/user_profile_repository.dart';
import 'package:touringbuddy_frontend/main.dart';
import 'package:touringbuddy_frontend/models/user_profile.dart';
import 'package:touringbuddy_frontend/supabase.dart';

class UserService extends ChangeNotifier {
  final UserProfileRepository _repository = UserProfileRepository();

  UserProfileData? _profileData;
  bool _loadingProfile = false;
  bool _signingOut = false;

  // Getters
  UserProfileData? get profileData => _profileData;
  bool get loadingProfile => _loadingProfile;
  bool get signingOut => _signingOut;
  bool get isLoggedIn => Supabase.instance.client.auth.currentSession != null;

  // Initialize after app startup
  Future<void> init() async {
    await refreshProfile();
  }

  // Reload profile of current user from database
  Future<void> refreshProfile() async {
    User user;
    try {
      user = getCurrentUser();
    } on UnauthenticatedUserException catch (e) {
      logger.w(
        'Attempted refreshing profile for a user that is not correctly logged in: ${e.toString()}',
      );
      _profileData = null;
      _loadingProfile = false;
      notifyListeners();
      return;
    }

    _loadingProfile = true;
    notifyListeners();

    try {
      _profileData = await _repository.getUserById(user.id);
      if (_profileData == null) {
        logger.i(
          'User ${user.id} does not have a user profile yet, creating new one',
        );
        UserProfileData newUserProfile = UserProfileData(id: user.id);
        await saveProfileData(newUserProfile, upsert: true);
      }
    } catch (error, stacktrace) {
      logger.e(
        'Failed to load user profile for user ${user.id}',
        error,
        stacktrace,
      );
    } finally {
      logger.i('Successfully retrieved profile data for user ${user.id}');
      _loadingProfile = false;
      notifyListeners();
    }
  }

  // Save profile changes
  Future<void> saveProfileData(
    UserProfileData updatedProfile, {
    bool upsert = false,
  }) async {
    try {
      if (upsert) {
        await _repository.upsertMyUser(updatedProfile);
      } else {
        await _repository.updateMyUser(updatedProfile);
      }
    } on PostgrestException catch (e) {
      logger.e(
        'Failed to save user profile data because of PostgresException: ${e.message}',
      );
      rethrow;
    } finally {
      _profileData = updatedProfile;
      logger.i('Successfully saved profile data for user ${updatedProfile.id}');
      notifyListeners();
    }
  }

  // Centralized sign-out handler
  Future<void> handleSignOut() async {
    if (_signingOut) return;

    _signingOut = true;
    notifyListeners();

    try {
      await signOut();

      // Clear cached profile data
      _profileData = null;
      notifyListeners();
    } on AuthException catch (e, st) {
      logger.e('Authentication error when trying to sign out', e, st);
      rootMessengerKey.currentState?.showSnackBar(
        ErrorSnackbar(
          message: 'An error occurred trying to sign you out',
        ).build(),
      );
    } catch (e, st) {
      logger.e('Unexpected error when trying to sign out', e, st);
      rootMessengerKey.currentState?.showSnackBar(
        ErrorSnackbar(
          message: 'An unexpected error occurred when trying to sign you out',
        ).build(),
      );
    } finally {
      _signingOut = false;
      logger.i('Successfully signed-out user');
      notifyListeners();
    }
  }
}
