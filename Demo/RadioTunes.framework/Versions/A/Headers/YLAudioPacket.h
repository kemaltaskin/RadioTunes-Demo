//
//  AudioPacket.h
//  RadioTunes
//
//  Copyright 2011 Yakamoz Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/// Custom object that encapsulates audio data and the relevant audio packet description.
@interface YLAudioPacket : NSObject

/// Audio data.
@property (nonatomic, retain) NSData *data;

/// Audio packet description.
@property (nonatomic, assign) AudioStreamPacketDescription audioDescription;


/** @name Initialization Methods */
/// Initializes a YLAudioPacket object and returns it to the caller.
/// @returns An initialized YLAudioPacket instance.
/// @param data NSData that contains audio data.
- (id)initWithData:(NSData *)data;


/** @name Length Methods */
/// @returns Length of the audio data.
- (NSUInteger)length;

/// @returns Length of the remaining audio data that's not consumed yet.
- (NSUInteger)remainingLength;
 

/** @name Memory Methods */
/// Copies a number of bytes into a given buffer.
/// @returns Number of bytes copied.
/// @param buffer A buffer into which to copy data.
/// @param size The number of bytes to copy to buffer.
- (NSInteger)copyToBuffer:(void *const)buffer size:(NSInteger)size;

/// Copies a number of bytes into two given buffers.
/// @returns Number of bytes copied.
/// @param firstBuffer A buffer into which to copy data.
/// @param secondBuffer A buffer into which to copy data.
/// @param size The number of bytes to copy to buffer.
- (NSInteger)copyToBuffer:(void *const)firstBuffer buffer:(void *const)secondBuffer size:(NSInteger)size;

@end
