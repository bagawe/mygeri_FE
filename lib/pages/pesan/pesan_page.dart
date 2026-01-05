import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'user_search_page.dart';
import '../../services/conversation_service.dart';
import '../../services/api_service.dart';
import '../../models/conversation.dart';

class PesanPage extends StatefulWidget {
  const PesanPage({super.key});

  @override
  State<PesanPage> createState() => _PesanPageState();
}

class _PesanPageState extends State<PesanPage> {
  final ConversationService _conversationService = ConversationService(ApiService());
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final conversations = await _conversationService.getConversations(
        page: 1,
        limit: 50,
      );

      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      print('❌ PesanPage: Error loading conversations: $e');
      print(stack);
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat percakapan: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshConversations() async {
    await _loadConversations();
  }

  void _navigateToUserSearch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserSearchPage(),
      ),
    );

    // Refresh conversations if a new conversation was created
    if (result == true) {
      _loadConversations();
    }
  }

  void _openChat(Conversation conversation) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          conversationId: conversation.id,
          otherParticipant: conversation.otherParticipant,
        ),
      ),
    );

    // Refresh conversations to update unread count
    _loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToUserSearch,
        backgroundColor: Colors.grey[700],
        foregroundColor: Colors.white,
        elevation: 4,
        tooltip: 'Pesan Baru',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadConversations,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Belum ada percakapan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai percakapan baru dengan\nmenekan tombol + di atas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToUserSearch,
              icon: const Icon(Icons.add),
              label: const Text('Mulai Percakapan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshConversations,
      child: ListView.separated(
        itemCount: _conversations.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          indent: 72,
          color: Colors.grey.shade300,
        ),
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          final participant = conversation.otherParticipant;

          return ListTile(
            leading: participant.fotoProfil != null
                ? CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(
                      '${ApiService.baseUrl}${participant.fotoProfil}',
                    ),
                  )
                : CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.red.shade100,
                    child: Text(
                      participant.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
            title: Text(
              participant.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                conversation.getLastMessagePreview(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: conversation.unreadCount > 0
                      ? Colors.black87
                      : Colors.grey.shade600,
                  fontWeight: conversation.unreadCount > 0
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  conversation.getLastMessageTime(),
                  style: TextStyle(
                    fontSize: 12,
                    color: conversation.unreadCount > 0
                        ? Colors.red
                        : Colors.grey.shade600,
                    fontWeight: conversation.unreadCount > 0
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                if (conversation.unreadCount > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      conversation.unreadCount > 99
                          ? '99+'
                          : conversation.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            onTap: () => _openChat(conversation),
          );
        },
      ),
    );
  }
}
