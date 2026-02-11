import 'dart:convert';
import 'api_service.dart';
import '../models/voting.dart';

class VotingService {
  final ApiService _apiService;

  VotingService(this._apiService);

  /// Get active votings for kader
  /// Endpoint: GET /api/voting/active
  Future<List<Voting>> getActiveVotings() async {
    try {
      print('📊 Fetching active votings...');
      
      final response = await _apiService.get('/voting/active');
      
      print('Response status: ${response['statusCode']}');
      
      if (response['success'] == true) {
        final data = response['data'] as List;
        final votings = data.map((json) => Voting.fromJson(json as Map<String, dynamic>)).toList();
        
        print('✅ Got ${votings.length} active votings');
        return votings;
      } else {
        final message = response['message'] ?? 'Failed to get active votings';
        print('❌ Error: $message');
        
        // Handle permission error
        if (message.toString().contains('Forbidden') || 
            message.toString().contains('insufficient privileges')) {
          throw Exception('Anda tidak memiliki akses ke fitur Voting. Silakan hubungi admin.');
        }
        
        throw Exception(message);
      }
    } catch (e) {
      print('❌ Error fetching active votings: $e');
      rethrow;
    }
  }

  /// Get voting detail by ID
  /// Endpoint: GET /api/voting/:id/detail
  Future<Voting> getVotingDetail(int votingId) async {
    try {
      print('📊 Fetching voting detail for ID: $votingId...');
      
      final response = await _apiService.get('/voting/$votingId/detail');
      
      print('Response status: ${response['statusCode']}');
      
      if (response['success'] == true) {
        final voting = Voting.fromJson(response['data'] as Map<String, dynamic>);
        
        print('✅ Got voting detail: ${voting.title}');
        return voting;
      } else {
        final message = response['message'] ?? 'Failed to get voting detail';
        print('❌ Error: $message');
        throw Exception(message);
      }
    } catch (e) {
      print('❌ Error fetching voting detail: $e');
      rethrow;
    }
  }

  /// Submit vote
  /// Endpoint: POST /api/voting/:id/vote
  Future<void> submitVote(int votingId, List<int> selectedOptions) async {
    try {
      print('📤 Submitting vote for voting ID: $votingId');
      print('Selected options: $selectedOptions');
      
      final response = await _apiService.post(
        '/voting/$votingId/vote',
        {
          'selectedOptions': selectedOptions,
        },
      );
      
      print('Response status: ${response['statusCode']}');
      print('Response body: ${json.encode(response)}');
      
      if (response['success'] == true) {
        print('✅ Vote submitted successfully');
      } else {
        final message = response['message'] ?? 'Failed to submit vote';
        print('❌ Error: $message');
        
        // Handle specific errors
        if (message.toString().contains('already voted')) {
          throw Exception('Anda sudah voting pada voting ini');
        } else if (message.toString().contains('deadline')) {
          throw Exception('Voting sudah ditutup');
        } else if (message.toString().contains('one option')) {
          throw Exception('Anda hanya bisa pilih 1 opsi');
        }
        
        throw Exception(message);
      }
    } catch (e) {
      print('❌ Error submitting vote: $e');
      rethrow;
    }
  }

  /// Get voting history
  /// Endpoint: GET /api/voting/my-votes
  Future<List<VotingHistory>> getMyVotingHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('📜 Fetching voting history (page: $page, limit: $limit)...');
      
      // Build query string
      final queryString = 'page=$page&limit=$limit';
      final endpoint = '/voting/my-votes?$queryString';
      
      final response = await _apiService.get(endpoint);
      
      print('Response status: ${response['statusCode']}');
      
      if (response['success'] == true) {
        final data = response['data'] as List;
        final history = data
            .map((json) => VotingHistory.fromJson(json as Map<String, dynamic>))
            .toList();
        
        print('✅ Got ${history.length} voting history items');
        return history;
      } else {
        final message = response['message'] ?? 'Failed to get voting history';
        print('❌ Error: $message');
        throw Exception(message);
      }
    } catch (e) {
      print('❌ Error fetching voting history: $e');
      rethrow;
    }
  }
}
