//
//  RecordingsViewController.m
//  RadioTunes
//
//  Copyright (c) 2013 Yakamoz Labs. All rights reserved.
//

#import "RecordingsViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface RecordingsViewController ()<AVAudioPlayerDelegate> {
    NSArray *_recordings;
    NSInteger _currentRecording;
    NSString *_documentsPath;
    
    AVAudioPlayer *_audioPlayer;
}

- (void)playButtonTapped;

@end

@implementation RecordingsViewController

@synthesize tableview = _tableview;
@synthesize bgImageView = _bgImageView;
@synthesize playButton = _playButton;
@synthesize statusLabel = _statusLabel;
@synthesize titleLabel = _titleLabel;

- (id)initWithRecordings:(NSArray *)recordings {
    self = [super initWithNibName:@"RecordingsView" bundle:nil];
    if (self) {
        self.title = @"Recordings";
        
        _recordings = [recordings retain];
        _currentRecording = -1;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _documentsPath = [[paths objectAtIndex:0] retain];
    }
    
    return self;
}

- (void)dealloc {
    [_tableview release];
    [_bgImageView release];
    [_playButton release];
    [_statusLabel release];
    [_titleLabel release];

    [_recordings release];
    [_documentsPath release];
    [_audioPlayer release];
    
    [super dealloc];
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
    [_statusLabel setText:@""];
    [_titleLabel setText:@""];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if(_audioPlayer && _audioPlayer.isPlaying) {
        [_audioPlayer stop];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark UITableViewDataSource/UITableViewDelegate Methods
- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_recordings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    int row = indexPath.row;
    
    [[cell textLabel] setText:[_recordings objectAtIndex:row]];
    if(row == _currentRecording) {
        [cell setAccessoryView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"now_playing.png"]] autorelease]];
    } else {
        [cell setAccessoryView:nil];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == _currentRecording) {
        return;
    }
    
    if(_audioPlayer) {
        _audioPlayer.delegate = nil;
        [_audioPlayer stop];
        [_audioPlayer release];
        _audioPlayer = nil;
    }
    
    [_statusLabel setText:@""];
    
    _currentRecording = indexPath.row;
    NSString *filename = [_recordings objectAtIndex:indexPath.row];
    [_titleLabel setText:filename];
    
    NSString *path = [_documentsPath stringByAppendingPathComponent:filename];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error;
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if(error) {
        [_statusLabel setText:[NSString stringWithFormat:@"%@", error.localizedDescription]];
    } else {
        if(_audioPlayer) {
            NSString *duration = [NSString stringWithFormat:@"%d:%02d", (int)_audioPlayer.duration / 60, (int)_audioPlayer.duration % 60];
            [_statusLabel setText:duration];
            [_playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
            
            [_audioPlayer setDelegate:self];
            [_audioPlayer setVolume:0.5];
            [_audioPlayer prepareToPlay];
            [_audioPlayer play];
        }
    }
    
    [self.tableview reloadData];
}


#pragma mark -
#pragma mark AVAudioPlayerDelegate Methods
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [_playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [_statusLabel setText:[NSString stringWithFormat:@"%@", error.localizedDescription]];
    [_playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
}


#pragma mark -
#pragma mark Private Methods
- (void)playButtonTapped {
    if(_audioPlayer == nil) {
        return;
    }
    
    if(_audioPlayer.isPlaying) {
        [_audioPlayer pause];
        [_playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    } else {
        [_audioPlayer play];
        [_playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }
}

@end
