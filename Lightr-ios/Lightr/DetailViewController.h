//
//  DetailViewController.h
//  Lightr
//
//  Created by Chris on 2/13/14.
//  Copyright (c) 2014 Whitewater Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MessageUI.h>

#import "NEOColorPickerViewController.h"

@class TVIcon;

@interface DetailViewController : UIViewController
<UISplitViewControllerDelegate,
MFMailComposeViewControllerDelegate,
NEOColorPickerViewControllerDelegate,
UIAlertViewDelegate>

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) IBOutlet UIScrollView *configurations;

@property (weak, nonatomic) IBOutlet UIScrollView *logView;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@property (weak, nonatomic) IBOutlet UISwitch *powerSwitch;
@property (weak, nonatomic) IBOutlet UISlider *brightnessSlider;

@property (nonatomic, strong) TVIcon *previewTV;

- (IBAction)togglePower:(id)sender;
- (IBAction)changeBrightness:(id)sender;

- (IBAction) sendLog:(id)sender;
- (IBAction) clearLog:(id)sender;

- (IBAction) saveToFavorites:(id)sender;
- (IBAction) apply:(id)sender;

- (void) addLog:(NSString*)msg;

@end
