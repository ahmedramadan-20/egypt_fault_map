import 'package:egypt_fault_map/core/helpers/extensions.dart';
import 'package:egypt_fault_map/features/home/data/repos/fault_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_strings.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LocationCubit()..getLocation(),
        ),
        BlocProvider(
          create: (context) => AddFaultCubit(
            getIt<IFaultRepository>(),
            getIt<FirebaseAuth>(),
          ),
        ),
      ],
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
    // Use BlocListener to react to location state changes
    context.read<LocationCubit>().stream.listen((locationState) {
      if (locationState is LocationSuccess && mounted) {
        setState(() {
          _initialPosition = LatLng(
            locationState.position.latitude,
            locationState.position.longitude,
          );
        });
        // Initialize AddFaultCubit with location
        context.read<AddFaultCubit>().init(_initialPosition);
      }
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.addNewFault)),
      body: BlocConsumer<AddFaultCubit, AddFaultState>(
        listener: (context, state) {
          if (state is AddFaultSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.faultAddedSuccess)),
            );
            context.pop();
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
                child: _MapSelector(
                  initialPosition: _initialPosition,
                  selectedLocation: state.selectedLocation,
                  onLocationSelected: (latLng) {
                    context.read<AddFaultCubit>().selectLocation(latLng);
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: _buildForm(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, AddFaultState state) {
    return SingleChildScrollView(
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
              labelText: AppStrings.faultType,
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16.h),
          AppTextFormField(
            controller: _descController,
            hintText: AppStrings.description,
            keyboardType: TextInputType.text,
            validator: (v) => v!.isEmpty
                ? AppStrings.pleaseEnterDescription
                : null,
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
              labelText: AppStrings.severity,
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
                  : const Text(AppStrings.addFault),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapSelector extends StatefulWidget {
  final LatLng initialPosition;
  final LatLng? selectedLocation;
  final Function(LatLng) onLocationSelected;

  const _MapSelector({
    required this.initialPosition,
    required this.selectedLocation,
    required this.onLocationSelected,
  });

  @override
  State<_MapSelector> createState() => _MapSelectorState();
}

class _MapSelectorState extends State<_MapSelector> {
  GoogleMapController? _mapController;
  LatLng? _lastPosition;

  @override
  void didUpdateWidget(_MapSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animate camera when position changes
    if (widget.initialPosition != oldWidget.initialPosition &&
        widget.initialPosition != _lastPosition) {
      _lastPosition = widget.initialPosition;
      _animateToPosition(widget.initialPosition);
    }
  }

  void _animateToPosition(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.initialPosition,
        zoom: 15,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
      },
      onTap: widget.onLocationSelected,
      markers: widget.selectedLocation != null
          ? {
              Marker(
                markerId: const MarkerId('selected'),
                position: widget.selectedLocation!,
              ),
            }
          : {},
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
