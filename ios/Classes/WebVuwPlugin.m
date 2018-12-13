#import "WebVuwPlugin.h"
#import "web_vuw/web_vuw-Swift.h"

@implementation WebVuwPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
 
    [registrar registerViewFactory: [[WebVuwFactory alloc] initWithMessenger:[registrar messenger]] withId:@"plugins.devfatani.com/web_vuw"];
}
@end
