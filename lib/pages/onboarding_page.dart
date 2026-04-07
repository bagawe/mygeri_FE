import 'package:flutter/material.dart';
import '../models/onboarding_slide_model.dart';
import '../services/onboarding_service.dart';
import 'login_page.dart';

/// Dynamic Onboarding Page yang fetch slides dari backend API
/// 
/// Navigation Rules:
/// - Slide 0 & 1: Skip disabled, "Next" button only
/// - Slide 2+: Skip enabled, "Next" dan "Skip" buttons
/// - Last slide: "Finish" button instead of "Next"
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  List<OnboardingSlideModel> _slides = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchSlides();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Fetch slides dari backend
  Future<void> _fetchSlides() async {
    try {
      final service = OnboardingService();
      final slides = await service.getSlides();

      setState(() {
        _slides = slides;
        _isLoading = false;

        // Jika no slides, langsung ke login
        if (slides.isEmpty) {
          _navigateToLogin();
        }
      });
    } catch (e) {
      print('Error fetching slides: $e');
      setState(() {
        _errorMessage = 'Error loading onboarding slides';
        _isLoading = false;
      });

      // Jika error, go to login after 2 seconds
      Future.delayed(Duration(seconds: 2), _navigateToLogin);
    }
  }

  /// Navigate ke Login Page
  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  /// Next slide atau Finish
  void _onNextPressed() {
    if (_isLastSlide) {
      // Last slide - go to login
      _navigateToLogin();
    } else {
      // Go to next slide
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Skip current slide - go to login
  void _onSkipPressed() {
    print('🔄 User skipped onboarding at slide ${_currentPage + 1}');
    _navigateToLogin();
  }

  /// Check apakah last slide
  bool get _isLastSlide => _currentPage == _slides.length - 1;

  /// Check apakah bisa skip
  /// Slide 0 dan 1: No skip
  /// Slide 2+: Yes skip
  bool get _canSkip => _currentPage >= 2;

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading onboarding...'),
            ],
          ),
        ),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text(_errorMessage!),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _navigateToLogin,
                child: Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    // No slides - should not reach here, but just in case
    if (_slides.isEmpty) {
      return LoginPage();
    }

    return WillPopScope(
      onWillPop: () async {
        // Prevent back gesture
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // PageView untuk slides
            PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() => _currentPage = page);
              },
              physics: NeverScrollableScrollPhysics(), // Prevent swipe
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                return _buildSlide(_slides[index]);
              },
            ),

            // Bottom buttons
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button (only if can skip)
                  if (_canSkip)
                    TextButton(
                      onPressed: _onSkipPressed,
                      child: Text(
                        'Skip',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  else
                    // Empty space for alignment
                    SizedBox(width: 60),

                  // Next/Finish button
                  ElevatedButton(
                    onPressed: _onNextPressed,
                    child: Text(_isLastSlide ? 'Finish' : 'Next'),
                  ),
                ],
              ),
            ),

            // Slide indicators (dots)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual slide based on type
  Widget _buildSlide(OnboardingSlideModel slide) {
    return Container(
      color: _parseBackgroundColor(slide.backgroundColor),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Render based on slide type
                _buildSlideContent(slide),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build slide content based on type
  Widget _buildSlideContent(OnboardingSlideModel slide) {
    switch (slide.type) {
      case 'title_image':
        return Column(
          children: [
            if (slide.title != null) _buildTitle(slide.title!),
            SizedBox(height: 32),
            if (slide.imageUrl != null) _buildImage(slide.imageUrl!),
          ],
        );

      case 'title_text':
        return Column(
          children: [
            if (slide.title != null) _buildTitle(slide.title!),
            SizedBox(height: 24),
            if (slide.description != null)
              _buildDescription(slide.description!),
          ],
        );

      case 'image_only':
        return _buildImage(slide.imageUrl ?? '');

      case 'text_only':
        return _buildDescription(slide.description ?? '');

      case 'title_image_text':
        return Column(
          children: [
            if (slide.title != null) _buildTitle(slide.title!),
            SizedBox(height: 24),
            if (slide.imageUrl != null) _buildImage(slide.imageUrl!),
            SizedBox(height: 32),
            if (slide.description != null)
              _buildDescription(slide.description!),
          ],
        );

      default:
        return _buildDescription(
          slide.description ?? 'Onboarding slide',
        );
    }
  }

  /// Build title widget
  Widget _buildTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Build description widget
  Widget _buildDescription(String description) {
    return Text(
      description,
      style: Theme.of(context).textTheme.bodyLarge,
      textAlign: TextAlign.center,
    );
  }

  /// Build image widget with error handling
  Widget _buildImage(String imageUrl) {
    return Container(
      constraints: BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: Icon(
                Icons.image_not_supported,
                size: 48,
                color: Colors.grey[600],
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[300],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Parse background color from hex string
  Color _parseBackgroundColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return Colors.white;
    }

    try {
      // Remove # if present
      String hex = hexColor.replaceFirst('#', '');

      // Add FF for alpha if not present
      if (hex.length == 6) {
        hex = 'FF$hex';
      }

      return Color(int.parse('0x$hex'));
    } catch (e) {
      print('Error parsing color: $hexColor - $e');
      return Colors.white;
    }
  }
}
