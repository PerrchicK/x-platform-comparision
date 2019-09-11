//
//  UtilsObjC.m
//  SomeApp
//
//  Created by Perry on 2/18/18.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

#import "UtilsObjC.h"
#import "FLEX.h"

@interface UtilsObjC()

//@property (nonatomic, strong) NSDictionary *environmentConfigurations;

@end

@implementation UtilsObjC

//@synthesize environmentConfigurations;

// Singleton implementation in Objective-C
__strong static UtilsObjC *_shared;
+ (UtilsObjC *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[UtilsObjC alloc] init];
    });
    
    return _shared;
}

+(BOOL)isRunningOnSimulator {
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    return NO;
#endif
}

+ (void)showFlex {
#if DEBUG
    NSLog(@"showing FLEX explorer...");
    [FLEXManager.sharedManager showExplorer];
    
#else
    NSLog(@"ignoring...");
#endif
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // init stuff...
    }
    return self;
}

+ (void)load {
    NSLog(@"Class loaded");
}

@end
