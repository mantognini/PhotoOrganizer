//
//  POAppDelegate.h
//  PhotoOrganizer
//
//  Created by Marco Antognini on 29/9/13.
//  Copyright (c) 2013 Marco Antognini (antognini.marco@gmail.com)
//
// This software is provided 'as-is', without any express or implied warranty.
// In no event will the authors be held liable for any damages arising from
// the use of this software.
//
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it freely,
// subject to the following restrictions:
//
// 1. The origin of this software must not be misrepresented;
//    you must not claim that you wrote the original software.
//    If you use this software in a product, an acknowledgment
//    in the product documentation would be appreciated but is not required.
//
// 2. Altered source versions must be plainly marked as such,
//    and must not be misrepresented as being the original software.
//
// 3. This notice may not be removed or altered from any source distribution.
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
@property (weak) IBOutlet NSProgressIndicator *progressBar;

@property (strong) POTimeFormatter *timeFormatter;
@property (strong) NSString *timeProp;

@property BOOL processing; // YES -> disable buttons

@end
