# Dokumentasi API Messaging System untuk Flutter

**Tanggal**: 24 Desember 2025  
**Status**: ✅ **IMPLEMENTED & TESTED**  
**Backend Version**: 1.0.0

---

## 📋 DAFTAR ISI

1. [Overview](#overview)
2. [Base URL & Authentication](#base-url--authentication)
3. [API Endpoints](#api-endpoints)
   - [User Search](#1-search-users)
   - [Get/Create Conversation](#2-get-or-create-conversation)
   - [Get Conversations List](#3-get-conversations-list)
   - [Get Messages](#4-get-messages)
   - [Send Message](#5-send-message)
   - [Mark Messages as Read](#6-mark-messages-as-read)
   - [Block User](#7-block-user)
   - [Unblock User](#8-unblock-user)
   - [Get Blocked Users](#9-get-blocked-users)
   - [Check Block Status](#10-check-block-status)
4. [Flutter Integration](#flutter-integration)
5. [Error Handling](#error-handling)
6. [Testing Checklist](#testing-checklist)

---

## OVERVIEW

Backend menyediakan **10 endpoints** untuk sistem messaging real-time dengan fitur:
- ✅ Search users (dengan filter blocked users)
- ✅ Create/Get conversations
- ✅ Send & receive messages
- ✅ Mark messages as read
- ✅ Block/Unblock users
- ✅ Pagination support
- ✅ Complete authorization checks

---

## BASE URL & AUTHENTICATION

### Base URL
```
Development: http://localhost:3030/api
Production: https://api.mygeri.com/api (sesuaikan)
```

### Authentication
Semua endpoint memerlukan **JWT Bearer Token**:

```dart
headers: {
  'Authorization': 'Bearer $accessToken',
  'Content-Type': 'application/json'
}
```

---

## API ENDPOINTS

### 1. Search Users

**Endpoint**: `GET /users/search`

**Query Parameters**:
- `q` (required): String - keyword pencarian
- `limit` (optional): Number - max results (default: 20)
- `excludeSelf` (optional): Boolean - exclude current user (default: true)

**Catatan**: API ini **otomatis exclude blocked users** (2 arah)

**Request Example**:
```bash
GET /api/users/search?q=rina&limit=10
Authorization: Bearer {accessToken}
```

**Response Success** (200):
```json
{
  "success": true,
  "data": [
    {
      "id": 5,
      "uuid": "16409e46-5ed8-4b56-bc03-fdbf9244a833",
      "username": "rinawati",
      "name": "RIna Wati",
      "fotoProfil": "/uploads/profiles/profil-5-xxx.jpg",
      "email": "rina.wati@example.com",
      "bio": null
    }
  ],
  "meta": {
    "total": 1,
    "limit": 10
  }
}
```

**Response Error** (400):
```json
{
  "success": false,
  "message": "Query parameter 'q' is required"
}
```

**Flutter Code**:
```dart
class MessageService {
  static const String baseUrl = 'http://localhost:3030/api';
  
  Future<List<UserSearchResult>> searchUsers(String query, {int limit = 20}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    
    final response = await http.get(
      Uri.parse('$baseUrl/users/search?q=$query&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List)
          .map((user) => UserSearchResult.fromJson(user))
          .toList();
    } else {
      throw Exception('Failed to search users');
    }
  }
}

class UserSearchResult {
  final int id;
  final String uuid;
  final String username;
  final String name;
  final String? fotoProfil;
  final String? bio;
  
  UserSearchResult({
    required this.id,
    required this.uuid,
    required this.username,
    required this.name,
    this.fotoProfil,
    this.bio,
  });
  
  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['id'],
      uuid: json['uuid'],
      username: json['username'],
      name: json['name'],
      fotoProfil: json['fotoProfil'],
      bio: json['bio'],
    );
  }
}
```

---

### 2. Get or Create Conversation

**Endpoint**: `POST /conversations/get-or-create`

**Purpose**: Mendapatkan conversation yang sudah ada ATAU membuat baru

**Request Body**:
```json
{
  "participantId": 5
}
```

**Response Success** (200 - existing / 201 - new):
```json
{
  "success": true,
  "data": {
    "id": 1,
    "uuid": "a0d92957-ab81-4acd-b412-01dfaec67f75",
    "participants": [
      {
        "id": 1,
        "uuid": "9d7a8574-5da6-441b-b76a-284db4d49d0c",
        "username": "admin",
        "name": "Admin",
        "fotoProfil": null
      },
      {
        "id": 5,
        "uuid": "16409e46-5ed8-4b56-bc03-fdbf9244a833",
        "username": "rinawati",
        "name": "RIna Wati",
        "fotoProfil": "/uploads/profiles/profil-5-xxx.jpg"
      }
    ],
    "lastMessage": null,
    "unreadCount": 0,
    "createdAt": "2025-12-24T05:49:12.191Z",
    "updatedAt": "2025-12-24T05:49:12.191Z"
  },
  "meta": {
    "isNew": true
  }
}
```

**Response Error** (400):
```json
{
  "success": false,
  "message": "Cannot create conversation with blocked user"
}
```

**Flutter Code**:
```dart
Future<Conversation> getOrCreateConversation(int participantId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  
  final response = await http.post(
    Uri.parse('$baseUrl/conversations/get-or-create'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'participantId': participantId,
    }),
  );
  
  if (response.statusCode == 200 || response.statusCode == 201) {
    final data = json.decode(response.body);
    return Conversation.fromJson(data['data']);
  } else {
    throw Exception('Failed to get or create conversation');
  }
}

class Conversation {
  final int id;
  final String uuid;
  final List<Participant> participants;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Conversation({
    required this.id,
    required this.uuid,
    required this.participants,
    this.lastMessage,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      uuid: json['uuid'],
      participants: (json['participants'] as List)
          .map((p) => Participant.fromJson(p))
          .toList(),
      lastMessage: json['lastMessage'] != null 
          ? Message.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class Participant {
  final int id;
  final String uuid;
  final String username;
  final String name;
  final String? fotoProfil;
  
  Participant({
    required this.id,
    required this.uuid,
    required this.username,
    required this.name,
    this.fotoProfil,
  });
  
  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      uuid: json['uuid'],
      username: json['username'],
      name: json['name'],
      fotoProfil: json['fotoProfil'],
    );
  }
}
```

---

### 3. Get Conversations List

**Endpoint**: `GET /conversations`

**Query Parameters**:
- `page` (optional): Number - page number (default: 1)
- `limit` (optional): Number - items per page (default: 20)

**Response Success** (200):
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "uuid": "a0d92957-ab81-4acd-b412-01dfaec67f75",
      "otherParticipant": {
        "id": 5,
        "uuid": "16409e46-5ed8-4b56-bc03-fdbf9244a833",
        "username": "rinawati",
        "name": "RIna Wati",
        "fotoProfil": "/uploads/profiles/profil-5-xxx.jpg"
      },
      "lastMessage": {
        "id": 3,
        "senderId": 1,
        "senderName": "Admin",
        "content": "Ada agenda rapat minggu depan?",
        "createdAt": "2025-12-24T05:50:06.326Z",
        "isRead": false
      },
      "unreadCount": 0,
      "updatedAt": "2025-12-24T05:50:06.325Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 1,
    "hasMore": false
  }
}
```

**Flutter Code**:
```dart
Future<ConversationList> getConversations({int page = 1, int limit = 20}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  
  final response = await http.get(
    Uri.parse('$baseUrl/conversations?page=$page&limit=$limit'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return ConversationList.fromJson(data);
  } else {
    throw Exception('Failed to load conversations');
  }
}

class ConversationList {
  final List<ConversationItem> conversations;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;
  
  ConversationList({
    required this.conversations,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });
  
  factory ConversationList.fromJson(Map<String, dynamic> json) {
    return ConversationList(
      conversations: (json['data'] as List)
          .map((c) => ConversationItem.fromJson(c))
          .toList(),
      page: json['meta']['page'],
      limit: json['meta']['limit'],
      total: json['meta']['total'],
      hasMore: json['meta']['hasMore'],
    );
  }
}

class ConversationItem {
  final int id;
  final String uuid;
  final Participant otherParticipant;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;
  
  ConversationItem({
    required this.id,
    required this.uuid,
    required this.otherParticipant,
    this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
  });
  
  factory ConversationItem.fromJson(Map<String, dynamic> json) {
    return ConversationItem(
      id: json['id'],
      uuid: json['uuid'],
      otherParticipant: Participant.fromJson(json['otherParticipant']),
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
```

---

### 4. Get Messages

**Endpoint**: `GET /conversations/:conversationId/messages`

**Query Parameters**:
- `page` (optional): Number - page number (default: 1)
- `limit` (optional): Number - messages per page (default: 50)
- `before` (optional): String - message ID for cursor pagination

**Response Success** (200):
```json
{
  "success": true,
  "data": [
    {
      "id": 3,
      "conversationId": 1,
      "senderId": 1,
      "senderName": "Admin",
      "senderPhoto": null,
      "content": "Ada agenda rapat minggu depan?",
      "isRead": false,
      "createdAt": "2025-12-24T05:50:06.326Z",
      "updatedAt": "2025-12-24T05:50:06.326Z"
    },
    {
      "id": 2,
      "conversationId": 1,
      "senderId": 1,
      "senderName": "Admin",
      "senderPhoto": null,
      "content": "Bagaimana kabar kegiatan di kelurahan?",
      "isRead": false,
      "createdAt": "2025-12-24T05:50:05.245Z",
      "updatedAt": "2025-12-24T05:50:05.245Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 50,
    "total": 3,
    "hasMore": false
  }
}
```

**Flutter Code**:
```dart
Future<MessageList> getMessages(int conversationId, {int page = 1, int limit = 50}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  
  final response = await http.get(
    Uri.parse('$baseUrl/conversations/$conversationId/messages?page=$page&limit=$limit'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return MessageList.fromJson(data);
  } else {
    throw Exception('Failed to load messages');
  }
}

class Message {
  final int id;
  final int conversationId;
  final int? senderId;
  final String? senderName;
  final String? senderPhoto;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Message({
    required this.id,
    required this.conversationId,
    this.senderId,
    this.senderName,
    this.senderPhoto,
    required this.content,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderPhoto: json['senderPhoto'],
      content: json['content'],
      isRead: json['isRead'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class MessageList {
  final List<Message> messages;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;
  
  MessageList({
    required this.messages,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });
  
  factory MessageList.fromJson(Map<String, dynamic> json) {
    return MessageList(
      messages: (json['data'] as List)
          .map((m) => Message.fromJson(m))
          .toList(),
      page: json['meta']['page'],
      limit: json['meta']['limit'],
      total: json['meta']['total'],
      hasMore: json['meta']['hasMore'],
    );
  }
}
```

---

### 5. Send Message

**Endpoint**: `POST /conversations/:conversationId/messages`

**Request Body**:
```json
{
  "content": "Halo, apa kabar?"
}
```

**Validation**:
- Content: Required, min 1 char, max 5000 chars

**Response Success** (201):
```json
{
  "success": true,
  "data": {
    "id": 1,
    "conversationId": 1,
    "senderId": 1,
    "senderName": "Admin",
    "senderPhoto": null,
    "content": "Halo, apa kabar?",
    "isRead": false,
    "createdAt": "2025-12-24T05:49:52.215Z",
    "updatedAt": "2025-12-24T05:49:52.215Z"
  },
  "message": "Message sent successfully"
}
```

**Response Error** (400):
```json
{
  "success": false,
  "message": "Cannot send message to blocked user"
}
```

**Flutter Code**:
```dart
Future<Message> sendMessage(int conversationId, String content) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  
  final response = await http.post(
    Uri.parse('$baseUrl/conversations/$conversationId/messages'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'content': content,
    }),
  );
  
  if (response.statusCode == 201) {
    final data = json.decode(response.body);
    return Message.fromJson(data['data']);
  } else {
    throw Exception('Failed to send message');
  }
}
```

---

### 6. Mark Messages as Read

**Endpoint**: `PUT /conversations/:conversationId/read`

**Purpose**: Menandai semua pesan dalam conversation sebagai sudah dibaca

**Response Success** (200):
```json
{
  "success": true,
  "message": "Messages marked as read",
  "data": {
    "updatedCount": 2
  }
}
```

**Flutter Code**:
```dart
Future<int> markMessagesAsRead(int conversationId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  
  final response = await http.put(
    Uri.parse('$baseUrl/conversations/$conversationId/read'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['data']['updatedCount'];
  } else {
    throw Exception('Failed to mark messages as read');
  }
}
```

---

### 7. Block User

**Endpoint**: `POST /users/block`

**Request Body**:
```json
{
  "blockedUserId": 5
}
```

**Response Success** (200):
```json
{
  "success": true,
  "message": "User blocked successfully",
  "data": {
    "id": 1,
    "blockerId": 1,
    "blockedUserId": 5,
    "createdAt": "2025-12-24T05:50:32.203Z"
  }
}
```

**Response Error** (400):
```json
{
  "success": false,
  "message": "Cannot block yourself"
}
```

**Flutter Code**:
```dart
Future<void> blockUser(int userId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  
  final response = await http.post(
    Uri.parse('$baseUrl/users/block'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'blockedUserId': userId,
    }),
  );
  
  if (response.statusCode != 200) {
    throw Exception('Failed to block user');
  }
}
```

---

### 8. Unblock User

**Endpoint**: `DELETE /users/block/:blockedUserId`

**Response Success** (200):
```json
{
  "success": true,
  "message": "User unblocked successfully"
}
```

**Flutter Code**:
```dart
Future<void> unblockUser(int userId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  
  final response = await http.delete(
    Uri.parse('$baseUrl/users/block/$userId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode != 200) {
    throw Exception('Failed to unblock user');
  }
}
```

---

### 9. Get Blocked Users

**Endpoint**: `GET /users/blocked`

**Response Success** (200):
```json
{
  "success": true,
  "data": [
    {
      "id": 6,
      "uuid": "7ed11187-5054-44ee-a71a-4ba8986b7aa5",
      "username": "agussetiawan",
      "name": "Agus Setiawan",
      "fotoProfil": null,
      "blockedAt": "2025-12-24T05:50:32.203Z"
    }
  ]
}
```

**Flutter Code**:
```dart
Future<List<BlockedUser>> getBlockedUsers() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  
  final response = await http.get(
    Uri.parse('$baseUrl/users/blocked'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['data'] as List)
        .map((user) => BlockedUser.fromJson(user))
        .toList();
  } else {
    throw Exception('Failed to get blocked users');
  }
}

class BlockedUser {
  final int id;
  final String uuid;
  final String username;
  final String name;
  final String? fotoProfil;
  final DateTime blockedAt;
  
  BlockedUser({
    required this.id,
    required this.uuid,
    required this.username,
    required this.name,
    this.fotoProfil,
    required this.blockedAt,
  });
  
  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      id: json['id'],
      uuid: json['uuid'],
      username: json['username'],
      name: json['name'],
      fotoProfil: json['fotoProfil'],
      blockedAt: DateTime.parse(json['blockedAt']),
    );
  }
}
```

---

### 10. Check Block Status

**Endpoint**: `GET /users/block-status/:userId`

**Response Success** (200):
```json
{
  "success": true,
  "data": {
    "isBlockedByMe": true,
    "isBlockingMe": false
  }
}
```

**Flutter Code**:
```dart
Future<BlockStatus> checkBlockStatus(int userId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  
  final response = await http.get(
    Uri.parse('$baseUrl/users/block-status/$userId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return BlockStatus.fromJson(data['data']);
  } else {
    throw Exception('Failed to check block status');
  }
}

class BlockStatus {
  final bool isBlockedByMe;
  final bool isBlockingMe;
  
  BlockStatus({
    required this.isBlockedByMe,
    required this.isBlockingMe,
  });
  
  factory BlockStatus.fromJson(Map<String, dynamic> json) {
    return BlockStatus(
      isBlockedByMe: json['isBlockedByMe'],
      isBlockingMe: json['isBlockingMe'],
    );
  }
  
  bool get canSendMessage => !isBlockedByMe && !isBlockingMe;
}
```

---

## FLUTTER INTEGRATION

### Complete MessageService Class

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MessageService {
  static const String baseUrl = 'http://localhost:3030/api';
  
  // Search Users
  Future<List<UserSearchResult>> searchUsers(String query, {int limit = 20}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    
    final response = await http.get(
      Uri.parse('$baseUrl/users/search?q=$query&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List)
          .map((user) => UserSearchResult.fromJson(user))
          .toList();
    } else {
      throw Exception('Failed to search users');
    }
  }
  
  // Get or Create Conversation
  Future<Conversation> getOrCreateConversation(int participantId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    
    final response = await http.post(
      Uri.parse('$baseUrl/conversations/get-or-create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'participantId': participantId}),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return Conversation.fromJson(data['data']);
    } else {
      throw Exception('Failed to get or create conversation');
    }
  }
  
  // Get Conversations List
  Future<ConversationList> getConversations({int page = 1, int limit = 20}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    
    final response = await http.get(
      Uri.parse('$baseUrl/conversations?page=$page&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ConversationList.fromJson(data);
    } else {
      throw Exception('Failed to load conversations');
    }
  }
  
  // Get Messages
  Future<MessageList> getMessages(int conversationId, {int page = 1, int limit = 50}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    
    final response = await http.get(
      Uri.parse('$baseUrl/conversations/$conversationId/messages?page=$page&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MessageList.fromJson(data);
    } else {
      throw Exception('Failed to load messages');
    }
  }
  
  // Send Message
  Future<Message> sendMessage(int conversationId, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    
    final response = await http.post(
      Uri.parse('$baseUrl/conversations/$conversationId/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'content': content}),
    );
    
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return Message.fromJson(data['data']);
    } else {
      throw Exception('Failed to send message');
    }
  }
  
  // Mark Messages as Read
  Future<int> markMessagesAsRead(int conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    
    final response = await http.put(
      Uri.parse('$baseUrl/conversations/$conversationId/read'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['updatedCount'];
    } else {
      throw Exception('Failed to mark messages as read');
    }
  }
  
  // Block User
  Future<void> blockUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    
    final response = await http.post(
      Uri.parse('$baseUrl/users/block'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'blockedUserId': userId}),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to block user');
    }
  }
  
  // Unblock User
  Future<void> unblockUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    
    final response = await http.delete(
      Uri.parse('$baseUrl/users/block/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to unblock user');
    }
  }
  
  // Get Blocked Users
  Future<List<BlockedUser>> getBlockedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    
    final response = await http.get(
      Uri.parse('$baseUrl/users/blocked'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List)
          .map((user) => BlockedUser.fromJson(user))
          .toList();
    } else {
      throw Exception('Failed to get blocked users');
    }
  }
  
  // Check Block Status
  Future<BlockStatus> checkBlockStatus(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    
    final response = await http.get(
      Uri.parse('$baseUrl/users/block-status/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return BlockStatus.fromJson(data['data']);
    } else {
      throw Exception('Failed to check block status');
    }
  }
}
```

---

## ERROR HANDLING

### Common Errors

1. **400 Bad Request**
   - Invalid input data
   - Blocked user action
   - Empty query

2. **401 Unauthorized**
   - Missing token
   - Invalid token
   - Expired token

3. **403 Forbidden**
   - Not a participant of conversation
   - Cannot message blocked user

4. **404 Not Found**
   - User not found
   - Conversation not found

**Flutter Error Handling Example**:
```dart
try {
  final conversation = await messageService.getOrCreateConversation(userId);
  // Success
} on Exception catch (e) {
  if (e.toString().contains('blocked')) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tidak Bisa Chat'),
        content: Text('User ini telah diblokir atau memblokir Anda'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  } else {
    // Handle other errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi kesalahan: $e')),
    );
  }
}
```

---

## TESTING CHECKLIST

### Backend Tests ✅
- [x] User search returns correct results
- [x] User search excludes current user
- [x] User search excludes blocked users (2-way)
- [x] Get/Create conversation works
- [x] Cannot create conversation with blocked user
- [x] Get conversations list works
- [x] Get messages works
- [x] Send message works
- [x] Cannot send message to blocked user
- [x] Mark as read works
- [x] Block user works
- [x] Unblock user works
- [x] Get blocked users list works
- [x] Check block status works
- [x] Authorization checks work

### Frontend Tests (TODO)
- [ ] Search users with debouncing
- [ ] Display user detail popup
- [ ] Start conversation from search
- [ ] Block user from popup
- [ ] Blocked user removed from search
- [ ] Send message in chat
- [ ] Display messages correctly
- [ ] Mark messages as read on open
- [ ] Unread count updates
- [ ] Pull to refresh conversations
- [ ] Pagination works

---

## PRODUCTION READY ✅

**Status**: Semua endpoint telah diimplementasikan, ditest, dan berfungsi dengan baik!

**Next Steps untuk Flutter Team**:
1. ✅ Copy semua model classes
2. ✅ Implement MessageService
3. ✅ Integrate dengan UI yang sudah ada
4. ✅ Test E2E flow
5. ✅ Deploy ke production

**Support**:
Jika ada pertanyaan atau issue, silakan hubungi Backend Team.

---

**Dokumen dibuat**: 24 Desember 2025  
**Backend Developer**: AI Assistant  
**Backend Version**: 1.0.0
