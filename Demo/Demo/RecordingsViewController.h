//
//  RecordingsViewController.h
//  RadioTunes
//
//  Copyright (c) 2013 Yakamoz Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordingsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableview;
@property (nonatomic, retain) IBOutlet UIImageView *bgImageView;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

- (id)initWithRecordings:(NSArray *)recordings;

@end
