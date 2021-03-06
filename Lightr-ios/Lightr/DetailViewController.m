//
//  DetailViewController.m
//  Lightr
//
//  Created by Chris on 2/13/14.
//  Copyright (c) 2014 Whitewater Labs. All rights reserved.
//

#import "DetailViewController.h"

#import "ColorPickerViewController.h"
#import "MasterViewController.h"
#import "TVIcon.h"
#import "AppDelegate.h"
#import "Configuration.h"
#import "UIColor+RGBValues.h"

#import "KTLoader.h"

#define START_LIGHT         0
#define BOTTOM_LEFT_INDEX   30
#define TOP_LEFT_INDEX      50
#define TOP_RIGHT_INDEX     80
#define BOTTOM_RIGHT_INDEX  100

@interface DetailViewController () {
    NSMutableArray *_log; // TODO: max cap log
    NSInteger _selectingIndex;
    UIPopoverController *_colorPopover;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void) sendCommand:(NSString*)command
           withValue:(id)value
           andParams:(NSArray*)params
           andColors:(NSArray*)colors
         showOverlay:(BOOL)overlay;

@end

@implementation DetailViewController

- (IBAction)togglePower:(id)sender
{
    UISwitch *sw = (UISwitch*)sender;
    [self sendCommand:(sw.on)?@"on":@"off"
            withValue:nil
            andParams:nil
            andColors:nil
          showOverlay:FALSE];
}

- (IBAction)changeBrightness:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    int newValue = (int) slider.value;
    NSLog(@"Newvalue: %d", newValue);
    [self sendCommand:@"brightness"
            withValue:[NSString stringWithFormat:@"%d", newValue]
            andParams:nil
            andColors:nil
          showOverlay:FALSE];
}

- (void) saveWithName:(NSString*)name
{
    if(name != nil) {
        [self addLog:[NSString stringWithFormat:@"Saving favorite: %@", name]];
    }
    
    NSManagedObjectContext *context = [[AppDelegate shared] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Configuration" inManagedObjectContext:context];
    Configuration *newObj = (Configuration*)[NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    newObj.created = [NSDate date];
    newObj.categoryType = [NSNumber numberWithInteger:(name != nil) ? CategoryTypeFavorite : CategoryTypeRecent];
    newObj.colors = _previewTV.currentColors;
    newObj.configurationString = _previewTV.configuration.configurationString;
    newObj.name = name;
    
    NSMutableString *msg = [NSMutableString stringWithFormat:@"Applying[category=%d] =>", newObj.categoryType.integerValue];
    for(UIColor *c in newObj.colors) { [msg appendFormat:@" (%@)", c.description]; }
    [self addLog:msg];

    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != alertView.cancelButtonIndex) {
        [self saveWithName:[alertView textFieldAtIndex:0].text];
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void) sendCommand:(NSString*)command
           withValue:(id)value
           andParams:(NSArray*)params
           andColors:(NSArray*)colors
         showOverlay:(BOOL)overlay
{
    [KTLoader showLoader:@"Working hard. Chill out dude"];
    
    if(value == nil) { value = @""; }
    
    // animations: arduino/animation/<animationMode>/<animationDelay>/COLORS
    NSString *urlString = [NSString stringWithFormat:@"http://arduino.local/arduino/%@", command];
    
    if(value != nil) {
        urlString = [urlString stringByAppendingPathComponent:value];
    }
    
    if(params != nil) {
        for(NSString *param in params) {
            urlString = [urlString stringByAppendingPathComponent:param];
        }
    }
    
    if(colors != nil) {
        if(colors.count > 0) {
            urlString = [urlString stringByAppendingString:@"/"];
        }
        
        for(NSString *color in colors) {
            urlString = [urlString stringByAppendingString:color];
        }
    }
    
    [self addLog:[NSString stringWithFormat:@"Making request: %@", urlString]];
    
//    NSLog(@"SUBSTR => %@", [urlString substringFromIndex:urlString.length-2]);
//    if([[urlString substringFromIndex:urlString.length-2] isEqualToString:@"/"]) {
//        urlString = [urlString substringToIndex:urlString.length-1];
//    }
    
    NSLog(@"Making request => %@", urlString);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setTimeoutInterval:30];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               [self addLog:[NSString stringWithFormat:@"Request complete => %@ => %@", connectionError, response]];
                               [self addLog:[NSString stringWithFormat:@"DATA => %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]];
                               
                               if(connectionError == nil) {
                                   [KTLoader hideLoader];
                               } else {
                                   [KTLoader showLoader:@"Something broke! Tell Chris!"
                                               animated:TRUE
                                          withIndicator:KTLoaderIndicatorError
                                        andHideInterval:KTLoaderDurationAuto];
                               }
                               
                           }];
}

- (IBAction) saveToFavorites:(id)sender
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Add Name"
                                                 message:@"Add a name to your favorite"
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"Save", nil];
    
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av show];
}

