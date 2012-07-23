//
//  AudioQueue.h
//  Radio
//
//  Copyright 2011 Yakamoz Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AudioPacket;

@interface AudioQueue : NSObject

- (AudioPacket *)pop;
- (AudioPacket *)peak;
- (void)addPacket:(AudioPacket *)packet;
- (void)removeAllPackets;
- (NSUInteger)count;

@end
