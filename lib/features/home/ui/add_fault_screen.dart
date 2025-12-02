import 'package:egypt_fault_map/features/home/data/repos/fault_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/widgets/text_field.dart';
import '../logic/add_fault/add_fault_cubit.dart';
import '../logic/add_fault/add_fault_state.dart';
import '../logic/location/location_cubit.dart';
import '../logic/location/location_state.dart';

class AddFaultScreen extends StatelessWidget {
  const AddFaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AddFaultCubit(getIt<FaultRepository>(), getIt<FirebaseAuth>()),
      child: const _AddFaultScreenContent(),
    );
  }
}

class _AddFaultScreenContent extends StatefulWidget {
  const _AddFaultScreenContent();

  @override
  State<_AddFaultScreenContent> createState() => _AddFaultScreenContentState();
}

class _AddFaultScreenContentState extends State<_AddFaultScreenContent> {
  final _descController = TextEditingController();
  String _type = 'other';
  String _severity = 'Low';
  LatLng _initialPosition = const LatLng(30.0444, 31.2357); // Cairo default

  @override
  void initState() {
    super.initState();
    final locationState = context.read<LocationCubit>().state;
    if (locationState is LocationSuccess) {
      _initialPosition = LatLng(
        locationState.position.latitude,
        locationState.position.longitude,
      );
      // Also select this location by default in the cubit
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AddFaultCubit>().selectLocation(_initialPosition);
      });
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Fault")),
      body: BlocConsumer<AddFaultCubit, AddFaultState>(
        listener: (context, state) {
          if (state is AddFaultSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Fault added successfully!")),
            );
            Navigator.pop(context);
          } else if (state is AddFaultError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                flex: 1,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition,
                    zoom: 15,
                  ),
                  onTap: (latLng) {
                    context.read<AddFaultCubit>().selectLocation(latLng);
                  },
                  markers:
                      context.read<AddFaultCubit>().selectedLocation != null
                      ? {
                          Marker(
                            markerId: const MarkerId('selected'),
                            position: context
                                .read<AddFaultCubit>()
                                .selectedLocation!,
                          ),
                        }
                      : {},
                ),
              ),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _type,
                        items: ['water', 'electric', 'street', 'light', 'other']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _type = v!),
                        decoration: const InputDecoration(
                          labelText: "Fault Type",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      AppTextFormField(
                        controller: _descController,
                        hintText: "Description",
                        keyboardType: TextInputType.text,
                        validator: (v) =>
                            v!.isEmpty ? "Please enter description" : null,
                      ),
                      SizedBox(height: 16.h),
                      DropdownButtonFormField<String>(
                        initialValue: _severity,
                        items: ['Low', 'Medium', 'High']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _severity = v!),
                        decoration: const InputDecoration(
                          labelText: "Severity",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: state is AddFaultLoading
                              ? null
                              : () {
                                  context.read<AddFaultCubit>().addFault(
                                    type: _type,
                                    description: _descController.text,
                                    severity: _severity,
                                  );
                                },
                          child: state is AddFaultLoading
                              ? const CircularProgressIndicator()
                              : const Text("Add Fault"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
