@interface SpringBoard : NSObject
+ (id)sharedApplication;
- (id)pluginUserAgent;
@end

@interface SBUserAgent : NSObject
- (bool)deviceIsPasscodeLocked;
- (void)lockAndDimDevice;
@end

%hook DDNotificationView
-(void)dismissByTimer {
  %orig;
  if(![[(SpringBoard *)[%c(SpringBoard) sharedApplication] pluginUserAgent] deviceIsPasscodeLocked])
    [[(SpringBoard *)[%c(SpringBoard) sharedApplication] pluginUserAgent] lockAndDimDevice];
}
%end

%ctor {
	dlopen("/Library/MobileSubstrate/DynamicLibraries/ShortLook.dylib", RTLD_LAZY);
  %init;
}
