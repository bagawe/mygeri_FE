import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/voting.dart';
import '../../services/voting_service.dart';
import '../../services/api_service.dart';
import 'voting_detail_page.dart';

class VotingPage extends StatefulWidget {
  const VotingPage({super.key});

  @override
  State<VotingPage> createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  final VotingService _votingService = VotingService(ApiService());
  List<Voting> _votings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVotings();
  }

  Future<void> _loadVotings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final votings = await _votingService.getActiveVotings();
      setState(() {
        _votings = votings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Voting', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFE41E26), // Gerindra red
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE41E26)))
          : _error != null
              ? _buildErrorState()
              : _votings.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadVotings,
                      color: const Color(0xFFE41E26),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _votings.length,
                        itemBuilder: (context, index) {
                          final voting = _votings[index];
                          return _buildVotingCard(voting);
                        },
                      ),
                    ),
    );
  }

  Widget _buildVotingCard(Voting voting) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VotingDetailPage(votingId: voting.id),
            ),
          );
          
          // Reload if user voted
          if (result == true) {
            _loadVotings();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      voting.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusBadge(voting),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Question
              Text(
                voting.question,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 16),
              
              // Question Image (if exists)
              if (voting.questionImageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    '${ApiService.baseUrl}${voting.questionImageUrl}',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 50, color: Colors.grey),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Info row
              Row(
                children: [
                  // Voting type
                  Icon(
                    voting.isSingleChoice ? Icons.radio_button_checked : Icons.check_box,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    voting.isSingleChoice ? 'Pilih 1' : 'Pilih Banyak',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Response count
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${voting.totalResponses} voting',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  
                  const Spacer(),
                  
                  // Deadline
                  Icon(
                    voting.isDeadlineClose ? Icons.warning : Icons.access_time,
                    size: 16,
                    color: voting.isDeadlineClose ? Colors.orange : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    voting.deadlineStatus,
                    style: TextStyle(
                      fontSize: 12,
                      color: voting.isDeadlineClose ? Colors.orange : Colors.grey[600],
                      fontWeight: voting.isDeadlineClose ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Action button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VotingDetailPage(votingId: voting.id),
                      ),
                    );
                    
                    if (result == true) {
                      _loadVotings();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: voting.hasVoted ? Colors.green : const Color(0xFFE41E26),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    voting.hasVoted ? 'Lihat Detail' : 'Mulai Voting',
                    style: TextStyle(
                      color: voting.hasVoted ? Colors.green : const Color(0xFFE41E26),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Voting voting) {
    if (voting.hasVoted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 14, color: Colors.green),
            SizedBox(width: 4),
            Text(
              'Sudah Voting',
              style: TextStyle(
                fontSize: 11,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    } else if (voting.isExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_clock, size: 14, color: Colors.red),
            SizedBox(width: 4),
            Text(
              'Ditutup',
              style: TextStyle(
                fontSize: 11,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.ballot, size: 14, color: Colors.orange),
            SizedBox(width: 4),
            Text(
              'Aktif',
              style: TextStyle(
                fontSize: 11,
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.ballot_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak Ada Voting Aktif',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada voting yang tersedia saat ini.\nCek kembali nanti.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _loadVotings,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE41E26)),
                foregroundColor: const Color(0xFFE41E26),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Gagal memuat data voting',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadVotings,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE41E26),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
