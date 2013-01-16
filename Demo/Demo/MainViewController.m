//
//  MainViewController.m
//  Radio
//
//  Copyright 2011 Yakamoz Labs. All rights reserved.
//

#import "MainViewController.h"
#import "RecordingsViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MainViewController() {
    NSInteger _currentRadio;
    NSInteger _recordingCounter;
    
    YLRadio *_radio;
    
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
        
        _radioStations = [[NSMutableArray alloc] init];
        _radioNames = [[NSMutableArray alloc] init];
        _radioSubtitles = [[NSMutableArray alloc] init];
        _recordings = [[NSMutableArray alloc] init];
        
        [_radioNames addObject:@"Show Radyo"];
        [_radioSubtitles addObject:@"mms wma stream"];
        [_radioStations addObject:@"mmsh://84.16.235.90/ShowRadyo"];
        
        [_radioNames addObject:@"DI.fm"];
        [_radioSubtitles addObject:@"mms wma stream"];
        [_radioStations addObject:@"mms://wstream5a.di.fm/vocaltrance"];
        
        [_radioNames addObject:@"Boost.FM"];
        [_radioSubtitles addObject:@"http mp3 stream"];
        [_radioStations addObject:@"http://108.168.244.242:8000/stream/1/"];
        
        [_radioNames addObject:@"BeatLounge"];
        [_radioSubtitles addObject:@"http mp3 stream"];
        [_radioStations addObject:@"http://199.19.105.171:8059"];
        
        [_radioNames addObject:@"Radio Javan"];
        [_radioSubtitles addObject:@"http mp3 stream"];
        [_radioStations addObject:@"http://stream.radiojavan.com/radiojavan"];
        
        [_radioNames addObject:@"Power FM"];
        [_radioSubtitles addObject:@"http aac+ pls stream"];
        [_radioStations addObject:@"http://46.20.4.43:8130/listen.pls"];
        
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
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
        default:
            break;
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
#pragma mark YLAudioSessionDelegate
- (void)beginInterruption {
    if(_radio == nil) {
        return;
    }
    
    [_radio pause];
}

- (void)endInterruptionWithFlags:(NSUInteger)flags {
    if(_radio == nil) {
        return;
    }
    
    if([_radio isPaused]) {
        [_radio play];
    }
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
- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_radioStations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    int row = indexPath.row;
    
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
        NSString *filename = [NSString stringWithFormat:@"%@%d.%@", [_radioNames objectAtIndex:_currentRadio], _recordingCounter++, [_radio fileExtensionHint]];
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
    } else if(state == kRadioStateStopped) {
        [_statusLabel setText:@"Status: Stopped"];
        [_playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [_playButton setEnabled:YES];
        [_recordButton setEnabled:NO];
    } else if(state == kRadioStateError) {
        [_statusLabel setText:@"Status: Error"];
        [_playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [_playButton setEnabled:YES];
        [_recordButton setEnabled:NO];
        
        YLRadioError error = [_radio radioError];
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
}

- (void)radio:(YLRadio *)radio recordingFailedWithError:(NSError *)error {
    // Error codes are defined in YLRadio.h: YLRadioRecordingError
    NSLog(@"Recording failed with error (code: %d): %@", error.code, error.localizedDescription);
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
