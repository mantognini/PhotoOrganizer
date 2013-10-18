//
//  POTimeFormatter.h
//  PhotoOrganizer
//
//  Created by Marco Antognini on 18/10/13.
//  Copyright (c) 2013 local. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POTimeFormatter : NSObject

@property NSString *inputFormat;
@property NSString *shiftFormat;
@property NSString *outputFormat;

@property NSString *shiftInput;

- (NSString *)format:(NSString *)input; // gives «output»

@end
