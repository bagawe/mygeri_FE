import '../models/conversation.dart';
import 'api_service.dart';

class ConversationService {
  final ApiService _apiService;

  ConversationService(this._apiService);

  /// Get or create conversation with a user
  Future<ConversationResponse> getOrCreateConversation(int participantId) async {
    try {
      print('🔍 ConversationService: Getting or creating conversation with user $participantId...');
      
      final response = await _apiService.post(
        '/api/conversations/get-or-create',
        {'participantId': participantId},
        requiresAuth: true,
      );
      
      print('✅ ConversationService: Conversation retrieved/created successfully');
      return ConversationResponse.fromJson(response);
    } catch (e) {
      print('❌ ConversationService: Error getting/creating conversation - $e');
      rethrow;
    }
  }

  /// Get all conversations for current user
  Future<List<Conversation>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('🔍 ConversationService: Getting conversations (page: $page, limit: $limit)...');
      
      final response = await _apiService.get(
        '/api/conversations?page=$page&limit=$limit',
        requiresAuth: true,
      );
      
      final conversations = (response['data'] as List)
          .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
          .toList();
      
      print('✅ ConversationService: ${conversations.length} conversations retrieved');
      return conversations;
    } catch (e) {
      print('❌ ConversationService: Error getting conversations - $e');
      rethrow;
    }
  }

  /// Mark all messages in a conversation as read
  Future<void> markAsRead(int conversationId) async {
    try {
      print('🔍 ConversationService: Marking conversation $conversationId as read...');
      
      await _apiService.put(
        '/api/conversations/$conversationId/read',
        {},
        requiresAuth: true,
      );
      
      print('✅ ConversationService: Conversation marked as read');
    } catch (e) {
      print('❌ ConversationService: Error marking as read - $e');
      rethrow;
    }
  }

  /// Delete a conversation
  Future<void> deleteConversation(int conversationId) async {
    try {
      print('🔍 ConversationService: Deleting conversation $conversationId...');
      
      await _apiService.delete(
        '/api/conversations/$conversationId',
        requiresAuth: true,
      );
      
      print('✅ ConversationService: Conversation deleted');
    } catch (e) {
      print('❌ ConversationService: Error deleting conversation - $e');
      rethrow;
    }
  }
}
