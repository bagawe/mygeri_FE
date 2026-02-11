class Voting {
  final int id;
  final String uuid;
  final String title;
  final String question;
  final String? questionImageUrl;
  final String votingType; // 'single' or 'multiple'
  final DateTime deadline;
  final bool isActive;
  final DateTime createdAt;
  final List<VotingOption> options;
  final int totalResponses;
  final bool hasVoted;
  final List<int>? userSelectedOptions;
  final bool isExpired;

  Voting({
    required this.id,
    required this.uuid,
    required this.title,
    required this.question,
    this.questionImageUrl,
    required this.votingType,
    required this.deadline,
    required this.isActive,
    required this.createdAt,
    required this.options,
    required this.totalResponses,
    required this.hasVoted,
    this.userSelectedOptions,
    required this.isExpired,
  });

  factory Voting.fromJson(Map<String, dynamic> json) {
    return Voting(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      question: json['question'] as String? ?? '',
      questionImageUrl: json['questionImageUrl'] as String?,
      votingType: json['votingType'] as String? ?? 'single',
      deadline: DateTime.tryParse(json['deadline'] as String? ?? '') ?? DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      options: (json['options'] as List<dynamic>?)
              ?.map((opt) => VotingOption.fromJson(opt as Map<String, dynamic>))
              .toList() ??
          [],
      totalResponses: json['totalResponses'] as int? ?? 0,
      hasVoted: json['hasVoted'] as bool? ?? false,
      userSelectedOptions: json['userSelectedOptions'] != null
          ? List<int>.from(json['userSelectedOptions'] as List)
          : null,
      isExpired: json['isExpired'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'title': title,
      'question': question,
      'questionImageUrl': questionImageUrl,
      'votingType': votingType,
      'deadline': deadline.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'options': options.map((opt) => opt.toJson()).toList(),
      'totalResponses': totalResponses,
      'hasVoted': hasVoted,
      'userSelectedOptions': userSelectedOptions,
      'isExpired': isExpired,
    };
  }

  // Helper methods
  bool get isSingleChoice => votingType == 'single';
  bool get isMultipleChoice => votingType == 'multiple';
  
  Duration get timeRemaining => deadline.difference(DateTime.now());
  bool get isDeadlineClose => timeRemaining.inHours <= 24 && timeRemaining.inHours > 0;
  
  String get deadlineStatus {
    if (isExpired) return 'Sudah Ditutup';
    
    final remaining = timeRemaining;
    if (remaining.inDays > 0) {
      return '${remaining.inDays} hari lagi';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours} jam lagi';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes} menit lagi';
    } else {
      return 'Segera ditutup';
    }
  }
}

class VotingOption {
  final int id;
  final int? votingId;
  final String optionText;
  final String? optionImageUrl;
  final int orderIndex;
  final int? voteCount;
  final String? percentage;

  VotingOption({
    required this.id,
    this.votingId,
    required this.optionText,
    this.optionImageUrl,
    required this.orderIndex,
    this.voteCount,
    this.percentage,
  });

  factory VotingOption.fromJson(Map<String, dynamic> json) {
    return VotingOption(
      id: json['id'] as int? ?? 0,
      votingId: json['votingId'] as int?,
      optionText: json['optionText'] as String? ?? '',
      optionImageUrl: json['optionImageUrl'] as String?,
      orderIndex: json['orderIndex'] as int? ?? 0,
      voteCount: json['voteCount'] as int?,
      percentage: json['percentage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'votingId': votingId,
      'optionText': optionText,
      'optionImageUrl': optionImageUrl,
      'orderIndex': orderIndex,
      'voteCount': voteCount,
      'percentage': percentage,
    };
  }
}

class VotingHistory {
  final int id;
  final int votingId;
  final VotingBasicInfo voting;
  final List<int> selectedOptions;
  final List<VotingOption> selectedOptionsDetail;
  final DateTime answeredAt;

  VotingHistory({
    required this.id,
    required this.votingId,
    required this.voting,
    required this.selectedOptions,
    required this.selectedOptionsDetail,
    required this.answeredAt,
  });

  factory VotingHistory.fromJson(Map<String, dynamic> json) {
    return VotingHistory(
      id: json['id'] as int? ?? 0,
      votingId: json['votingId'] as int? ?? 0,
      voting: VotingBasicInfo.fromJson(json['voting'] as Map<String, dynamic>? ?? {}),
      selectedOptions: List<int>.from(json['selectedOptions'] as List? ?? []),
      selectedOptionsDetail: (json['selectedOptionsDetail'] as List<dynamic>?)
              ?.map((opt) => VotingOption.fromJson(opt as Map<String, dynamic>))
              .toList() ??
          [],
      answeredAt: DateTime.tryParse(json['answeredAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'votingId': votingId,
      'voting': voting.toJson(),
      'selectedOptions': selectedOptions,
      'selectedOptionsDetail': selectedOptionsDetail.map((opt) => opt.toJson()).toList(),
      'answeredAt': answeredAt.toIso8601String(),
    };
  }
}

class VotingBasicInfo {
  final int id;
  final String uuid;
  final String title;
  final String question;
  final String? questionImageUrl;
  final String votingType;
  final DateTime deadline;
  final bool isExpired;

  VotingBasicInfo({
    required this.id,
    required this.uuid,
    required this.title,
    required this.question,
    this.questionImageUrl,
    required this.votingType,
    required this.deadline,
    required this.isExpired,
  });

  factory VotingBasicInfo.fromJson(Map<String, dynamic> json) {
    return VotingBasicInfo(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      question: json['question'] as String? ?? '',
      questionImageUrl: json['questionImageUrl'] as String?,
      votingType: json['votingType'] as String? ?? 'single',
      deadline: DateTime.tryParse(json['deadline'] as String? ?? '') ?? DateTime.now(),
      isExpired: json['isExpired'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'title': title,
      'question': question,
      'questionImageUrl': questionImageUrl,
      'votingType': votingType,
      'deadline': deadline.toIso8601String(),
      'isExpired': isExpired,
    };
  }
}
