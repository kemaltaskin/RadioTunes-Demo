//
//  MainViewController.m
//
//  Copyright 2011 Yakamoz Labs. All rights reserved.
//

#import "MainViewController.h"
#import "RecordingsViewController.h"
#import "LicenseViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MainViewController()<UIAlertViewDelegate> {
    NSInteger _currentRadio;
    NSInteger _recordingCounter;
    
    NSString *_documentsPath;
    
    YLRadio *_radio;
    BOOL _interruptedDuringPlayback;
    AudioQueueLevelMeterState *_levels;
    
    NSMutableArray *_radioStations;
    NSMutableArray *_radioNames;
    NSMutableArray *_radioSubtitles;
    NSMutableArray *_recordings;
}

- (void)recordingsTapped;
- (void)playButtonTapped;
- (void)recordButtonTapped;
- (void)volumeSliderMoved:(id)sender;

@end

@implementation MainViewController

@synthesize tableview = _tableview;
@synthesize bgImageView = _bgImageView;
@synthesize volumeSlider = _volumeSlider;
@synthesize playButton = _playButton;
@synthesize recordButton = _recordButton;
@synthesize statusLabel = _statusLabel;
@synthesize titleLabel = _titleLabel;

- (id)init {
    self = [super initWithNibName:@"MainView" bundle:nil];
    if (self) {
        self.title = @"RadioTunes";
        
        UIBarButtonItem *rButton = [[[UIBarButtonItem alloc] initWithTitle:@"Recordings"
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self
                                                                    action:@selector(recordingsTapped)] autorelease];
        self.navigationItem.rightBarButtonItem = rButton;
        
        _radio = nil;
        _currentRadio = -1;
        _recordingCounter = 1;
        _levels = NULL;
        
        _radioStations = [[NSMutableArray alloc] init];
        _radioNames = [[NSMutableArray alloc] init];
        _radioSubtitles = [[NSMutableArray alloc] init];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _documentsPath = [[paths objectAtIndex:0] retain];
        NSString *recPlist = [_documentsPath stringByAppendingPathComponent:@"recordings.plist"];
        if([[NSFileManager defaultManager] fileExistsAtPath:recPlist]) {
            id recordings = [NSKeyedUnarchiver unarchiveObjectWithFile:recPlist];
            if(recordings) {
                _recordings = [[NSMutableArray arrayWithArray:(NSArray *)recordings] retain];
            }
        }
        
        if(_recordings == nil) {
            _recordings = [[NSMutableArray alloc] init];
        }
        
        _recordingCounter = [_recordings count] + 1;
        
        [_radioNames addObject:@"CNN TV"];
        [_radioSubtitles addObject:@"mms wma stream"];
        [_radioStations addObject:@"mmsh://a466.l3760630465.c37606.g.lm.akamaistream.net/D/466/37606/v0001/reflector:30465"];
        
        [_radioNames addObject:@"BBC Radio 1"];
        [_radioSubtitles addObject:@"http asx mms wma stream"];
        [_radioStations addObject:@"http://www.bbc.co.uk/radio/listen/live/r1.asx"];
        
        [_radioNames addObject:@"Boost.FM"];
        [_radioSubtitles addObject:@"http mp3 stream"];
        [_radioStations addObject:@"http://108.168.244.242:8000/stream/1/"];
        
        [_radioNames addObject:@"Soundtracks"];
        [_radioSubtitles addObject:@"http pls mp3 stream"];
        [_radioStations addObject:@"http://yp.shoutcast.com/sbin/tunein-station.pls?id=5266"];
        
        [_radioNames addObject:@"Radio Javan"];
        [_radioSubtitles addObject:@"http mp3 stream"];
        [_radioStations addObject:@"http://stream.radiojavan.com/radiojavan"];
        
        [_radioNames addObject:@"Power FM"];
        [_radioSubtitles addObject:@"http aac+ stream"];
        [_radioStations addObject:@"http://sc.powergroup.com.tr:80/PowerFM/aac/128/tunein"];
        
        [_radioNames addObject:@"181.FM Chilled"];
        [_radioSubtitles addObject:@"http mp3 pls stream"];
        [_radioStations addObject:@"http://www.181.fm/winamp.pls?station=181-chilled&style=mp3&description=Chilled%20Out&file=181-chilled.pls"];
        
        [[YLAudioSession sharedInstance] addDelegate:self];
    }
    
    return self;
}

