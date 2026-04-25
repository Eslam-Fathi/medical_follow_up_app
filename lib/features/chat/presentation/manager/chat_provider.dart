import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:medical_follow_up_app/features/chat/data/api/chat_api.dart';
import 'package:medical_follow_up_app/features/chat/data/models/chat_message_model/chat_message.dart';
import 'package:medical_follow_up_app/features/profile/presentation/manager/profile.provider.dart';
import 'package:medical_follow_up_app/features/appointments/presentation/manager/providers/appointments_provider.dart';
import 'package:medical_follow_up_app/features/doctors/presentation/manager/care_team_provider.dart';

/// Provider for a single conversation history, cached by the other user's ID.
/// Uses StateNotifier to maintain compatibility with the project's current setup.
final chatHistoryProvider = StateNotifierProvider.family<ChatHistoryNotifier, AsyncValue<List<ChatMessage>>, String>((ref, otherUserId) {
  final api = ref.watch(chatApiProvider);
  
  // We try to get the profile. If it's not ready yet, we'll have an empty currentUserId.
  // The notifier will re-fetch once the profile finishes loading.
  final profileAsync = ref.watch(profileProvider);
  final currentUserId = profileAsync.value?.user.id ?? '';
  
  return ChatHistoryNotifier(api, currentUserId, otherUserId);
});

class ChatHistoryNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final ChatApi _api;
  final String _currentUserId;
  final String _otherUserId;

  ChatHistoryNotifier(this._api, this._currentUserId, this._otherUserId) 
      : super(const AsyncValue.loading()) {
    if (_currentUserId.isNotEmpty) {
      fetchHistory();
    }
  }

  Future<void> fetchHistory() async {
    state = const AsyncValue.loading();
    try {
      final history = await _api.getHistory(_otherUserId, _currentUserId);
      state = AsyncValue.data(history);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    final previousMessages = state.value ?? [];
    
    // Optimistic Update
    final tempMsg = ChatMessage(
      text: text,
      isFromUser: true,
      timestamp: DateTime.now(),
    );

    state = AsyncValue.data([...previousMessages, tempMsg]);

    try {
      final savedMsg = await _api.sendMessage(_otherUserId, text, _currentUserId);
      
      // Update state with confirmed message from backend
      state = AsyncValue.data([...previousMessages, savedMsg]);
    } catch (e, stack) {
      // Revert on failure
      state = AsyncValue.data(previousMessages);
      rethrow;
    }
  }
}

/// Global manager to handle "warm-up" (pre-fetching) of all chats on login.
final chatWarmUpProvider = Provider((ref) {
  return ChatWarmUpManager(ref);
});

class ChatWarmUpManager {
  final Ref _ref;
  ChatWarmUpManager(this._ref);

  /// Identifies all chat partners and triggers their history fetch in the background.
  Future<void> warmUp() async {
    try {
      final profile = await _ref.read(profileProvider.future);
      final role = profile.user.role;

      List<String> targetUserIds = [];

      if (role == 'DOCTOR') {
        // For doctors, pre-load all patients from their appointments
        final appointments = await _ref.read(doctorAppointmentsProvider.future);
        targetUserIds = appointments.map((a) => a.patient.user.id).where((id) => id.isNotEmpty).toSet().toList();
      } else {
        // For patients, pre-load all doctors in their care team
        final careTeam = _ref.read(careTeamProvider);
        targetUserIds = careTeam.map((d) => d.userId).where((id) => id.isNotEmpty).toSet().toList();
      }

      // Trigger history fetch for each contact in parallel
      for (final id in targetUserIds) {
        if (id.isNotEmpty) {
          _ref.read(chatHistoryProvider(id).notifier).fetchHistory();
        }
      }
    } catch (_) {
      // Warm-up failure is non-critical
    }
  }
}
