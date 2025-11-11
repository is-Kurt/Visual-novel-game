import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

class RoundedBoxComponent extends PositionComponent {
  final Paint? fillPaint;
  final Paint? borderPaint;
  final double? borderRadius;

  // NEW: Per-corner radius
  final double? topLeftRadius;
  final double? topRightRadius;
  final double? bottomLeftRadius;
  final double? bottomRightRadius;

  final double? borderWidth;

  // NEW: Per-side borders
  final bool borderTop;
  final bool borderRight;
  final bool borderBottom;
  final bool borderLeft;

  final BoxShadow? boxShadow;

  RoundedBoxComponent({
    Vector2? position,
    required Vector2 super.size,
    this.fillPaint,
    this.borderPaint,

    // Global radius (overridden by individual corner radii)
    this.borderRadius,

    // Individual corner radii
    this.topLeftRadius,
    this.topRightRadius,
    this.bottomLeftRadius,
    this.bottomRightRadius,

    this.borderWidth,

    // Per-side borders (default all sides)
    this.borderTop = true,
    this.borderRight = true,
    this.borderBottom = true,
    this.borderLeft = true,

    this.boxShadow,
    super.priority,
    Anchor? anchor,
  }) : super(position: position ?? Vector2.zero(), anchor: anchor ?? Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    final double strokeWidth = borderWidth ?? 0;
    final double radius = borderRadius ?? 0;

    // Calculate individual corner radii
    final double tl = topLeftRadius ?? radius;
    final double tr = topRightRadius ?? radius;
    final double bl = bottomLeftRadius ?? radius;
    final double br = bottomRightRadius ?? radius;

    // Keep border fully inside the box
    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(inset, inset, size.x - strokeWidth, size.y - strokeWidth);

    // Create RRect with individual corner radii
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(tl),
      topRight: Radius.circular(tr),
      bottomLeft: Radius.circular(bl),
      bottomRight: Radius.circular(br),
    );

    // Render Shadow
    if (boxShadow != null) {
      final shadowPaint = Paint()
        ..color = boxShadow!.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, boxShadow!.blurRadius);
      final shadowRRect = rrect.shift(boxShadow!.offset);
      canvas.drawRRect(shadowRRect, shadowPaint);
    }

    // Fill
    if (fillPaint != null) {
      canvas.drawRRect(rrect, fillPaint!);
    }

    // Border (with per-side control)
    if (borderPaint != null && strokeWidth > 0) {
      final border = borderPaint!
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      // If all borders are enabled, draw the full border
      if (borderTop && borderRight && borderBottom && borderLeft) {
        canvas.drawRRect(rrect, border);
      } else {
        // Draw individual sides
        _drawPartialBorder(canvas, rrect, border, strokeWidth);
      }
    }
  }

  void _drawPartialBorder(Canvas canvas, RRect rrect, Paint border, double strokeWidth) {
    final path = Path();
    bool needsMoveTo = true;

    // --- 1. Top Border ---
    if (borderTop) {
      // Start at top-left, after radius
      path.moveTo(rrect.left + rrect.tlRadiusX, rrect.top);
      // Line to top-right, before radius
      path.lineTo(rrect.right - rrect.trRadiusX, rrect.top);
      needsMoveTo = false;
    }

    // --- 2. Top-Right Arc ---
    // Only draw arc if top or right border is enabled
    if (rrect.trRadius.x > 0 && (borderTop || borderRight)) {
      final trCenter = Offset(rrect.right - rrect.trRadius.x, rrect.top + rrect.trRadius.y);
      final arcRect = Rect.fromCircle(center: trCenter, radius: rrect.trRadius.x);
      // Use forceMoveTo = true if the top border wasn't drawn
      path.arcTo(arcRect, -pi / 2, pi / 2, needsMoveTo);
      needsMoveTo = false;
    }

    // --- 3. Right Border ---
    if (borderRight) {
      if (needsMoveTo) {
        // If TR arc wasn't drawn, move to start of right line
        path.moveTo(rrect.right, rrect.top + rrect.trRadiusY);
      }
      path.lineTo(rrect.right, rrect.bottom - rrect.brRadiusY);
      needsMoveTo = false;
    }

    // --- 4. Bottom-Right Arc ---
    // Only draw arc if right or bottom border is enabled
    if (rrect.brRadius.x > 0 && (borderRight || borderBottom)) {
      final brCenter = Offset(rrect.right - rrect.brRadius.x, rrect.bottom - rrect.brRadius.y);
      final arcRect = Rect.fromCircle(center: brCenter, radius: rrect.brRadius.x);
      path.arcTo(arcRect, 0, pi / 2, needsMoveTo);
      needsMoveTo = false;
    }

    // --- 5. Bottom Border ---
    if (borderBottom) {
      if (needsMoveTo) {
        // If BR arc wasn't drawn, move to start of bottom line
        path.moveTo(rrect.right - rrect.brRadiusX, rrect.bottom);
      }
      path.lineTo(rrect.left + rrect.blRadiusX, rrect.bottom);
      needsMoveTo = false;
    }

    // --- 6. Bottom-Left Arc ---
    // Only draw arc if bottom or left border is enabled
    if (rrect.blRadius.x > 0 && (borderBottom || borderLeft)) {
      final blCenter = Offset(rrect.left + rrect.blRadius.x, rrect.bottom - rrect.blRadius.y);
      final arcRect = Rect.fromCircle(center: blCenter, radius: rrect.blRadius.x);
      path.arcTo(arcRect, pi / 2, pi / 2, needsMoveTo);
      needsMoveTo = false;
    }

    // --- 7. Left Border ---
    if (borderLeft) {
      if (needsMoveTo) {
        // If BL arc wasn't drawn, move to start of left line
        path.moveTo(rrect.left, rrect.bottom - rrect.blRadiusY);
      }
      path.lineTo(rrect.left, rrect.top + rrect.tlRadiusY);
      needsMoveTo = false;
    }

    // --- 8. Top-Left Arc ---
    // Only draw arc if left or top border is enabled
    if (rrect.tlRadius.x > 0 && (borderLeft || borderTop)) {
      final tlCenter = Offset(rrect.left + rrect.tlRadius.x, rrect.top + rrect.tlRadius.y);
      final arcRect = Rect.fromCircle(center: tlCenter, radius: rrect.tlRadius.x);
      path.arcTo(arcRect, pi, pi / 2, needsMoveTo);
      needsMoveTo = false;
    }

    canvas.drawPath(path, border);
  }
}
