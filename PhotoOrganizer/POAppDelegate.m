//
//  POAppDelegate.m
//  PhotoOrganizer
//
//  Created by Marco Antognini on 29/9/13.
//  Copyright (c) 2013 local. All rights reserved.
//

#import "POAppDelegate.h"
#import "NSArrayController+PO.h"

@implementation POAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (IBAction)browse:(id)sender
{
    // Open a browser panel
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
        [self loadPropertiesForUrls:[panel URLs]];
        [self updateInfo];
    }
}

- (IBAction)clear:(id)sender
{
    [self.imagesData removeAllObjects];
    [self.urls removeAllObjects];
}

- (IBAction)info:(id)sender
{
    if ([self.infoPanel isVisible]) [self.infoPanel orderOut:self];
    else [self.infoPanel orderFront:self];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    [self updateInfo];
}

- (void)updateInfo
{
    [self.currentImageData removeAllObjects];
    NSDictionary *selection = [self.imagesData.selectedObjects lastObject];
    [self.currentImageData addObjects:[selection objectForKey:@"props"]];
    [self.currentImageData setSelectedObjects:nil];
}

- (void)loadPropertiesForUrls:(NSArray *)urls
{
    if (nil == self.urls) self.urls = [NSMutableArray array];

    NSFileManager *fs = [NSFileManager defaultManager];
    [urls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSURL *url = obj;

        if ([self.urls containsObject:url]) return;
        [self.urls addObject:url];

        NSMutableArray *props = [NSMutableArray array];
        [self.imagesData addObject:@{@"url": url, @"props": props}];

        NSError *error = nil;
        NSDictionary *fsprops = [fs attributesOfItemAtPath:url.relativePath error:&error];
        if (error) [self reportError:error to:props];
        else [self addProperties:fsprops to:props];

        CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
        if (source) {
            NSDictionary* cgprops = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, 0, NULL));
            [self addProperties:cgprops to:props];
            CFRelease(source);
        } else [self reportErrorMessage:@"Cannot open CFImageSource" to:props];
    }];
}

- (void)addProperties:(NSDictionary *)inprops to:(NSMutableArray *)props
{
    [inprops enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) [self addProperties:obj withPrefixName:[key description] to:props];
        else [self addPropertyWithName:[key description] andValue:[obj description] to:props]; // Make sure to pass NSString!
    }];
}

- (void)addProperties:(NSDictionary *)inprops withPrefixName:(NSString *)prefix to:(NSMutableArray *)props
{
    [inprops enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) [self addProperties:obj withPrefixName:[NSString stringWithFormat:@"%@.%@", prefix, key] to:props];
        else [self addPropertyWithName:[NSString stringWithFormat:@"%@.%@", prefix, key] andValue:[obj description] to:props]; // Make sure to pass NSString!
    }];
}

- (void)reportErrorMessage:(NSString *)error to:(NSMutableArray *)props
{
    [self addPropertyWithName:@"Error" andValue:error to:props];
}

- (void)reportError:(NSError *)error to:(NSMutableArray *)props
{
    [self addPropertyWithName:@"Error" andValue:[[NSNumber numberWithInteger:[error code]] stringValue] to:props];
    [self addPropertyWithName:@"Error" andValue:[error domain] to:props];
    [self addPropertyWithName:@"Error" andValue:[error localizedDescription] to:props];
}

- (void)addPropertyWithName:(NSString *)name andValue:(NSString *)value to:(NSMutableArray *)props
{
    // Remove new lines (crash when sorting)
    value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    [props addObject:@{@"name": name, @"value": value}];
}

@end
