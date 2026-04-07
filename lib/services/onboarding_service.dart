import '../models/onboarding_slide_model.dart';
import 'api_service.dart';

/// Service untuk fetch onboarding slides dari backend API
class OnboardingService {
  // Singleton pattern
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  static const String _baseUrl = '/api/onboarding';
  final _apiService = ApiService();

  /// Fetch semua active onboarding slides
  /// 
  /// Returns list slides sorted by order (ascending)
  /// Returns empty list jika ada error
  Future<List<OnboardingSlideModel>> getSlides() async {
    try {
      print('📱 OnboardingService: Fetching slides from API...');

      final response = await _apiService.get('$_baseUrl/slides');

      if (response['success'] == true) {
        final List<dynamic> dataList = response['data'] ?? [];
        final slides = dataList
            .map((json) => OnboardingSlideModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Sort by order (ASC)
        slides.sort((a, b) => a.order.compareTo(b.order));

        print('✅ OnboardingService: Got ${slides.length} slides');
        for (var slide in slides) {
          print('   Slide ${slide.order}: ${slide.title ?? slide.type}');
        }
        return slides;
      } else {
        print('⚠️ OnboardingService: API returned success=false');
        return [];
      }
    } catch (e) {
      print('❌ OnboardingService: Error fetching slides - $e');
      return [];
    }
  }
}
