//
//  YLRadioBase.h
//  RadioTunesBinary
//
//  Created by Kemal Taskin on 28/10/14.
//  Copyright (c) 2014 Yakamoz Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "YLAudioQueue.h"

#define NUM_AQ_BUFS             3       // Number of audio queue buffers.
#define AQ_MAX_PACKET_DESCS     256     // Maximum number of audio packet descriptions.
#define AQ_DEFAULT_BUF_SIZE     4096    // Default audio queue buffer size.

typedef struct YLQueueBuffer {
    AudioQueueBufferRef mQueueBuffer;
    AudioStreamPacketDescription *mPacketDescriptions;
    UInt32 mPacketDescriptionCount;
} YLQueueBuffer;

typedef YLQueueBuffer *YLQueueBufferRef;

typedef struct YLPlayerState {
    AudioFileStreamID mStreamID;
    AudioStreamBasicDescription mAudioFormat;
    AudioQueueRef mQueue;
    YLQueueBufferRef mQueueBuffers[NUM_AQ_BUFS];
    __unsafe_unretained YLAudioQueue *mAudioQueue;
    BOOL mStarted;
    BOOL mPlaying;
    BOOL mPaused;
    BOOL mBuffering;
    BOOL mRecording;
    int mBufferSize;
    NSUInteger mBufferInSeconds;
    unsigned long long mTotalBytes;
    float mGain;
} YLPlayerState;

typedef enum {
    kRadioStateStopped = 0,
    kRadioStateConnecting,
    kRadioStateBuffering,
    kRadioStatePlaying,
    kRadioStateError
} YLRadioState;

typedef enum {
    kRadioErrorNone = 0,
    kRadioErrorPlaylistParsing,
    kRadioErrorPlaylistMMSStreamDetected,
    kRadioErrorFileStreamGetProperty,
    kRadioErrorFileStreamOpen,
    kRadioErrorAudioQueueCreate,
    kRadioErrorAudioQueueBufferCreate,
    kRadioErrorAudioQueueEnqueue,
    kRadioErrorAudioQueueStart,
    kRadioErrorDecoding,
    kRadioErrorHostNotReachable,
    kRadioErrorNetworkError,
    kRadioErrorUnsupportedStreamFormat
} YLRadioError;

@interface YLRadioBase : NSObject {
    YLPlayerState playerState;
}

/// Current radio state.
@property (nonatomic, readwrite) YLRadioState radioState;

/// Current radio error type.
@property (nonatomic, readwrite) YLRadioError radioError;

@end
