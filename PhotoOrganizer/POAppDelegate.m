//
//  POAppDelegate.m
//  PhotoOrganizer
//
//  Created by Marco Antognini on 29/9/13.
//  Copyright (c) 2013 local. All rights reserved.
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
    }
    return self;
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
    NSDictionary *selection = [self.imagesData.selectedObjects lastObject];
    [self.currentImageData addObjects:[selection objectForKey:@"props"]];

    // We don't want everything to be selected
    [self.currentImageData setSelectedObjects:nil];
    [self.commonProps setSelectedObjects:nil];
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

@end
