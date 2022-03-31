#import "CfMultiPickerPlugin.h"
#if __has_include(<cf_multi_picker/cf_multi_picker-Swift.h>)
#import <cf_multi_picker/cf_multi_picker-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "cf_multi_picker-Swift.h"
#endif

@implementation CfMultiPickerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCfMultiPickerPlugin registerWithRegistrar:registrar];
}
@end
