//
//  POAppDelegate.h
//  PhotoOrganizer
//
//  Created by Marco Antognini on 29/9/13.
//  Copyright (c) 2013 local. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface POAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSWindow *commonPropsWindow;
@property (unsafe_unretained) IBOutlet NSPanel *infoPanel;
@property (strong) NSMutableArray *urls; // Array<NSURL>
@property (weak) IBOutlet NSArrayController *imagesData; // ~Array~<{url, props}>
// {props} is NSMutableArray{key, value}
@property (weak) IBOutlet NSArrayController *currentImageData;
@property (weak) IBOutlet NSArrayController *commonProps;
@property (strong) NSMutableSet *commonPropsSet;

@end
