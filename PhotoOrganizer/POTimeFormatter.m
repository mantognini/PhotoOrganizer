//
//  POTimeFormatter.m
//  PhotoOrganizer
//
//  Created by Marco Antognini on 18/10/13.
//  Copyright (c) 2013 local. All rights reserved.
//

#import "POTimeFormatter.h"

@implementation POTimeFormatter

- (NSString *)format:(NSString *)input
{
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:self.inputFormat];

    NSDate *inputDate = [formater dateFromString:input];

    /* DOESN'T WORK

    // Ugly hack to get a time interval from a date
    // Because if the year/month/... are not set by the user in the shift
    // a default value is set and can be random (currently it set it to 2000-01-01...)
    NSTimeInterval shiftInterval = 0;
    [formater setDateFormat:self.shiftFormat];
    NSDate *shiftDate = [formater dateFromString:self.shiftInput];
    if (shiftDate != nil) {
        // Get the ref date + 1 sec
        [formater setDateFormat:@"s"];
        NSDate *refDate = [formater dateFromString:@"1"];
        NSTimeInterval refInterval = [refDate timeIntervalSince1970] - 1;
        shiftInterval = [shiftDate timeIntervalSince1970];
        shiftInterval -= refInterval;
    }
    */

    NSDate *outputDate = [inputDate dateByAddingTimeInterval:[self.shift doubleValue]];

    [formater setDateFormat:self.outputFormat];
    NSString *output = [formater stringFromDate:outputDate];
    return output;
}

@end
