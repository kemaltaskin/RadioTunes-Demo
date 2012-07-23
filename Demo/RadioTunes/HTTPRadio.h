//
//  HTTPRadio.h
//  Radio
//
//  Copyright 2011 Yakamoz Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Radio.h"
#import "PlaylistParserProtocol.h"

typedef enum {
    kPlaylistNone = 0,
    kPlaylistM3U,
    kPlaylistPLS,
    kPlaylistXSPF
} PlaylistType;

typedef enum {
    kHTTPStatePlaylistParsing = 0,
    kHTTPStateAudioStreaming
} HTTPState;

@interface HTTPRadio : Radio

@property (nonatomic, copy) NSString *httpUserAgent;
@property (nonatomic, assign) NSUInteger httpTimeout;

@end
