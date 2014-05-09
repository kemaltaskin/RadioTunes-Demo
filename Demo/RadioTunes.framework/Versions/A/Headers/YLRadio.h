//
//  Radio.h
//  RadioTunes
//
//  Copyright 2011 Yakamoz Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
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

typedef enum {
    kRadioConnectionTypeNone = 0,
    kRadioConnectionTypeWWAN,
    kRadioConnectionTypeWiFi
} YLRadioConnectionType;

typedef enum {
    kRadioRecordingInitializationError = 0,
    kRadioRecordingFileError,
    kRadioRecordingFormatError,
    kRadioRecordingWriteError
} YLRadioRecordingError;

typedef enum {
    kRadioMeteringInitializationError = 0,
    kRadioMeteringStateError,
    kRadioMeteringQueryError
} YLRadioMeteringError;

extern NSString *YLRadioTunesErrorDomain;

@protocol YLRadioDelegate;
@class YLReachability;

/// Base class extended by YLHTTPRadio and YLMMSRadio.
@interface YLRadio : NSObject {
    NSURL *_url;
    NSString *_filePath;
    
    NSString *_radioTitle;
    NSString *_radioName;
    NSString *_radioGenre;
    NSString *_radioUrl;
    
    YLPlayerState _playerState;
    YLRadioState _radioState;
    YLRadioError _radioError;
    
    NSObject<YLRadioDelegate> *_delegate;
    
    BOOL _shutdown;
    BOOL _waitingForReconnection;
    BOOL _connectionError;
    int _buffersInUse;
    
    UIBackgroundTaskIdentifier _bgTask;
    NSTimer *_bufferTimer;
    NSTimer *_reconnectTimer;
    dispatch_queue_t _lockQueue;
    
    YLReachability *_reachability;
    YLRadioConnectionType _connectionType;
}

/// This url can be different than the one you passed in initWithURL. If a playlist is detected this property
/// will contain the first url detected by the playlist parser.
@property (nonatomic, readonly) NSURL *url;

/// Current radio state.
@property (nonatomic, readonly) YLRadioState radioState;

/// Current radio error type.
@property (nonatomic, readonly) YLRadioError radioError;

/// Title of currently playing song (if provided by Shoutcast metadata).
@property (nonatomic, retain, readonly) NSString *radioTitle;

/// Name of the radio station (if provided by Shoutcast metadata).
@property (nonatomic, retain, readonly) NSString *radioName;

/// Genre of the radio station (if provided by Shoutcast metadata).
@property (nonatomic, retain, readonly) NSString *radioGenre;

/// Website of the radio station (if provided by Shoutcast metadata).
@property (nonatomic, retain, readonly) NSString *radioUrl;

/// Reference to the delegate object.
@property (nonatomic, assign) NSObject<YLRadioDelegate> *delegate;


/** @name Initialization Methods */
/// Initializes a YLRadio object and returns it to the caller.
/// @returns An initialized YLRadio object.
/// @param url Url of the radio station.
- (id)initWithURL:(NSURL *)url;

/** @name Playback Methods */
/// This function should be called before you release a radio object.
- (void)shutdown;

/// Start playback.
- (void)play;

/// Stop playback.
- (void)pause;


/** @name Recording Methods */
/// Start recording to the specified file path.
/// @param filePath Filesystem path.
- (void)startRecordingWithDestination:(NSString *)filePath;

/// Stop recording.
- (void)stopRecording;

/// Returns the appropriate filename extension that should be used for recording.
/// @returns Filename extension.
- (NSString *)fileExtensionHint;


/** @name State Methods */
/// @returns YES if radio is playing.
- (BOOL)isPlaying;

/// @returns YES if radio playback has stopped.
- (BOOL)isPaused;

/// @returns YES if radio is buffering.
- (BOOL)isBuffering;

/// @returns YES if radio is recording.
- (BOOL)isRecording;


/** @name Tuning Methods */
/// Sets the number of seconds that should be buffered before playback starts. Default value is 2 seconds.
/// @param seconds Number of seconds. Should be a value between 1 and 30.
- (void)setBufferInSeconds:(NSUInteger)seconds;

/// Sets the volume. Default value is 0.5.
/// @param volume A value between 0.0 and 1.0.
- (void)setVolume:(float)volume;


/** @name Level Metering Methods */
/// This method should be called when the radio object is in the kRadioStatePlaying state.
/// @returns Number of channels. When there's an error the returned value will be -1.
/// @param error NSError object describing the error if any.
- (NSInteger)enableLevelMetering:(NSError **)error;

/// Returns the current level meter values in decibels.
/// @param levels Array of AudioQueueLevelMeterState structures, 1 per channel. Use the value returned
/// by the enableLevelMetering method to allocate an array with the right size.
/// @param error NSError object describing the error if any.
- (void)currentLevelMeterDB:(AudioQueueLevelMeterState *)levels error:(NSError **)error;

@end


/// Implement this delegate to get notified about radio state changes and audio recording.
@protocol YLRadioDelegate<NSObject>
@required
/// Called when the radio state has changed.
/// @param radio The YLRadio object informing the delegate
- (void)radioStateChanged:(YLRadio *)radio;

@optional
/// Called when recording has started.
/// @param radio The YLRadio object informing the delegate.
/// @param path Filesystem path of the recorded file.
- (void)radio:(YLRadio *)radio didStartRecordingWithDestination:(NSString *)path;

/// Called when recording has stopped.
/// @param radio The YLRadio object informing the delegate.
/// @param path Filesystem path of the recorded file.
- (void)radio:(YLRadio *)radio didStopRecordingWithDestination:(NSString *)path;

/// Called when recording has failed.
/// @param radio The YLRadio object informing the delegate.
/// @param error NSError object describing the error.
- (void)radio:(YLRadio *)radio recordingFailedWithError:(NSError *)error;

/// Called when the Shoutcast metadata is parsed.
/// @param radio The YLRadio object informing the delegate.
- (void)radioMetadataReady:(YLRadio *)radio;

/// Called when the currenly playing song has changed.
/// @param radio The YLRadio object informing the delegate.
- (void)radioTitleChanged:(YLRadio *)radio;

@end
