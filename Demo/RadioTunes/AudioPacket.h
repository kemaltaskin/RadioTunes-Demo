//
//  AudioPacket.h
//  Radio
//
//  Copyright 2011 Yakamoz Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AudioPacket : NSObject {
    NSData *_data;
    AudioStreamPacketDescription _audioDescription;
    
    NSUInteger _consumedLength;
}

@property (nonatomic, retain) NSData *data;
@property (nonatomic, assign) AudioStreamPacketDescription audioDescription;

- (id)initWithData:(NSData *)data;

- (NSUInteger)length;
- (NSUInteger)remainingLength;
- (void)copyToBuffer:(void *const)buffer size:(int)size;

@end
