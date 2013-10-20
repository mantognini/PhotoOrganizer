//
//  POAppDelegate.m
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

#import "POAppDelegate.h"
#import "POImageData.h"
#import "NSArrayController+PO.h"

@implementation POAppDelegate

- (id)init
{
    self = [super init];
    if (self) {
        // Init own (strong) attributes
        self.urls = [NSMutableArray array];
        self.commonPropsSet = nil; // yup!
        self.timeFormatter = [[POTimeFormatter alloc] init];
        self.timeFormatter.inputFormat = @"yyyy:MM:dd HH:mm:ss";
        self.timeFormatter.outputFormat = @"yyyy.MM.dd-HH.mm.ss";
        self.timeProp = nil;

        // Register for format modification
        [self.timeFormatter addObserver:self forKeyPath:@"inputFormat"
                                options:NSKeyValueObservingOptionNew context:NULL];
        [self.timeFormatter addObserver:self forKeyPath:@"outputFormat"
                                options:NSKeyValueObservingOptionNew context:NULL];
        [self.timeFormatter addObserver:self forKeyPath:@"shift"
                                options:NSKeyValueObservingOptionNew context:NULL];

        self.processing = NO;
    }
    return self;
}

- (void)dealloc
{
    // Unregister observer
    [self.timeFormatter removeObserver:self forKeyPath:@"shift"];
    [self.timeFormatter removeObserver:self forKeyPath:@"outputFormat"];
    [self.timeFormatter removeObserver:self forKeyPath:@"inputFormat"];
}

- (IBAction)browse:(id)sender
{
    // Open a browser panel for image selection only
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setFloatingPanel:YES];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowsMultipleSelection:YES];
    [panel setTitle:@"Select some Images"];
    [panel setAllowedFileTypes:@[(__bridge NSString *)kUTTypeImage]];

    // Browse
    NSInteger i = [panel runModal];
    if (i == NSOKButton) {
        // Load props & update info window
        [self loadPropertiesForUrls:[panel URLs]];
        [self updateInfo];
    }
}

- (IBAction)clear:(id)sender
{
    // Unload everything
    [self.imagesData removeAllObjects];
    [self.currentImageData removeAllObjects];
    [self.urls removeAllObjects];
    self.commonPropsSet = nil; // yup!
    [self.commonProps removeAllObjects];
}

- (IBAction)info:(id)sender
{
    [self toggle:self.infoPanel];
}

- (IBAction)props:(id)sender
{
    [self toggle:self.commonPropsPanel];
}

- (void)toggle:(NSWindow *)window
{
    // Toggle window visibility
    if ([window isVisible]) [window orderOut:self];
    else [window orderFront:self];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    [self updateInfo];
}

- (void)updateInfo
{
    // Populate info window with selected image props
    [self.currentImageData removeAllObjects];
    POImageData *selection = [self.imagesData.selectedObjects lastObject];
    [self.currentImageData addObjects:selection.props];

    // We don't want everything to be selected
    [self.currentImageData setSelectedObjects:nil];
    [self.commonProps setSelectedObjects:nil];
}

- (void)updatePreviewName
{
    // Find out the date of each picture
    [self.imagesData.arrangedObjects enumerateObjectsUsingBlock:^(POImageData *obj, NSUInteger idx, BOOL *stop) {
        NSString *rawTime = [obj valueForProperty:self.timeProp];
        NSString *output = [self.timeFormatter format:rawTime];
        obj.previewName = output != nil && ![output isEqualToString:@""] ? output : obj.origName;
    }];
}

