#import "GeofenceServicePlugin.h"
#if __has_include(<geofence_service_in_app/geofence_service_in_app-Swift.h>)
#import <geofence_service_in_app/geofence_service_in_app-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "geofence_service_in_app-Swift.h"
#endif

@implementation GeofenceServicePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftGeofenceServicePlugin registerWithRegistrar:registrar];
}
@end
