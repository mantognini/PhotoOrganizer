//
//  POImageData.h
//  PhotoOrganizer
//
//  Created by Marco Antognini on 5/10/13.
//  Copyright (c) 2013 local. All rights reserved.
//

#import <Foundation/Foundation.h>

// Kind of dictionary with keys:
// {url, props, dir, origName, previewName}
// {props} is NSMutableArray{key, value}

@interface POImageData : NSObject

@property (strong) NSURL *url;
@property (strong) NSMutableArray *props;
@property (strong) NSURL *dir;
@property (strong) NSString *origName;
@property (strong) NSString *previewName;

+ (id)imageDataForUrl:(NSURL *)url;

@end