- (void)loadPropertiesForUrls:(NSArray *)urls
{
    // For each URL...
    [urls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSURL *url = obj;

        // ...make sure we haven't already loaded it
        if ([self.urls containsObject:url]) return;
        [self.urls addObject:url];

        // ...then load data
        POImageData *data = [POImageData imageDataForUrl:url];
        [self.imagesData addObject:data];

        // ...update common props set
        NSMutableSet *propsSet = [NSMutableSet set];
        [data.props enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *dict = obj;
            NSString *propName = [dict objectForKey:@"name"];
            [propsSet addObject:propName];
        }];
        if (self.commonPropsSet == nil) {
            self.commonPropsSet = propsSet;
        } else {
            [self.commonPropsSet intersectSet:propsSet];
        }
    }];

    // And update Common Props Window
    [self.commonProps removeAllObjects];
    [self.commonProps addObjects:[self.commonPropsSet allObjects]];
}

- (IBAction)toggleQuickLook:(NSButton *)sender
{
    if ([QLPreviewPanel sharedPreviewPanelExists]
        && [[QLPreviewPanel sharedPreviewPanel] isVisible]) {
        [[QLPreviewPanel sharedPreviewPanel] orderOut:sender];
    } else {
        [[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:sender];
    }
}

- (NSArray *)arrangedImageData
{
    return self.imagesData.arrangedObjects;
}

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel
{
    return self.arrangedImageData.count;
}

- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index
{
    return [self.arrangedImageData objectAtIndex:index];
}

- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel
{
    return YES;
}

- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel
{
    panel.dataSource = self;
    panel.currentPreviewItemIndex = self.imagesData.selectionIndex;
}

- (void)endPreviewPanelControl:(QLPreviewPanel *)panel
{
    // Update selection
    self.imagesData.selectionIndex = panel.currentPreviewItemIndex;
}

- (IBAction)setTimeProperty:(id)sender
{
    if (self.commonProps.selectionIndex == NSNotFound) {
        self.timeProp = nil;
    } else {
        self.timeProp = self.commonProps.selectedObjects.lastObject;
        [self updatePreviewName];
    }
}

// Run on main thread
- (void)preCopyImage
{
    self.processing = YES;
    [self.progressBar setMinValue:0.0];
    [self.progressBar setMaxValue:[self.imagesData.arrangedObjects count]];
    [self.progressBar setDoubleValue:0.0];
    [self.progressBar startAnimation:self];
}

// Run on main thread
- (void)postCopyImage:(NSError *)error
{
    if (error != nil) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
    }
    
    [self.progressBar stopAnimation:self];
    [self.progressBar setDoubleValue:0.0];
    self.processing = NO;
}

// This selector is run in a worker thread
- (void)copyImagesTo:(NSURL *)output
{
    [self performSelectorOnMainThread:@selector(preCopyImage) withObject:nil waitUntilDone:YES];

    __block NSError *error = nil;
    [self.imagesData.arrangedObjects enumerateObjectsUsingBlock:^(POImageData *obj, NSUInteger idx, BOOL *stop) {
        error = [self copy:obj.url to:output withName:obj.previewName];
        *stop = error != nil;
        [self.progressBar incrementBy:1.0];
    }];

    [self performSelectorOnMainThread:@selector(postCopyImage:) withObject:error waitUntilDone:YES];
}

- (IBAction)save:(id)sender
{
    // Open a browser panel to select the output directory
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setFloatingPanel:YES];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setTitle:@"Select the output directory"];

    // Browse
    NSInteger i = [panel runModal];
    if (i == NSOKButton) {
        // Copy each files to the destination
        NSURL *output = [[panel URLs] lastObject];
        [self performSelectorInBackground:@selector(copyImagesTo:) withObject:output];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    // We only observe our formatter so...
    [self updatePreviewName];
}

- (NSError *)copy:(NSURL *)file to:(NSURL *)directory withName:(NSString *)name
{
    NSURL *destination = [[directory URLByAppendingPathComponent:name] URLByAppendingPathExtension:[file pathExtension]];

    NSError *error = nil;
    NSFileManager *fs = [NSFileManager defaultManager];
    [fs copyItemAtURL:file toURL:destination error:&error];

    return error;
}

@end
