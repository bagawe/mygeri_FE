import '../models/message.dart';
import 'api_service.dart';

class MessageService {
  final ApiService _apiService;

  MessageService(this._apiService);

  /// Get messages for a conversation
  Future<List<Message>> getMessages(
    int conversationId, {
    int page = 1,
    int limit = 50,
    int? beforeMessageId,
  }) async {
    try {
      print('🔍 MessageService: Getting messages for conversation $conversationId...');
      
      String endpoint = '/api/conversations/$conversationId/messages?page=$page&limit=$limit';
      if (beforeMessageId != null) {
        endpoint += '&before=$beforeMessageId';
      }
      
      final response = await _apiService.get(
        endpoint,
        requiresAuth: true,
      );
      
      final messages = (response['data'] as List)
          .map((json) => Message.fromJson(json as Map<String, dynamic>))
          .toList();
      
      print('✅ MessageService: ${messages.length} messages retrieved');
      return messages;
    } catch (e) {
      print('❌ MessageService: Error getting messages - $e');
      rethrow;
    }
  }

  /// Send a message
  Future<Message> sendMessage(int conversationId, String content) async {
    try {
      print('🔍 MessageService: Sending message to conversation $conversationId...');
      
      final response = await _apiService.post(
        '/api/conversations/$conversationId/messages',
        {'content': content},
        requiresAuth: true,
      );
      
      print('✅ MessageService: Message sent successfully');
      return Message.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      print('❌ MessageService: Error sending message - $e');
      rethrow;
    }
  }

  /// Delete a message
  Future<void> deleteMessage(int conversationId, int messageId) async {
    try {
      print('🔍 MessageService: Deleting message $messageId...');
      
      await _apiService.delete(
        '/api/conversations/$conversationId/messages/$messageId',
        requiresAuth: true,
      );
      
      print('✅ MessageService: Message deleted');
    } catch (e) {
      print('❌ MessageService: Error deleting message - $e');
      rethrow;
    }
  }

  /// Edit a message
  Future<Message> editMessage(
    int conversationId,
    int messageId,
    String newContent,
  ) async {
    try {
      print('🔍 MessageService: Editing message $messageId...');
      
      final response = await _apiService.put(
        '/api/conversations/$conversationId/messages/$messageId',
        {'content': newContent},
        requiresAuth: true,
      );
      
      print('✅ MessageService: Message edited successfully');
      return Message.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      print('❌ MessageService: Error editing message - $e');
      rethrow;
    }
  }
}
