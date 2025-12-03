import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/helpers/extensions.dart';
import '../../data/models/fault_model.dart';

class FaultCard extends StatelessWidget {
  final FaultModel fault;
  final double? distance;

  const FaultCard({super.key, required this.fault, this.distance});

  String _getDistanceText() {
    if (distance == null) return "";
    if (distance! < 1000) {
      return "${distance!.toStringAsFixed(0)} m away";
    }
    return "${(distance! / 1000).toStringAsFixed(1)} km away";
  }

  Color _getStatusColor() {
    switch (fault.status.toLowerCase()) {
      case 'pending':
        return AppColors.statusPending;
      case 'in-progress':
        return AppColors.statusInProgress;
      case 'done':
        return AppColors.statusDone;
      default:
        return AppColors.statusUnknown;
    }
  }

  Color _getSeverityColor() {
    switch (fault.severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'fault_${fault.id}',
      child: Card(
        margin: EdgeInsets.only(bottom: 12.h),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: InkWell(
        onTap: () {
          context.pushNamed(
            Routes.faultDetailsScreen,
            arguments: {'fault': fault, 'distance': distance},
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image/Icon
              _buildLeadingImage(),
              SizedBox(width: 12.w),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with severity indicator
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fault.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // Severity indicator dot
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: _getSeverityColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    // Description
                    Text(
                      fault.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[700],
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Status and Distance badges
                    Row(
                      children: [
                        // Status badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: _getStatusColor().withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            fault.status.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (distance != null) ...[
                          SizedBox(width: 8.w),
                          // Distance badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 12.sp,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  _getDistanceText(),
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildLeadingImage() {
    if (fault.imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: CachedNetworkImage(
          imageUrl: fault.imageUrl,
          width: 70.w,
          height: 70.h,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 70.w,
            height: 70.h,
            color: AppColors.grey300,
            child: Center(
              child: SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            width: 70.w,
            height: 70.h,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.broken_image,
              size: 30.sp,
              color: AppColors.grey,
            ),
          ),
        ),
      );
    }

    // Default icon container with gradient
    return Container(
      width: 70.w,
      height: 70.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getSeverityColor().withValues(alpha: 0.2),
            _getSeverityColor().withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(
        Icons.report_problem_outlined,
        size: 32.sp,
        color: _getSeverityColor(),
      ),
    );
  }
}
