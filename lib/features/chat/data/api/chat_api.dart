import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/network/api_client.dart';
import 'package:medical_follow_up_app/core/network/api_providers.dart';
import 'package:medical_follow_up_app/core/errors/error_mapper.dart';
import 'package:medical_follow_up_app/features/chat/data/models/chat_message_model/chat_message.dart';

final chatApiProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChatApi(apiClient);
});

class ChatApi {
  final ApiClient _client;

  ChatApi(this._client);

  Future<List<ChatMessage>> getHistory(String otherUserId, String currentUserId) async {
    try {
      final res = await _client.dio.get('/api/chat/history/$otherUserId');
      final List data = res.data;
      return data.map((json) => ChatMessage.fromJson(json, currentUserId)).toList();
    } on DioException catch (e) {
      throw mapDioError(e, fallback: 'Failed to fetch messages');
    } catch (_) {
      throw Exception('Failed to fetch messages');
    }
  }

  Future<ChatMessage> sendMessage(String receiverId, String content, String currentUserId) async {
    try {
      final res = await _client.dio.post('/api/chat', data: {
        'receiverId': receiverId,
        'content': content,
      });
      return ChatMessage.fromJson(res.data, currentUserId);
    } on DioException catch (e) {
      throw mapDioError(e, fallback: 'Failed to send message');
    } catch (_) {
      throw Exception('Failed to send message');
    }
  }
}
