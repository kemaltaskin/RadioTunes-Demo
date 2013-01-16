//
//  AudioConverter.h
//  RadioTunes
//
//  Copyright (c) 2013 Yakamoz Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

// YLAudioConverter will encode PCM audio data into AAC.
@interface YLAudioConverter : NSObject

@property (nonatomic, readonly) char *audioBuffer;

+ (BOOL)AudioConverterAvailable;

- (id)initWithAudioFormat:(AudioStreamBasicDescription)audioFormat bufferSize:(int)bufferSize;

- (BOOL)startWithDestination:(NSString *)destination error:(NSError **)error;

- (BOOL)writeBytesWithLength:(int)length error:(NSError **)error;

- (void)finish;

@end
