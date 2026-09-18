//
//  DelayMarker.m
//
//  Copyright © 2026 Blue Triangle. All rights reserved.
//
//  Objective-C's +load runs during dyld's image-loading phase, before any
//  Swift code — including the App struct's own init() — ever executes.
//  That makes it the earliest possible point to inject a Slow Launch delay,
//  even earlier than the "App init()" call site in StressSimulators.swift.
//  Deliberately reads NSUserDefaults directly with the same keys
//  StressSimulators.swift uses, rather than calling into Swift, since the
//  Swift runtime's readiness this early in process startup isn't
//  guaranteed the way it is by the time App.init() or AppDelegate methods
//  run.
//

#import <Foundation/Foundation.h>
#import <math.h>

@interface DelayMarker : NSObject
@end

@implementation DelayMarker

+ (void)load {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *const armedKey = @"MatricKitPoc.ArmSlowLaunch";
    NSString *const delayKey = @"MatricKitPoc.SlowLaunchDelay";
    NSString *const callSiteKey = @"MatricKitPoc.SlowLaunchCallSite";
    NSString *const methodKey = @"MatricKitPoc.SlowLaunchMethod";

    if (![defaults boolForKey:armedKey]) {
        return;
    }

    NSString *callSite = [defaults stringForKey:callSiteKey];
    if (![callSite isEqualToString:@"objcLoad"]) {
        return;
    }

    [defaults removeObjectForKey:armedKey];

    double delay = [defaults doubleForKey:delayKey];
    if (delay <= 0) {
        delay = 5;
    }

    NSString *method = [defaults stringForKey:methodKey];
    if ([method isEqualToString:@"busyLoop"]) {
        NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:delay];
        double accumulator = 0;
        while ([[NSDate date] compare:deadline] == NSOrderedAscending) {
            accumulator += sin(accumulator);
        }
        (void)accumulator;
    } else {
        [NSThread sleepForTimeInterval:delay];
    }
}

@end
