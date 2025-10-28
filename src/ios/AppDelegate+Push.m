//
//  AppDelegate+Push.m
//  BluetoohTest
//
//  Created by Ronelio Oliveira on 12/11/23.
//

#import "AppDelegate+Push.h"
#import <objc/runtime.h>
#import <AEPCore/AEPCore-Swift.h>

@implementation AppDelegate (Push)

+ (void)load {
    Method original = class_getInstanceMethod(self, @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:));
    Method swizzled = class_getInstanceMethod(self, @selector(application:swizzledDidRegisterForRemoteNotificationsWithDeviceToken:));
    method_exchangeImplementations(original, swizzled);
}

- (void)application:(UIApplication *)application swizzledDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [AEPMobileCore setPushIdentifier:deviceToken];
    NSLog(@"ACPCampaign_didRegisterForRemoteNotificationsWithDeviceToken");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;
}

@end
