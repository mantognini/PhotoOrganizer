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

- (id)init
{
    self = [super init];
    if (self) {
        // Init own (strong) attributes
        self.urls = [NSMutableArray array];
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
}

- (IBAction)info:(id)sender
{
    // Toggle info window visibility
    if ([self.infoPanel isVisible]) [self.infoPanel orderOut:self];
    else [self.infoPanel orderFront:self];
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
    [self.currentImageData setSelectedObjects:nil]; // We don't want everything to be selected
}

- (void)loadPropertiesForUrls:(NSArray *)urls
{
    // For each URL...
    NSFileManager *fs = [NSFileManager defaultManager];
    [urls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSURL *url = obj;

        // ...make sure we haven't already loaded it
        if ([self.urls containsObject:url]) return;
        [self.urls addObject:url];

        // ...then create data container (empty yet)
        NSMutableArray *props = [NSMutableArray array];
        [self.imagesData addObject:@{@"url": url, @"props": props}];

        // ...ask the fs for basic file attributes
        NSError *error = nil;
        NSDictionary *fsprops = [fs attributesOfItemAtPath:url.relativePath error:&error];
        if (error) [self reportError:error to:props];
        else [self addProperties:fsprops to:props];

        // ...and ask CG for more attributes
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
    // Load inprops{key, value} into props
    [inprops enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) [self addProperties:obj withPrefixName:[key description] to:props]; // Unpack dictionary!
        else [self addPropertyWithName:[key description] andValue:[obj description] to:props]; // Make sure to pass NSString!
    }];
}

- (void)addProperties:(NSDictionary *)inprops withPrefixName:(NSString *)prefix to:(NSMutableArray *)props
{
    // Load inprops{key, value} into props with a prefix (unpacking dictionary)
    [inprops enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) [self addProperties:obj withPrefixName:[NSString stringWithFormat:@"%@.%@", prefix, key] to:props];
        else [self addPropertyWithName:[NSString stringWithFormat:@"%@.%@", prefix, key] andValue:[obj description] to:props]; // Make sure to pass NSString!
    }];
}

- (void)reportErrorMessage:(NSString *)error to:(NSMutableArray *)props
{
    // Display error as a property...
    [self addPropertyWithName:@"Error" andValue:error to:props];
}

- (void)reportError:(NSError *)error to:(NSMutableArray *)props
{
    // Display error as a property...
    [self addPropertyWithName:@"Error" andValue:[[NSNumber numberWithInteger:[error code]] stringValue] to:props];
    [self addPropertyWithName:@"Error" andValue:[error domain] to:props];
    [self addPropertyWithName:@"Error" andValue:[error localizedDescription] to:props];
}

- (void)addPropertyWithName:(NSString *)name andValue:(NSString *)value to:(NSMutableArray *)props
{
    // Remove new lines (crash when sorting)
    value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

    // Finaly! add {name} and {value} data
    [props addObject:@{@"name": name, @"value": value}];
}

@end
