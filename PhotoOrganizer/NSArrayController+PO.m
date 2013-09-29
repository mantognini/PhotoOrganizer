//
//  NSArrayController+PO.m
//  PhotoOrganizer
//
//  Created by Marco Antognini on 29/9/13.
//  Copyright (c) 2013 local. All rights reserved.
//

#import "NSArrayController+PO.h"

@implementation NSArrayController (PO)

- (void)removeAllObjects
{
    NSRange range = NSMakeRange(0, [[self arrangedObjects] count]);
    [self removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
}

@end
