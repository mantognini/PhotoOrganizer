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
		self.imageUrls = [panel URLs];
        [self loadProperties];
    } else {
        self.imageUrls = [NSArray array];
        [self clearProperties];
    }
}

- (void)loadProperties
{
    [self clearProperties];

    NSFileManager *fs = [NSFileManager defaultManager];
    NSError *error = nil;
    NSURL *url = [self.imageUrls objectAtIndex:0];
    NSDictionary *props = [fs attributesOfItemAtPath:url.relativePath error:&error];
    if (error) return [self reportError:error];
    else [self displayProperties:props];

    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (source) {
        NSDictionary* props = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, 0, NULL));
        [self displayProperties:props];
        CFRelease(source);
    } else return [self reportErrorMessage:@"Cannot open CFImageSource"];
}

- (void)displayProperties:(NSDictionary *)props
{
    [props enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) [self displayProperties:obj withPrefixName:[key description]];
        else [self addPropertyWithName:[key description] andValue:[obj description]]; // Make sure to pass NSString!
    }];
}

- (void)displayProperties:(NSDictionary *)props withPrefixName:(NSString *)prefix
{
    [props enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) [self displayProperties:obj withPrefixName:[NSString stringWithFormat:@"%@.%@", prefix, key]];
        else [self addPropertyWithName:[NSString stringWithFormat:@"%@.%@", prefix, key] andValue:[obj description]]; // Make sure to pass NSString!
    }];
}

- (void)reportErrorMessage:(NSString *)error
{
    [self addPropertyWithName:@"Error" andValue:error];
}

- (void)reportError:(NSError *)error
{
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
