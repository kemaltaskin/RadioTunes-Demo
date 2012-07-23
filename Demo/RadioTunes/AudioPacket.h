//
//  AudioPacket.h
//  Radio
//
//  Copyright 2011 Yakamoz Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AudioPacket : NSObject

@property (nonatomic, retain) NSData *data;
@property (nonatomic, assign) AudioStreamPacketDescription audioDescription;

- (id)initWithData:(NSData *)data;

- (NSUInteger)length;
- (NSUInteger)remainingLength;
- (void)copyToBuffer:(void *const)buffer size:(int)size;

@end
