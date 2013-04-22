//
//  LicenseViewController.m
//
//  Copyright (c) 2013 Yakamoz Labs. All rights reserved.
//

#import "LicenseViewController.h"

@interface LicenseViewController () {
    UIWebView *_webview;
}

@end

@implementation LicenseViewController

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = @"License";
    }
    
    return self;
}

- (void)dealloc {
    [_webview release];
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webview = [[UIWebView alloc] initWithFrame:self.view.bounds];
    NSString *licensePath = [[NSBundle mainBundle] pathForResource:@"License" ofType:@"md"];
    [_webview loadData:[NSData dataWithContentsOfFile:licensePath] MIMEType:@"text/plain" textEncodingName:@"UTF-8" baseURL:nil];
    [self.view addSubview:_webview];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _webview.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
