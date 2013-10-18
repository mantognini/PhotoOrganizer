//
//  POImageData.m
//  PhotoOrganizer
//
//  Created by Marco Antognini on 5/10/13.
//  Copyright (c) 2013 local. All rights reserved.
//

#import "POImageData.h"

@implementation POImageData

+ (id)imageDataForUrl:(NSURL *)url
{
    POImageData *it = [[POImageData alloc] init];

    it.url = url;
    it.props = [NSMutableArray array];
    it.dir = [url URLByDeletingLastPathComponent];
    it.origName = [url lastPathComponent];
    it.previewName = it.origName;

    // Ask the fs for basic file attributes
    NSFileManager *fs = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *fsprops = [fs attributesOfItemAtPath:url.relativePath error:&error];
    if (error) [it reportError:error];
    else [it addProperties:fsprops];

    // Ask CG for more attributes
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (source) {
        NSDictionary* cgprops = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, 0, NULL));
        [it addProperties:cgprops];
        CFRelease(source);
    } else [it reportErrorMessage:@"Cannot open CFImageSource"];

    return it;
}

- (NSString *)valueForProperty:(NSString *)key
{
    NSUInteger index = [self.props indexOfObjectPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        return [[obj objectForKey:@"name"] isEqualToString:key];
    }];

    if (index == NSNotFound) {
        return nil;
    } else {
        return [[self.props objectAtIndex:index] objectForKey:@"value"];
    }
}

- (void)addProperties:(NSDictionary *)inprops
{
    // Load inprops{key, value} into props
    [inprops enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) [self addProperties:obj withPrefixName:[key description]]; // Unpack dictionary!
        else [self addPropertyWithName:[key description] andValue:[obj description]]; // Make sure to pass NSString!
    }];
}

- (void)addProperties:(NSDictionary *)inprops withPrefixName:(NSString *)prefix
{
    // Load inprops{key, value} into props with a prefix (unpacking dictionary)
    [inprops enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) [self addProperties:obj withPrefixName:[NSString stringWithFormat:@"%@.%@", prefix, key]];
        else [self addPropertyWithName:[NSString stringWithFormat:@"%@.%@", prefix, key] andValue:[obj description]]; // Make sure to pass NSString!
    }];
}

- (void)reportErrorMessage:(NSString *)error
{
    // Display error as a property...
    [self addPropertyWithName:@"Error" andValue:error];
}

- (void)reportError:(NSError *)error
{
    // Display error as a property...
    [self addPropertyWithName:@"Error" andValue:[[NSNumber numberWithInteger:[error code]] stringValue]];
    [self addPropertyWithName:@"Error" andValue:[error domain]];
    [self addPropertyWithName:@"Error" andValue:[error localizedDescription]];
}

- (void)addPropertyWithName:(NSString *)name andValue:(NSString *)value
{
    // Remove new lines (crash when sorting)
    value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

    // Finaly! add {name} and {value} data
    [self.props addObject:@{@"name": name, @"value": value}];
}


/// QLPreviewItem protocol

- (NSURL *)previewItemURL
{
    return self.url;
}

@end