- (void)dealloc {
    [[YLAudioSession sharedInstance] removeDelegate:self];
    [_radio setDelegate:nil];
    [_radio release];
    
    [_tableview release];
    [_bgImageView release];
    [_volumeSlider release];
    [_playButton release];
    [_statusLabel release];
    [_titleLabel release];
    
    [_radioStations release];
    [_radioNames release];
    [_radioSubtitles release];
    [_recordings release];
    [_documentsPath release];
    
    if(_levels != NULL) {
        free(_levels);
        _levels = NULL;
    }
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    
    if([[UIScreen mainScreen] scale] >= 2.0 && [[UIScreen mainScreen] bounds].size.height > 480) {
        [_bgImageView setImage:[UIImage imageNamed:@"bg-i5.png"]];
    }
    
    [_playButton addTarget:self action:@selector(playButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_recordButton addTarget:self action:@selector(recordButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    _recordButton.enabled = NO;
    [_statusLabel setText:@""];
    [_titleLabel setText:@""];
    
    [_volumeSlider setThumbImage:[UIImage imageNamed:@"knob.png"] forState:UIControlStateNormal];
	[_volumeSlider setMinimumTrackImage:[[UIImage imageNamed:@"scrub_left.png"] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{0.0,6.0,0.0,6.0}")]
                               forState:UIControlStateNormal];
	[_volumeSlider setMaximumTrackImage:[[UIImage imageNamed:@"scrub_right.png"] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{0.0,6.0,0.0,6.0}")]
                               forState:UIControlStateNormal];
	[_volumeSlider addTarget:self action:@selector(volumeSliderMoved:) forControlEvents:UIControlEventValueChanged];
    
    NSString *message = @"The demo version of RadioTunes SDK has a time limit of 2 minutes!";
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"RadioTunes SDK"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                           otherButtonTitles:@"License", nil] autorelease];
    [alert show];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    if(event.type == UIEventTypeRemoteControl) {
        switch(event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                if(_radio) {
                    if([_radio isPlaying]) {
                        [_radio pause];
                    } else {
                        [_radio play];
                    }
                }
                break;
            case UIEventSubtypeRemoteControlPause:
                if(_radio && [_radio isPlaying]) {
                    [_radio pause];
                }
                break;
            case UIEventSubtypeRemoteControlPlay:
                if(_radio && [_radio isPaused]) {
                    [_radio play];
                }
                break;
            default:
                break;
        }
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.tableview = nil;
    self.bgImageView = nil;
    self.volumeSlider = nil;
    self.playButton = nil;
    self.statusLabel = nil;
    self.titleLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex == [alertView firstOtherButtonIndex]) {
        LicenseViewController *l = [[[LicenseViewController alloc] init] autorelease];
        [self.navigationController pushViewController:l animated:YES];
    }
}


#pragma mark -
#pragma mark YLAudioSessionDelegate
- (void)beginInterruption {
    if(_radio == nil) {
        return;
    }
    
    if([_radio isPlaying]) {
        _interruptedDuringPlayback = YES;
        [_radio pause];
    }
}

- (void)endInterruptionWithFlags:(NSUInteger)flags {
    if(_radio == nil) {
        return;
    }
    
    if(_interruptedDuringPlayback && [_radio isPaused]) {
        [_radio play];
    }
    
    _interruptedDuringPlayback = NO;
}

- (void)headphoneUnplugged {
    if(_radio == nil) {
        return;
    }
    
    if([_radio isPlaying]) {
        [_radio pause];
    }
}


#pragma mark -
#pragma mark UITableViewDataSource/UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_radioStations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSInteger row = indexPath.row;
    
    [[cell textLabel] setText:[_radioNames objectAtIndex:row]];
    [[cell detailTextLabel] setText:[_radioSubtitles objectAtIndex:row]];
    if(row == _currentRadio) {
        [cell setAccessoryView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"now_playing.png"]] autorelease]];
    } else {
        [cell setAccessoryView:nil];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == _currentRadio) {
        return;
    }
    
    if(_radio) {
        [_radio shutdown];
        [_radio release];
        _radio = nil;
    }
    
    [_statusLabel setText:@""];
    [_titleLabel setText:@""];
    
    _currentRadio = indexPath.row;
    NSString *radioUrl = [_radioStations objectAtIndex:indexPath.row];
    if([radioUrl hasPrefix:@"mms"]) {
        _radio = [[YLMMSRadio alloc] initWithURL:[NSURL URLWithString:radioUrl]];
    } else {
        _radio = [[YLHTTPRadio alloc] initWithURL:[NSURL URLWithString:radioUrl]];
    }
    
    if(_radio) {
        [_radio setDelegate:self];
        [_radio play];
    }
    
    [self.tableview reloadData];
}


