//
//  MainViewController.h
//  Radio
//
//  Copyright 2011 Yakamoz Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Radio.h"

@interface MainViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,RadioDelegate> {
    UITableView *_tableview;
    NSInteger _currentRadio;
    
    UISlider *_volumeSlider;
    UIButton *_playButton;
    UILabel *_statusLabel;
    UILabel *_titleLabel;

    Radio *_radio;
    
    NSMutableArray *_radioStations;
    NSMutableArray *_radioNames;
    NSMutableArray *_radioSubtitles;
}

@property (nonatomic, retain) IBOutlet UITableView *tableview;
@property (nonatomic, retain) IBOutlet UISlider *volumeSlider;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

- (void)beginInterruption;
- (void)endInterruption;

@end
