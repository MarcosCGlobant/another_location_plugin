#import "AnotherLocationPlugin.h"
#if __has_include(<another_location_plugin/another_location_plugin-Swift.h>)
#import <another_location_plugin/another_location_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "another_location_plugin-Swift.h"
#endif

@implementation AnotherLocationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAnotherLocationPlugin registerWithRegistrar:registrar];
}
@end
