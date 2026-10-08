import 'package:flutter/material.dart';

class ZoomableCanvas extends StatefulWidget {
  final Widget child;
  final TransformationController? transformationController;

  const ZoomableCanvas({
    super.key,
    required this.child,
    this.transformationController,
  });

  @override
  State<ZoomableCanvas> createState() => _ZoomableCanvasState();
}

class _ZoomableCanvasState extends State<ZoomableCanvas> {
  late TransformationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.transformationController ?? TransformationController();
  }

  @override
  void dispose() {
    if (widget.transformationController == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _controller,
      minScale: 1.0,
      maxScale: 5.0,
      panEnabled: true,
      scaleEnabled: true,
      clipBehavior: Clip.hardEdge,
      child: Center(
        child: widget.child,
      ),
    );
  }
}
