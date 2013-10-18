//
//  POImageData.h
//  PhotoOrganizer
//
//  Created by Marco Antognini on 5/10/13.
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

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

// Kind of dictionary with keys:
// {url, props, dir, origName, previewName}
// {props} is NSMutableArray{key, value}

@interface POImageData : NSObject <QLPreviewItem>

@property (strong) NSURL *url;
@property (strong) NSMutableArray *props;
@property (strong) NSURL *dir;
@property (strong) NSString *origName;
@property (strong) NSString *previewName;

+ (id)imageDataForUrl:(NSURL *)url;

- (NSString *)valueForProperty:(NSString *)key;

@end
