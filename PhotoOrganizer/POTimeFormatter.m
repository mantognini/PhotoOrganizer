//
//  POTimeFormatter.m
//  PhotoOrganizer
//
//  Created by Marco Antognini on 18/10/13.
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
