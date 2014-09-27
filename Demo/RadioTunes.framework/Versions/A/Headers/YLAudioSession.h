//
//  YLAudioSession.h
//  RadioTunes
//
//  Copyright (c) 2013 Yakamoz Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Implement this delegate if you want to get notified about Audio Session interruptions
/// or Audio Route changes.
@protocol YLAudioSessionDelegate<NSObject>
@optional
/// Called after the audio session is interrupted.
- (void)beginInterruption;

/// Called after the audio session interruption ends, with flags indicating the state of the audio session.
/// @param flags Flags indicating the state of the audio session when this method is called.
- (void)endInterruptionWithFlags:(NSUInteger)flags;

/// Called after the availability of audio input changes on a device.
/// @param isInputAvailable YES if audio input is now available, or NO if it is not.
- (void)inputIsAvailableChanged:(BOOL)isInputAvailable;

/// Called when headphones are unplugged.
- (void)headphoneUnplugged;
@end

typedef enum {
    kNetworkConnectionTypeAll=0,
    kNetworkConnectionTypeWWAN,
    kNetworkConnectionTypeWiFi
} YLNetworkConnectionType;

/// YLAudioSession is a wrapper around AVAudioSession and provides extra functionality like notifications when
/// headphones are unplugged. You can register as many delegates as you want everywhere you want to receive
/// notifications about audio session changes.
@interface YLAudioSession : NSObject

/** @name Initialization */
/// Returns a reference to the singleton YLAudioSession instance.
/// @returns An initialized YLAudioSession instance.
+ (YLAudioSession *)sharedInstance;

/// Initializes the global audio session with the right audio category. This function should be called only once.
- (void)startAudioSession;


/** @name Delegate Methods */
/// Adds a delegate object.
/// @param delegate The delegate object.
- (void)addDelegate:(id)delegate;

/// Removes a delegate object.
/// @param delegate The delegate object.
- (void)removeDelegate:(id)delegate;


/** @name Bandwidth Methods */
/// Reports the bandwidth usage for a specific network connection type.
/// @returns The number of bytes consumed using the specified network connection type.
/// @param type Network connection type.
- (UInt64)bandwidthUsageForConnectionType:(YLNetworkConnectionType)type;

/// Resets the bandwidth usage for all network connection types.
- (void)resetBandwidth;

/// Resets the bandwidth usage for the specified network connection type.
/// @param type Network connection type.
- (void)resetBandwidthForConnectionType:(YLNetworkConnectionType)type;


// This function are internal and are only used by YLHTTPRadio and YLMMSRadio!
- (void)reportBytes:(NSUInteger)length forConnectionType:(YLNetworkConnectionType)type;

@end
