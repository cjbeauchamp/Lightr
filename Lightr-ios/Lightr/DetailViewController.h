//
//  DetailViewController.h
//  Lightr
//
//  Created by Chris on 2/13/14.
//  Copyright (c) 2014 Whitewater Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MessageUI.h>

@class TVIcon;

@interface DetailViewController : UIViewController
<UISplitViewControllerDelegate,
MFMailComposeViewControllerDelegate,
UIAlertViewDelegate>

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) IBOutlet UIScrollView *configurations;

@property (weak, nonatomic) IBOutlet UIScrollView *logView;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@property (nonatomic, strong) TVIcon *previewTV;

- (IBAction) sendLog:(id)sender;
- (IBAction) clearLog:(id)sender;

- (IBAction) saveToFavorites:(id)sender;
- (IBAction) apply:(id)sender;

- (void) addLog:(NSString*)msg;

@end
