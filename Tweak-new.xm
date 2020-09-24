/*
* First method:
@interface SpringBoard : NSObject
+ (id)sharedApplication;
- (id)pluginUserAgent;
@end

@interface SBUserAgent : NSObject
- (bool)deviceIsPasscodeLocked;
- (void)lockAndDimDevice;
@end*/
#define _GNU_SOURCE
#include <dlfcn.h>
// Second method:
@interface MCPasscodeManager : NSObject
+ (MCPasscodeManager *)sharedManager;
- (BOOL)isDeviceLocked;
- (void)lockDevice;
@end

@interface DDNotificationSBControlSource : NSObject
-(bool)actuallySleepAfterIdlePresentation;
@end

static bool sleepAfterIdlePresentation;

%hook DDNotificationSBControlSource
-(void)dismissedNotification:(id) arg1 {
  %orig;
  sleepAfterIdlePresentation = self.actuallySleepAfterIdlePresentation;
}
%end

%hook DDNotificationView
-(void)dismissByTimer {
  %orig;
  if(![(MCPasscodeManager *)[%c(MCPasscodeManager) sharedManager] isDeviceLocked] && sleepAfterIdlePresentation)
    [(MCPasscodeManager *)[%c(MCPasscodeManager) sharedManager] lockDevice];

  /*if(![[(SpringBoard *)[%c(SpringBoard) sharedApplication] pluginUserAgent] deviceIsPasscodeLocked])
    [[(SpringBoard *)[%c(SpringBoard) sharedApplication] pluginUserAgent] lockAndDimDevice];*/
}
%end

%ctor {
	dlopen("/Library/MobileSubstrate/DynamicLibraries/ShortLook.dylib", RTLD_LAZY);
  %init;
}