#pragma mark -
#pragma mark Private Methods
- (void)recordingsTapped {
    if(_radio && [_radio isPlaying]) {
        [_radio pause];
    }
    
    RecordingsViewController *r = [[[RecordingsViewController alloc] initWithRecordings:[NSArray arrayWithArray:_recordings]] autorelease];
    [self.navigationController pushViewController:r animated:YES];
}

- (void)playButtonTapped {
    if(_radio == nil) {
        return;
    }
    
    if([_radio isPlaying]) {
        [_radio pause];
    } else {
        [_radio play];
    }
}

- (void)recordButtonTapped {
    if(_radio == nil) {
        return;
    }
    
    if(![_radio isPlaying]) {
        return;
    }
    
    if(_radio.isRecording) {
        [_recordButton setImage:[UIImage imageNamed:@"record_off.png"] forState:UIControlStateNormal];
        [_radio stopRecording];
    } else {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *filename = [NSString stringWithFormat:@"%@%ld.%@", [_radioNames objectAtIndex:_currentRadio], (long)_recordingCounter++, [_radio fileExtensionHint]];
        NSString *path = [documentsPath stringByAppendingPathComponent:filename];
        
        [_recordButton setImage:[UIImage imageNamed:@"record_on.png"] forState:UIControlStateNormal];
        [_radio startRecordingWithDestination:path];
    }
}

- (void)volumeSliderMoved:(id)sender {
    if(_radio) {
        [_radio setVolume:[_volumeSlider value]];
    }
}