- (IBAction) apply:(id)sender
{
    NSMutableArray *colors = [NSMutableArray array];
    
    int found = 0;
    while(found < _previewTV.subviews.count) {
        for(UIView *v in _previewTV.subviews) {
            if(v.tag == found) {
                [colors addObject:[v.backgroundColor hexValue]];
                ++found;
                break;
            }
        }
    }
    
    Configuration *config = _previewTV.configuration;

    NSMutableArray *params = [NSMutableArray array];
    if(config.animationMode != nil) {
        if(config.animationMode.integerValue > 0) {
            [params addObject:[NSString stringWithFormat:@"%d", config.animationMode.integerValue]];
        }
    }
    
    if(config.animationDelay != nil) {
        if(config.animationDelay.integerValue > 0) {
            [params addObject:[NSString stringWithFormat:@"%d", config.animationDelay.integerValue]];
        }
    }

    if(config.animationSteps != nil) {
        if(config.animationSteps.integerValue > 0) {
            [params addObject:[NSString stringWithFormat:@"%d", config.animationSteps.integerValue]];
        }
    }
    
    NSString *cmd = (config.categoryType.integerValue == CategoryTypeAnimated) ? @"animated" : @"standard";

    [self sendCommand:cmd
            withValue:nil
            andParams:params
            andColors:colors
          showOverlay:TRUE];
    
    [self saveWithName:nil];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSLog(@"Finished => %d", result);
    
    [controller dismissViewControllerAnimated:TRUE completion:nil];
    
    if(result == MessageComposeResultSent && error == nil) {
        [[[UIAlertView alloc] initWithTitle:@"Log sent!"
                                    message:@"Now go yell at Chris and tell him to fix it"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                           otherButtonTitles:nil] show];
    } else if(error != nil) {
        [[[UIAlertView alloc] initWithTitle:@"Error Sending - Tell Chris"
                                    message:error.localizedDescription
                                   delegate:nil
                          cancelButtonTitle:@"Did you tell Chris?"
                          otherButtonTitles:nil] show];
    }
}

- (IBAction) sendLog:(id)sender
{
    if(_log.count > 0) {

        // compile into text file
        NSMutableString *output = [NSMutableString string];
        
        for(NSString *str in _log) {
            [output appendString:str];
            [output appendString:@"\n"];
        }
        
        NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *myPath = [myPathList objectAtIndex:0];
        myPath = [myPath stringByAppendingPathComponent:@"output"];
        
        NSData *outputData = [output dataUsingEncoding:NSUTF8StringEncoding];
        [outputData writeToFile:myPath atomically:TRUE];
        
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.subject = @"Lightr Output Log";
            
            [picker addAttachmentData:outputData mimeType:@"text/plain" fileName:@"output"];
            
            [picker setMailComposeDelegate:self];
            [self presentViewController:picker animated:TRUE completion:nil];
            
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:@"Unable to send log"
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
        }

    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Nothing to send"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    }
    
}

- (IBAction) clearLog:(id)sender
{
    [_log removeAllObjects];

    for(UIView *v in _logView.subviews) {
        if([v isKindOfClass:[UILabel class]]) {
            [v removeFromSuperview];
        }
    }
}

