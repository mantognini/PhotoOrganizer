//
//  POAppDelegate.h
//  PhotoOrganizer
//
//  Created by Marco Antognini on 29/9/13.
//  Copyright (c) 2013 local. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

#import "POTimeFormatter.h"

@interface POAppDelegate : NSObject
<
    NSApplicationDelegate,
    NSTableViewDelegate,
    QLPreviewPanelDataSource
>

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSPanel *commonPropsPanel;
@property (unsafe_unretained) IBOutlet NSPanel *infoPanel;
@property (strong) NSMutableArray *urls; // Array<NSURL>
@property (weak) IBOutlet NSArrayController *imagesData; // ~Array~<ImageData>
@property (weak) IBOutlet NSArrayController *currentImageData;
@property (weak) IBOutlet NSArrayController *commonProps;
@property (strong) NSMutableSet *commonPropsSet;

@property (strong) POTimeFormatter *timeFormatter;
@property (strong) NSString *timeProp;

@end
