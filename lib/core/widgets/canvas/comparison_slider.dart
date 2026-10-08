import 'package:flutter/material.dart';
import 'package:removeit_app/core/services/haptic_service.dart';

class ComparisonSlider extends StatefulWidget {
  final Widget originalImage;
  final Widget processedImage;
  final double initialPosition;

  const ComparisonSlider({
    super.key,
    required this.originalImage,
    required this.processedImage,
    this.initialPosition = 0.5,
  });

  @override
  State<ComparisonSlider> createState() => _ComparisonSliderState();
}

class _ComparisonSliderState extends State<ComparisonSlider>
    with SingleTickerProviderStateMixin {
  late double _sliderPosition;
  late AnimationController _animController;
  Animation<double>? _resetAnimation;

  @override
  void initState() {
    super.initState();
    _sliderPosition = widget.initialPosition;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..addListener(() {
        if (_resetAnimation != null) {
          setState(() {
            _sliderPosition = _resetAnimation!.value;
          });
        }
      });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _updatePosition(double localDx, double width) {
    if (width <= 0) return;
    final newPos = (localDx / width).clamp(0.0, 1.0);

    // Haptic tick when passing center (0.5)
    if ((_sliderPosition < 0.5 && newPos >= 0.5) ||
        (_sliderPosition > 0.5 && newPos <= 0.5)) {
      HapticService.selection();
    }

    setState(() => _sliderPosition = newPos);
  }

  void _resetToCenter() {
    HapticService.light();
    _resetAnimation = Tween<double>(begin: _sliderPosition, end: 0.5).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return GestureDetector(
          onDoubleTap: _resetToCenter,
          onHorizontalDragUpdate: (details) =>
              _updatePosition(details.localPosition.dx, width),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Processed Layer (Cutout with active backdrop)
              widget.processedImage,

              // 2. Original Layer clipped to slider position
              ClipRect(
                clipper: _SliderClipper(_sliderPosition),
                child: widget.originalImage,
              ),

              // 3. Divider Line
              Positioned(
                left: (width * _sliderPosition) - 1.5,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 3,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),

              // 4. Thumb Handle
              Positioned(
                left: (width * _sliderPosition) - 20,
                top: (height / 2) - 20,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.compare_arrows_rounded,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SliderClipper extends CustomClipper<Rect> {
  final double fraction;
  _SliderClipper(this.fraction);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * fraction, size.height);
  }

  @override
  bool shouldReclip(_SliderClipper oldClipper) => oldClipper.fraction != fraction;
}
