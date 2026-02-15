import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:touringbuddy_frontend/components/error_snackbar.dart';
import 'package:touringbuddy_frontend/core/exceptions/no_user_profile_exception.dart';
import 'package:touringbuddy_frontend/core/exceptions/unauthenticated_user_exception.dart';
import 'package:touringbuddy_frontend/core/logging/app_logger.dart';
import 'package:touringbuddy_frontend/features/user/user_profile_domain.dart';
import 'package:touringbuddy_frontend/features/user/user_profile_repository.dart';
import 'package:touringbuddy_frontend/main.dart';
import 'package:touringbuddy_frontend/supabase.dart';

class UserService extends ChangeNotifier {
  UserService({required UserProfileRepository userProfileRepository})
    : _userProfileRepository = userProfileRepository;

  final UserProfileRepository _userProfileRepository;

  UserProfileData? _profileData;
  bool _loadingProfile = false;
  bool _signingOut = false;

  // Getters
  UserProfileData? get profileData => _profileData;
  bool get loadingProfile => _loadingProfile;
  bool get signingOut => _signingOut;
  bool get isLoggedIn {
    try {
      final _ = getCurrentUser();
      return true;
    } catch (_) {
      return false;
    }
  }

  bool get isAnonymous {
    User user;

    try {
      user = getCurrentUser();
    } catch (_) {
      return false;
    }

    // Newer SDKs
    final dynamic maybe = (user as dynamic);
    if (maybe.isAnonymous is bool) return maybe.isAnonymous as bool;

    // Fallback (works because JWT has is_anonymous; many SDKs also store provider in app_metadata)
    final provider = (user.appMetadata['provider'] ?? '').toString();
    return provider == 'anonymous';
  }

  bool get isPermanentUser => isLoggedIn && !isAnonymous;

  // Initialize after app startup
  Future<void> init() async {
    await refreshProfile();
  }

  UserProfileData getLoggedInUserProfile() {
    if (profileData == null) {
      throw NoUserProfileException(userId: getCurrentUser().id);
    }
    return profileData!;
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
      _profileData = await _userProfileRepository.getUserById(user.id);
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
        await _userProfileRepository.upsertMyUser(updatedProfile);
      } else {
        await _userProfileRepository.updateMyUser(updatedProfile);
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

  Future<void> loginWithPassword(String email, String password) async {
    await signInWithPassword(email, password);
    await refreshProfile();
    notifyListeners();
  }

  Future<void> signUpWithEmailPassword(String email, String password) async {
    final res = await signUpWithPassword(email, password);
    if (res.session == null) {
      notifyListeners();
      return;
    }

    await refreshProfile();
    notifyListeners();
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
