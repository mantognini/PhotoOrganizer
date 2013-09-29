//
//  POAppDelegate.h
//  PhotoOrganizer
//
//  Created by Marco Antognini on 29/9/13.
//  Copyright (c) 2013 local. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface POAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) NSArray *imageUrls;
@property (strong) NSDictionary *urlProperties; // <NSURL, NSDictionary<NSString, NSString>>
@property (weak) IBOutlet NSArrayController *imageProperties; // NSDictionary<NSString, NSString>

@end
