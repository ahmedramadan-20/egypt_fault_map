import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/helpers/extensions.dart';
import '../../../core/routing/routes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../home/data/repos/fault_repository.dart';
import '../../home/ui/widgets/fault_card.dart';
import '../logic/my_reports/my_reports_cubit.dart';

class MyReportsScreen extends StatelessWidget {
  final String userId;

  const MyReportsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyReportsCubit(getIt<IFaultRepository>())
        ..loadUserReports(userId),
      child: const _MyReportsContent(),
    );
  }
}

class _MyReportsContent extends StatelessWidget {
  const _MyReportsContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: BlocBuilder<MyReportsCubit, MyReportsState>(
        builder: (context, state) {
          if (state is MyReportsLoading) {
            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: 5,
              itemBuilder: (context, index) => const FaultCardSkeleton(),
            );
          } else if (state is MyReportsLoaded) {
            if (state.faults.isEmpty) {
              return EmptyState(
                icon: Icons.report_problem_outlined,
                title: 'No Reports Yet',
                message: 'You haven\'t reported any faults yet.\nStart by reporting a fault to help your community!',
                actionLabel: 'Report a Fault',
                onActionPressed: () {
                  Navigator.pop(context);
                  context.pushNamed(Routes.addFaultScreen);
                },
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<MyReportsCubit>().refreshReports(),
              child: Column(
                children: [
                  // Summary Card
                  _buildSummaryCard(state),
                  // Faults List
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: state.faults.length,
                      itemBuilder: (context, index) {
                        final fault = state.faults[index];
                        return GestureDetector(
                          onTap: () {
                            context.pushNamed(
                              Routes.faultDetailsScreen,
                              arguments: fault.id,
                            );
                          },
                          child: FaultCard(fault: fault),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (state is MyReportsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'Error Loading Reports',
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text(
                      state.message,
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: () => context.read<MyReportsCubit>().refreshReports(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummaryCard(MyReportsLoaded state) {
    final statusCounts = <String, int>{
      'pending': 0,
      'in_progress': 0,
      'resolved': 0,
    };

    for (var fault in state.faults) {
      statusCounts[fault.status] = (statusCounts[fault.status] ?? 0) + 1;
    }

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Impact',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusChip('Pending', statusCounts['pending']!, Colors.orange),
              _buildStatusChip('In Progress', statusCounts['in_progress']!, Colors.blue),
              _buildStatusChip('Resolved', statusCounts['resolved']!, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    final cubit = context.read<MyReportsCubit>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filter Reports'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Reports'),
              leading: const Icon(Icons.list),
              onTap: () {
                cubit.filterByStatus(null);
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              title: const Text('Pending'),
              leading: const Icon(Icons.pending, color: Colors.orange),
              onTap: () {
                cubit.filterByStatus('pending');
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              title: const Text('In Progress'),
              leading: const Icon(Icons.engineering, color: Colors.blue),
              onTap: () {
                cubit.filterByStatus('in_progress');
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              title: const Text('Resolved'),
              leading: const Icon(Icons.check_circle, color: Colors.green),
              onTap: () {
                cubit.filterByStatus('resolved');
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
      ),
    );
  }
}
