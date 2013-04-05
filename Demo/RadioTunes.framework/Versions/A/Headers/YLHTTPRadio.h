//
//  HTTPRadio.h
//  RadioTunes
//
//  Copyright 2011 Yakamoz Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLRadio.h"
#import "YLPlaylistParserProtocol.h"

typedef enum {
    kPlaylistNone = 0,
    kPlaylistM3U,
    kPlaylistPLS,
    kPlaylistXSPF,
    kPlaylistASX
} YLPlaylistType;

typedef enum {
    kHTTPStatePlaylistParsing = 0,
    kHTTPStateAudioStreaming
} YLHTTPState;

/// Radio class for streaming http radio stations. Use this class if the radio url starts with http or https.
@interface YLHTTPRadio : YLRadio

/// Change the http user agent string if needed.
@property (nonatomic, copy) NSString *httpUserAgent;

/// Change the http timeout value if needed. Default value is 30 seconds.
@property (nonatomic, assign) NSUInteger httpTimeout;

@end