#pragma mark -
#pragma mark MMSRadioDelegate Methods
- (void)radioStateChanged:(YLRadio *)radio {
    YLRadioState state = [_radio radioState];
    if(state == kRadioStateConnecting) {
        [_statusLabel setText:@"Status: Connecting"];
        [_titleLabel setText:@""];
        [_playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        [_playButton setEnabled:NO];
        [_recordButton setEnabled:NO];
    } else if(state == kRadioStateBuffering) {
        [_statusLabel setText:@"Status: Buffering"];
        [_playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        [_playButton setEnabled:YES];
        [_recordButton setEnabled:NO];
    } else if(state == kRadioStatePlaying) {
        [_statusLabel setText:@"Status: Playing"];
        [_playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        [_playButton setEnabled:YES];
        [_recordButton setEnabled:YES];
        
        /* Example code showing how you can query the current level meter in DB. */
        /* BEGIN LEVEL METERING CODE */
        /******************************
        NSError *error = nil;
        NSInteger numberOfChannels = [_radio enableLevelMetering:&error];
        if(error != nil) {
            NSLog(@"Metering error: %@", error.description);
        } else {
            NSLog(@"Metering number of channels: %ld", (long)numberOfChannels);
            if(_levels != NULL) {
                free(_levels);
                _levels = NULL;
            }
            
            _levels = (AudioQueueLevelMeterState *)malloc(sizeof(AudioQueueLevelMeterState) * numberOfChannels);
            
            // Put the following code in another function that keeps called at a certain rate with a timer.
            [_radio currentLevelMeterDB:_levels error:&error];
            if(error == nil) {
                for(NSInteger i = 0; i < numberOfChannels; i++) {
                    NSLog(@"CHAN: %ld - LEVELS: %f %f", (long)i, _levels[i].mAveragePower, _levels[i].mPeakPower);
                }
            }
        }
        ****************************/
        /* END LEVEL METERING CODE */
    } else if(state == kRadioStateStopped) {
        [_statusLabel setText:@"Status: Stopped"];
        [_playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [_playButton setEnabled:YES];
        [_recordButton setEnabled:NO];
    } else if(state == kRadioStateError) {
        YLRadioError error = [_radio radioError];
        // Special handling for ASX playlist which is parsed by YLHTTPRadio. We need to switch over to
        // YLMMSRadio if the parsed URL is a valid mms URL.
        if(error == kRadioErrorPlaylistMMSStreamDetected) {
            // copy url because it will be gone when we release our _radio instance
            NSURL *url = [[_radio url] copy];
            [_radio shutdown];
            [_radio release];
            
            _radio = [[YLMMSRadio alloc] initWithURL:url];
            [url release];
            if(_radio) {
                [_radio setDelegate:self];
                [_radio play];
            }
            
            return;
        }
        
        [_statusLabel setText:@"Status: Error"];
        [_playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [_playButton setEnabled:YES];
        [_recordButton setEnabled:NO];
        if(error == kRadioErrorAudioQueueBufferCreate) {
            [_titleLabel setText:@"Audio buffers could not be created."];
        } else if(error == kRadioErrorAudioQueueCreate) {
            [_titleLabel setText:@"Audio queue could not be created."];
        } else if(error == kRadioErrorAudioQueueEnqueue) {
            [_titleLabel setText:@"Audio queue enqueue failed."];
        } else if(error == kRadioErrorAudioQueueStart) {
            [_titleLabel setText:@"Audio queue could not be started."];
        } else if(error == kRadioErrorFileStreamGetProperty) {
            [_titleLabel setText:@"File stream get property failed."];
        } else if(error == kRadioErrorFileStreamOpen) {
            [_titleLabel setText:@"File stream could not be opened."];
        } else if(error == kRadioErrorPlaylistParsing) {
            [_titleLabel setText:@"Playlist could not be parsed."];
        } else if(error == kRadioErrorDecoding) {
            [_titleLabel setText:@"Audio decoding error."];
        } else if(error == kRadioErrorHostNotReachable) {
            [_titleLabel setText:@"Radio host not reachable."];
        } else if(error == kRadioErrorNetworkError) {
            [_titleLabel setText:@"Network connection error."];
        } else if(error == kRadioErrorUnsupportedStreamFormat) {
            [_titleLabel setText:@"Unsupported stream format."];
        }
    }
}

- (void)radio:(YLRadio *)radio didStartRecordingWithDestination:(NSString *)path {
    NSLog(@"Did start recording with destination: %@", path);
}

- (void)radio:(YLRadio *)radio didStopRecordingWithDestination:(NSString *)path {
    NSLog(@"Did stop recording with destination: %@", path);
    [_recordButton setImage:[UIImage imageNamed:@"record_off.png"] forState:UIControlStateNormal];
    NSURL *url = [NSURL fileURLWithPath:path];
    [_recordings addObject:[url lastPathComponent]];
    NSString *recPlist = [_documentsPath stringByAppendingPathComponent:@"recordings.plist"];
    [NSKeyedArchiver archiveRootObject:_recordings toFile:recPlist];
}

- (void)radio:(YLRadio *)radio recordingFailedWithError:(NSError *)error {
    // Error codes are defined in YLRadio.h: YLRadioRecordingError
    NSLog(@"Recording failed with error (code: %ld): %@", (long)error.code, error.localizedDescription);
    [_recordButton setImage:[UIImage imageNamed:@"record_off.png"] forState:UIControlStateNormal];
}

- (void)radioMetadataReady:(YLRadio *)radio {
    NSString *radioName = [radio radioName];
    NSString *radioGenre = [radio radioGenre];
    NSString *radioUrl = [radio radioUrl];
    
    if(radioName) {
        NSLog(@"Radio name: %@", radioName);
    }
    
    if(radioGenre) {
        NSLog(@"Radio genre: %@", radioGenre);
    }
    
    if(radioUrl) {
        NSLog(@"Radio url: %@", radioUrl);
    }
}

- (void)radioTitleChanged:(YLRadio *)radio {
    [_titleLabel setText:[NSString stringWithFormat:@"Now Playing: %@", [radio radioTitle]]];
    
    if(NSClassFromString(@"MPNowPlayingInfoCenter")) {
        /* we're on iOS 5, so set up the now playing center */
        NSDictionary *trackInfo = [NSDictionary dictionaryWithObject:[radio radioTitle] forKey:MPMediaItemPropertyTitle];
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = trackInfo;
    }
}

@end
