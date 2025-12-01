import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'core/routing/app_router.dart';

class EgyptFaultMap extends StatelessWidget {
  final AppRouter appRouter;
  final String initialRoute;

  const EgyptFaultMap({
    super.key,
    required this.appRouter,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      child: MaterialApp(
        title: 'Egypt Fault Map',
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute,
        onGenerateRoute: appRouter.generateRoute,
      ),
    );
  }
}

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   GoogleMapController? _controller;

//   final CameraPosition _initialPosition = const CameraPosition(
//     target: LatLng(30.0444, 31.2357), // Cairo coordinates
//     zoom: 14,
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Google Maps")),
//       body: GoogleMap(
//         initialCameraPosition: _initialPosition,
//         onMapCreated: (controller) => _controller = controller,
//         myLocationEnabled: true,
//         myLocationButtonEnabled: true,
//         zoomControlsEnabled: true,
//       ),
//     );
//   }
// }
