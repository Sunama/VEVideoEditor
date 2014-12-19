//
//  Utilities.h
//  VideoEditor
//
//  Created by Apple Macintosh on 7/12/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject

+ (NSString *)minutesWithSeconds:(float)seconds;
+ (NSString *)bundlePath:(NSString *)fileName;
+ (NSString *)documentsPath:(NSString *)fileName;
+ (NSURL *)urlBundlePath:(NSString *)fileName;
+ (NSURL *)urlDocumentsPath:(NSString *)fileName;
+ (int)generateRandomNumberWithlowerBound:(int)lowerBound upperBound:(int)upperBound;

@end
