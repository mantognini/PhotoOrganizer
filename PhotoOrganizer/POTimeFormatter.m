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

//    NSDate *shiftDate = [formater dateFromString:self.shiftDate];
//    NSDate *outputDate = [origineDate dat]
//    NSString *formatedTime =

    NSDate *outputDate = inputDate;

    [formater setDateFormat:self.outputFormat];
    NSString *output = [formater stringFromDate:outputDate];
    return output;
}

@end
