import 'package:flutter/material.dart';
import '../../models/conversation.dart';
import '../../models/message.dart';
import '../../services/message_service.dart';
import '../../services/conversation_service.dart';
import '../../services/api_service.dart';
import '../../services/block_service.dart';

class ChatPage extends StatefulWidget {
  // Support both old and new parameters for backward compatibility
  final String? nama; // Old parameter (for hardcoded chat)
  final int? conversationId; // New parameter
  final ConversationParticipant? otherParticipant; // New parameter

  const ChatPage({
    super.key,
    this.nama,
    this.conversationId,
    this.otherParticipant,
  }) : assert(
          (nama != null) || (conversationId != null && otherParticipant != null),
          'Either nama or (conversationId + otherParticipant) must be provided',
        );

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MessageService _messageService = MessageService(ApiService());
  final ConversationService _conversationService = ConversationService(ApiService());
  final BlockService _blockService = BlockService(ApiService());
  
  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isBlocked = false;
  String? _blockMessage;

  // Check if using new API or old hardcoded mode
  bool get _isApiMode => widget.conversationId != null;

  @override
  void initState() {
    super.initState();
    if (_isApiMode) {
      _checkBlockStatus();
      _loadMessages();
      _markAsRead();
      _scrollController.addListener(_onScroll);
    } else {
      // Old hardcoded messages for backward compatibility
      _messages = [
        Message(
          id: 1,
          conversationId: 0,
          senderId: 999,
          senderName: 'Other',
          content: 'Halo juga! Ada yang bisa dibantu?',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        Message(
          id: 2,
          conversationId: 0,
          senderId: 0,
          senderName: 'Me',
          content: 'Halo, ${DateTime.now().hour}:00!',
          isRead: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkBlockStatus() async {
    if (!_isApiMode) return;
    try {
      final blockService = BlockService(ApiService());
      final status = await blockService.checkBlockStatus(widget.otherParticipant!.id);
      if (mounted) {
        setState(() {
          if (status['isBlockedByMe'] == true) {
            _isBlocked = true;
            _blockMessage = 'Anda telah memblokir pengguna ini. Tidak bisa mengirim pesan.';
          } else if (status['isBlockingMe'] == true) {
            _isBlocked = true;
            _blockMessage = 'Pengguna ini telah memblokir Anda. Tidak bisa mengirim pesan.';
          } else {
            _isBlocked = false;
            _blockMessage = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBlocked = false;
          _blockMessage = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore && _isApiMode) {
        _loadMoreMessages();
      }
    }
  }

  Future<void> _loadMessages() async {
    if (!_isApiMode) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final messages = await _messageService.getMessages(
        widget.conversationId!,
        page: 1,
        limit: 50,
      );
      
      if (mounted) {
        setState(() {
          _messages = messages.reversed.toList(); // Reverse to show newest at bottom
          _isLoading = false;
          _currentPage = 1;
        });
        
        // Scroll to bottom after loading
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat pesan: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreMessages() async {
    if (!_isApiMode || _isLoadingMore || !_hasMore) return;
    
    setState(() => _isLoadingMore = true);

    try {
      final oldestMessageId = _messages.first.id;
      final messages = await _messageService.getMessages(
        widget.conversationId!,
        page: _currentPage + 1,
        limit: 50,
        beforeMessageId: oldestMessageId,
      );
      
      if (mounted) {
        setState(() {
          _messages.insertAll(0, messages.reversed.toList());
          _isLoadingMore = false;
          _currentPage++;
          _hasMore = messages.isNotEmpty;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat pesan lama: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead() async {
    if (!_isApiMode) return;
    
    try {
      await _conversationService.markAsRead(widget.conversationId!);
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_isBlocked) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (_isApiMode) {
      // API mode
      setState(() => _isSending = true);
      _controller.clear();

      try {
        final message = await _messageService.sendMessage(
          widget.conversationId!,
          text,
        );
        
        if (mounted) {
          setState(() {
            _messages.add(message);
            _isSending = false;
          });
          
          // Scroll to bottom
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSending = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengirim pesan: $e'),
              backgroundColor: Colors.red,
            ),
          );
          // Restore text if failed
          _controller.text = text;
        }
      }
    } else {
      // Old hardcoded mode
      setState(() {
        _messages.add(Message(
          id: _messages.length + 1,
          conversationId: 0,
          senderId: 0,
          senderName: 'Me',
          content: text,
          isRead: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _isApiMode 
        ? widget.otherParticipant!.name 
        : widget.nama!;
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (_isApiMode && widget.otherParticipant!.fotoProfil != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    '${ApiService.baseUrl}${widget.otherParticipant!.fotoProfil}',
                  ),
                ),
              )
            else if (_isApiMode)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  radius: 18,
                  child: Text(
                    displayName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            Expanded(
              child: Text(
                displayName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
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
              onPressed: _loadMessages,
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

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Belum ada pesan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kirim pesan pertama Anda!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoadingMore && index == 0) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final messageIndex = _isLoadingMore ? index - 1 : index;
        final message = _messages[messageIndex];
        final isMe = _isApiMode 
            ? message.senderId != widget.otherParticipant!.id
            : message.senderId == 0;
        
        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isMe ? Colors.red[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  message.getFormattedTime(),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    if (_isBlocked) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey.shade100,
        child: Row(
          children: [
            const Icon(Icons.block, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _blockMessage ?? 'Tidak bisa mengirim pesan',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ketik pesan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              enabled: !_isSending,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: _isSending ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
