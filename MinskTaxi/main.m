    //
//  main.m
//  MinskTaxi
//
//  Created by ml on 9/25/11.
//  Copyright (c) 2011 ml. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

/*
int main(int argc, char *argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}*/

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
