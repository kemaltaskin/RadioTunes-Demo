//
//  YLRadioTunes.h
//  RadioTunesBinary
//
//  Created by Kemal Taskin on 28/10/14.
//  Copyright (c) 2014 Yakamoz Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YLRadioTunes : NSObject

+ (instancetype)sharedInstance;

+ (NSString *)version;

- (void)setLicenseKey:(NSString *)licenseKey;
- (void)setLicenseKey:(NSString *)licenseKey withActivationKey:(NSString *)activationKey;

- (NSString *)licenseKey;
- (NSString *)activationKey;

@end
