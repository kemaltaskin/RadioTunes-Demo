//
//  AudioQueue.h
//  RadioTunes
//
//  Copyright 2011 Yakamoz Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YLAudioPacket;

/// Custom FIFO array implementation that keeps track of YLAudioPacket objects.
@interface YLAudioQueue : NSObject

/// Removes and returns the oldest YLAudioPacket object. You should release the returned
/// object when you don't need it anymore!
/// @returns YLAudioPacket object.
- (YLAudioPacket *)pop;

/// Returns a reference to the oldest YLAudioPacket object.
/// @returns YLAudioPacket object.
- (YLAudioPacket *)peak;

/// Adds a YLAudioPacket object to the queue.
/// @param packet YLAudioPacket object.
- (void)addPacket:(YLAudioPacket *)packet;

/// Removes all YLAudioPacket objects in the queue.
- (void)removeAllPackets;

/// @returns Number of YLAudioPacket objects in the queue.
- (NSUInteger)count;

@end
