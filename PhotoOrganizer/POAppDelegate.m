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
    self.imageUrl = [NSURL URLWithString:@"Browsing"];

    // Open a browser panel
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setFloatingPanel:YES];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setTitle:@"Select an Image"];
    [panel setAllowedFileTypes:@[(__bridge NSString *)kUTTypeImage]];

    // Browse
	NSInteger i = [panel runModal];
	if (i == NSOKButton) {
		self.imageUrl = [[panel URLs] lastObject];
        [self loadProperties];
    } else {
        self.imageUrl = [NSURL URLWithString:@"No image"];
        [self clearProperties];
    }
}

- (void)loadProperties
{
    NSFileManager *fs = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *props = [fs attributesOfItemAtPath:self.imageUrl.relativePath error:&error];
    if (error) [self report:error];
    else [self displayProperties:props];
}

- (void)displayProperties:(NSDictionary *)props
{
    [self clearProperties];
    [props enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        // Make sure to pass NSString!
        [self addPropertyWithName:[key description] andValue:[obj description]];
    }];
}

- (void)report:(NSError *)error
{
    [self clearProperties];
    [self addPropertyWithName:@"Error" andValue:[[NSNumber numberWithInteger:[error code]] stringValue]];
    [self addPropertyWithName:@"Error" andValue:[error domain]];
    [self addPropertyWithName:@"Error" andValue:[error localizedDescription]];
}

- (void)clearProperties
{
    [self.imageProperties removeAll];
}

- (void)addPropertyWithName:(NSString *)name andValue:(NSString *)value
{
    // Remove new lines (crash when sorting)
    value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    [self.imageProperties addObject:@{@"name": name, @"value": value}];
}

@end
