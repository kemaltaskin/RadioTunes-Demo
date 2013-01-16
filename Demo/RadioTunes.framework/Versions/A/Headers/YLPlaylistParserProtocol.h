//
//  YLPlaylistParserProtocol.h
//  RadioKit
//
//  Copyright 2011 Yakamoz Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Protocol implemented by all playlist parsers.
@protocol YLPlaylistParserProtocol <NSObject>
/// Parses a HTTP response object and extracts the audio stream url.
/// @param httpData HTTP response data.
/// @returns A single url in string format.
- (NSString *)parseStreamUrl:(NSData *)httpData;
@end