- (void) addLog:(NSString *)msg
{
    msg = [NSString stringWithFormat:@"%@ => %@", [NSDate date], msg];
    [_log addObject:msg];
    
    for(UIView *v in _logView.subviews) {
        if([v isKindOfClass:[UILabel class]]) {
            [v removeFromSuperview];
        }
    }
    
    CGFloat height = 20;
    int yOffset = 0;
    for(NSString *str in _log) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, yOffset, _logView.frame.size.width, height)];
        label.backgroundColor = [UIColor clearColor];
        label.text = str;
        label.numberOfLines = 99;
        label.textColor = [UIColor greenColor];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.font = [UIFont fontWithName:@"Courier" size:14.0f];
        [_logView addSubview:label];
        
        
        CGSize maximumLabelSize = CGSizeMake(label.frame.size.width, FLT_MAX);
        CGSize expectedLabelSize = [str sizeWithFont:label.font
                                         constrainedToSize:maximumLabelSize
                                             lineBreakMode:label.lineBreakMode];
        
        CGRect f = label.frame;
        f.size.height = expectedLabelSize.height;
        label.frame = f;
        
        yOffset += f.size.height + 10;
    }
    
    [_logView setContentSize:CGSizeMake(_logView.frame.size.width, yOffset)];
    
    CGFloat offsetY = _logView.contentSize.height - _logView.frame.size.height;
    
    if(offsetY < 0) {
        offsetY = 0;
    }
    
    [_logView setContentOffset:CGPointMake(0, offsetY) animated:TRUE];
    
    NSLog(@"msg => %@", msg);
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void) changeConfiguration:(UITapGestureRecognizer*)gesture
{
    TVIcon *icon = (TVIcon*)gesture.view;
    [_previewTV setupWithConfiguration:icon.configuration];
    
    [self addLog:[NSString stringWithFormat:@"Changing configuration: %d", icon.configuration.categoryType.integerValue]];
}

- (void) previewTapped:(UITapGestureRecognizer*)tap
{
    CGPoint pt = [tap locationInView:_previewTV];
    
    _selectingIndex = [_previewTV indexAtTapPosition:pt];
    
    [self addLog:[NSString stringWithFormat:@"Selected color group: %d", _selectingIndex]];
    
    if(_selectingIndex > -1) {
        
        UIColor *curColor = [_previewTV.currentColors objectAtIndex:_selectingIndex];
        
        CGPoint superPoint = [self.view convertPoint:pt fromView:_previewTV];
        
        CGRect f = CGRectMake(superPoint.x, superPoint.y, 0, 0);
        
        NEOColorPickerViewController *controller = [[NEOColorPickerViewController alloc] init];
        controller.delegate = self;
        controller.selectedColor = curColor;
        
        UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:controller];

        _colorPopover = [[UIPopoverController alloc] initWithContentViewController:navVC];
        [_colorPopover presentPopoverFromRect:f
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionRight
                                     animated:YES];

    }
}

- (void) colorPickerViewController:(NEOColorPickerBaseViewController *)controller didSelectColor:(UIColor *)color {
    // Do something with the color.
    
    [self addLog:[NSString stringWithFormat:@"Updated color at index %d => %@", _selectingIndex, [color prettyPrint]]];
    
    [_previewTV replaceColorAtIndex:_selectingIndex withColor:color];
    
    [_colorPopover dismissPopoverAnimated:TRUE];
}

- (void) colorPickerViewControllerDidCancel:(NEOColorPickerBaseViewController *)controller
{
    [_colorPopover dismissPopoverAnimated:TRUE];
}

- (void) viewDidAppear:(BOOL)animated
{
    [KTLoader showLoader:@"Loading Status..."];
    
    
    NSString *urlString = @"http://arduino.local/arduino/get";
    
    [self addLog:[NSString stringWithFormat:@"Making request: %@", urlString]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setTimeoutInterval:30];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               NSLog(@"Data=> %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                               
                               if(connectionError == nil) {
                                   [KTLoader hideLoader];
                                   
                                   NSDictionary* json = [NSJSONSerialization
                                                         JSONObjectWithData:data
                                                         options:0
                                                         error:nil];
                                   
                                   NSLog(@"Dict => %@", json);
                                                                      
                                   _powerSwitch.on = [[json objectForKey:@"power"] integerValue] == 1;
                                   _brightnessSlider.value = [[json objectForKey:@"brightness"] integerValue];
                                   
                               } else {
                                   [KTLoader showLoader:@"Something broke! Tell Chris!"
                                               animated:TRUE
                                          withIndicator:KTLoaderIndicatorError
                                        andHideInterval:KTLoaderDurationAuto];
                               }
                               
                           }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [AppDelegate shared].detailViewController = self;
    
    _log = [[NSMutableArray alloc] initWithCapacity:2];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapped:)];
    
    _previewTV = [TVIcon iconWithWidth:500];
    _previewTV.center = CGPointMake(352, 310);
//    [_previewTV configure:TVConfigurationWhole withColors:@[[UIColor blackColor]]];
    [self.view addSubview:_previewTV];
    
    [_previewTV addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
