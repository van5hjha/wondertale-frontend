import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../core/api/sliders_service.dart';
import '../models/slider_model.dart';
import 'before_after_slider.dart';

class BeforeAfterSlideshow extends StatefulWidget {
  const BeforeAfterSlideshow({super.key});

  @override
  State<BeforeAfterSlideshow> createState() => _BeforeAfterSlideshowState();
}

class _BeforeAfterSlideshowState extends State<BeforeAfterSlideshow> {
  final SlidersService _slidersService = SlidersService();
  List<SliderModel> _slides = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isHovered = false;
  bool _movingForward = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadSlides();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSlides() async {
    try {
      final list = await _slidersService.fetchSliders();
      if (mounted) {
        setState(() {
          _slides = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching sliders from API: $e. Falling back to local assets.');
      try {
        final jsonString = await DefaultAssetBundle.of(context)
            .loadString('assets/data/sliders.json');
        final List<dynamic> list = json.decode(jsonString);
        final fallbackList = list.map((json) => SliderModel(
          id: 0,
          title: '',
          beforeImageUrl: json['beforeImageUrl'] as String,
          afterImageUrl: json['afterImageUrl'] as String,
        )).toList();
        
        if (mounted) {
          setState(() {
            _slides = fallbackList;
            _isLoading = false;
          });
        }
      } catch (jsonErr) {
        debugPrint('Error loading fallback sliders.json: $jsonErr');
        if (mounted) {
          setState(() {
            _slides = [
              SliderModel(
                id: 0,
                title: '',
                beforeImageUrl: "assets/images/before_image.png",
                afterImageUrl: "assets/images/after_image.jpg",
              )
            ];
            _isLoading = false;
          });
        }
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isHovered && _slides.isNotEmpty && !_isLoading) {
        setState(() {
          _movingForward = true;
          _currentIndex = (_currentIndex + 1) % _slides.length;
        });
      }
    });
  }

  void _goToPrev() {
    if (_slides.isEmpty) return;
    setState(() {
      _movingForward = false;
      _currentIndex = (_currentIndex - 1 + _slides.length) % _slides.length;
    });
  }

  void _goToNext() {
    if (_slides.isEmpty) return;
    setState(() {
      _movingForward = true;
      _currentIndex = (_currentIndex + 1) % _slides.length;
    });
  }

  Widget _buildNavArrow({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _isHovered ? 0.9 : 0.4,
      child: Tooltip(
        message: tooltip,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicators() {
    if (_slides.length <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length, (index) {
        final isActive = index == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: isActive ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.secondary : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4.0),
            boxShadow: isActive
                ? [
                    const BoxShadow(
                      color: Color(0x33A258F3),
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    )
                  ]
                : null,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AspectRatio(
        aspectRatio: 4 / 3,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppTheme.secondary),
          ),
        ),
      );
    }

    if (_slides.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentSlide = _slides[_currentIndex];

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  switchInCurve: Curves.easeInOutCubic,
                  switchOutCurve: Curves.easeInOutCubic,
                  transitionBuilder: (child, animation) {
                    final isIncoming = child.key == ValueKey<int>(_currentIndex);
                    Offset beginOffset;
                    if (isIncoming) {
                      beginOffset = _movingForward
                          ? const Offset(0.0, -1.0)
                          : const Offset(0.0, 1.0);
                    } else {
                      beginOffset = _movingForward
                          ? const Offset(0.0, 1.0)
                          : const Offset(0.0, -1.0);
                    }

                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: beginOffset,
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  child: BeforeAfterSlider(
                    key: ValueKey<int>(_currentIndex),
                    beforeImageUrl: currentSlide.beforeImageUrl,
                    afterImageUrl: currentSlide.afterImageUrl,
                  ),
                ),
              ),
              if (_slides.length > 1) ...[
                Positioned(
                  top: 12.0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildNavArrow(
                      icon: Icons.keyboard_arrow_up,
                      onTap: _goToPrev,
                      tooltip: 'Previous Slide',
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12.0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildNavArrow(
                      icon: Icons.keyboard_arrow_down,
                      onTap: _goToNext,
                      tooltip: 'Next Slide',
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16.0),
          _buildIndicators(),
        ],
      ),
    );
  }
}
