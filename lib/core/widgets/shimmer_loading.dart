import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShimmerLoading extends StatefulWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

// Shimmer Skeleton Widgets
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double? borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
      ),
    );
  }
}

class FaultCardSkeleton extends StatelessWidget {
  const FaultCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Card(
        margin: EdgeInsets.only(bottom: 12.h),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              ShimmerBox(width: 70.w, height: 70.h, borderRadius: 10.r),
              SizedBox(width: 12.w),
              // Content placeholder
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: double.infinity, height: 16.h),
                    SizedBox(height: 8.h),
                    ShimmerBox(width: double.infinity, height: 14.h),
                    SizedBox(height: 4.h),
                    ShimmerBox(width: 200.w, height: 14.h),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        ShimmerBox(width: 80.w, height: 24.h, borderRadius: 6.r),
                        SizedBox(width: 8.w),
                        ShimmerBox(width: 90.w, height: 24.h, borderRadius: 6.r),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            height: 200.h,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerBox(width: 120.w, height: 120.w, borderRadius: 60.r),
                SizedBox(height: 16.h),
                ShimmerBox(width: 150.w, height: 20.h),
                SizedBox(height: 8.h),
                ShimmerBox(width: 200.w, height: 16.h),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          // Stats cards
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: ShimmerBox(width: double.infinity, height: 120.h, borderRadius: 16.r),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ShimmerBox(width: double.infinity, height: 120.h, borderRadius: 16.r),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
