//
//  MainViewController.h
//
//  Copyright 2011 Yakamoz Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RadioTunes/RadioTunes.h>

@interface MainViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,YLRadioDelegate,YLAudioSessionDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableview;
@property (nonatomic, retain) IBOutlet UIImageView *bgImageView;
@property (nonatomic, retain) IBOutlet UISlider *volumeSlider;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *recordButton;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

@end
