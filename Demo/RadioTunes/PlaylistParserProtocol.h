//
//  PlaylistParserProtocol.h
//  RadioKit
//
//  Copyright 2011 Yakamoz Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlaylistParserProtocol <NSObject>
- (NSString *)parseStreamUrl:(NSData *)httpData;
@end
