import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';

void main() => runApp(ExampleApp());

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  final _activityStreamController = StreamController<Activity>();
  final _geofenceStreamController = StreamController<Geofence>();

  // Create a [GeofenceService] instance and set options.
  final _geofenceService = GeofenceService.instance.setup(
      interval: 5000,
      accuracy: 100,
      loiteringDelayMs: 60000,
      statusChangeDelayMs: 10000,
      useActivityRecognition: true,
      allowMockLocations: false,
      printDevLog: false,
      geofenceRadiusSortType: GeofenceRadiusSortType.DESC);

  // Create a [Geofence] list.
  final _geofenceList = <Geofence>[
    Geofence(
      id: 'place_1',
      latitude: 35.103422,
      longitude: 129.036023,
      radius: [
        GeofenceRadius(id: 'radius_100m', length: 100),
        GeofenceRadius(id: 'radius_25m', length: 25),
        GeofenceRadius(id: 'radius_250m', length: 250),
        GeofenceRadius(id: 'radius_200m', length: 200)
      ]
    ),
    Geofence(
      id: 'place_2',
      latitude: 35.104971,
      longitude: 129.034851,
      radius: [
        GeofenceRadius(id: 'radius_25m', length: 25),
        GeofenceRadius(id: 'radius_100m', length: 100),
        GeofenceRadius(id: 'radius_200m', length: 200)
      ]
    ),
  ];

  // This function is to be called when the geofence status is changed.
  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Position position) async {
    print('geofence: ${geofence.toJson()}');
    print('geofenceRadius: ${geofenceRadius.toJson()}');
    print('geofenceStatus: ${geofenceStatus.toString()}\n');
    _geofenceStreamController.sink.add(geofence);
  }

  // This function is to be called when the activity has changed.
  void _onActivityChanged(Activity prevActivity, Activity currActivity) {
    print('prevActivity: ${prevActivity.toMap()}');
    print('currActivity: ${currActivity.toMap()}\n');
    _activityStreamController.sink.add(currActivity);
  }

  // This function is to be called when the position has changed.
  void _onPositionChanged(Position position) {
    print('position: ${position.toJson()}');
  }

  // This function is to be called when a location service status change occurs
  // since the service was started.
  void _onLocationServiceStatusChanged(bool status) {
    print('location service status: $status');
  }

  // This function is used to handle errors that occur in the service.
  void _onError(error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      print('Undefined error: $error');
      return;
    }

    print('ErrorCode: $errorCode');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _geofenceService.addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
      _geofenceService.addPositionChangeListener(_onPositionChanged);
      _geofenceService.addLocationServiceStatusChangeListener(_onLocationServiceStatusChanged);
      _geofenceService.addActivityChangeListener(_onActivityChanged);
      _geofenceService.addStreamErrorListener(_onError);
      _geofenceService.start(_geofenceList).catchError(_onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // A widget used when you want to start a foreground task when trying to minimize or close the app.
      // Declare on top of the [Scaffold] widget.
      home: WillStartForegroundTask(
        onWillStart: () {
          // You can add a foreground task start condition.
          return _geofenceService.isRunningService;
        },
        notificationOptions: NotificationOptions(
          channelId: 'geofence_service_notification_channel',
          channelName: 'Geofence Service Notification',
          channelDescription: 'This notification appears when the geofence service is running in the background.',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW
        ),
        notificationTitle: 'Geofence Service is running',
        notificationText: 'Tap to return to the app',
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Geofence Service'),
            centerTitle: true
          ),
          body: _buildContentView()
        ),
      ),
    );
  }

  @override
  void dispose() {
    _activityStreamController.close();
    _geofenceStreamController.close();
    super.dispose();
  }

  Widget _buildContentView() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      children: [
        _buildActivityMonitor(),
        SizedBox(height: 20.0),
        _buildGeofenceMonitor()
      ],
    );
  }
  
  Widget _buildActivityMonitor() {
    return StreamBuilder<Activity>(
      stream: _activityStreamController.stream,
      builder: (context, snapshot) {
        final updatedDateTime = DateTime.now();
        final content = snapshot.data?.toMap().toString() ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('•\t\tActivity (updated: $updatedDateTime)'),
            SizedBox(height: 10.0),
            Text(content)
          ]
        );
      },
    );
  }
  
  Widget _buildGeofenceMonitor() {
    return StreamBuilder<Geofence>(
      stream: _geofenceStreamController.stream,
      builder: (context, snapshot) {
        final updatedDateTime = DateTime.now();
        final content = snapshot.data?.toJson().toString() ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('•\t\tGeofence (updated: $updatedDateTime)'),
            SizedBox(height: 10.0),
            Text(content)
          ]
        );
      },
    );
  }
}
