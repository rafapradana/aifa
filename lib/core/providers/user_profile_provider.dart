import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import 'auth_provider.dart';

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  UserProfileNotifier(this._supabase) : super(const AsyncValue.loading());

  final SupabaseClient _supabase;

  Future<void> loadUserProfile() async {
    state = const AsyncValue.loading();
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final response =
          await _supabase
              .from('user_profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();

      if (response != null) {
        final profile = UserProfile.fromJson(response);
        state = AsyncValue.data(profile);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createUserProfile({
    required double monthlyIncome,
    String? financialGoal,
    required List<String> spendingCategories,
    required String userType,
    String? fullName,
    String currency = 'USD',
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get full name from parameter or user metadata
      final userName =
          fullName ??
          user.userMetadata?['full_name'] as String? ??
          user.email?.split('@').first;

      final profile = UserProfile(
        id: user.id,
        email: user.email,
        fullName: userName,
        monthlyIncome: monthlyIncome,
        financialGoal: financialGoal,
        spendingCategories: spendingCategories,
        userType: userType,
        currency: currency,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _supabase.from('user_profiles').insert(profile.toJson());
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    state = const AsyncValue.loading();
    try {
      final updatedProfile = profile.copyWith(updatedAt: DateTime.now());

      await _supabase
          .from('user_profiles')
          .update(updatedProfile.toJson())
          .eq('id', profile.id);

      state = AsyncValue.data(updatedProfile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearProfile() {
    state = const AsyncValue.data(null);
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
      final supabase = ref.watch(supabaseClientProvider);
      final notifier = UserProfileNotifier(supabase);

      // Load profile when auth state changes
      ref.listen(authStateProvider, (previous, next) {
        next.whenData((authState) {
          if (authState.session?.user != null) {
            notifier.loadUserProfile();
          } else {
            notifier.clearProfile();
          }
        });
      });

      return notifier;
    });
