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

@interface DetailViewController () {
    NSMutableArray *_log; // TODO: max cap log
    NSInteger _selectingIndex;
    UIPopoverController *_colorPopover;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void) configureView;
@end

@implementation DetailViewController

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
    newObj.configurationType = [NSNumber numberWithInteger:_previewTV.configuration];
    newObj.isFavorite = [NSNumber numberWithBool:(name != nil)];
    newObj.colors = _previewTV.colors;
    newObj.name = name;
    
    NSMutableString *msg = [NSMutableString stringWithFormat:@"Applying[isFavorite=%d][config=%d] =>", newObj.isFavorite.integerValue, newObj.configurationType.integerValue];
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

- (NSString*)createRandomHex
{
    NSString *chars = @"0123456789ABCDEF";
    NSMutableString *retString = [NSMutableString stringWithString:@""];
    for(int i=0; i<6; i++) {
        int loc = arc4random() % chars.length;
        [retString appendString:[chars substringWithRange:NSMakeRange(loc, 1)]];
    }
    return [NSString stringWithString:retString];
}

- (void) sendCommand:(NSString*)command
{
    
    NSMutableString *colors = [NSMutableString stringWithString:@""];
    
    for(int i=0; i<30*4; i++) {
        [colors appendString:[self createRandomHex]];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"http://arduino.local/arduino/c/%@/p/%@/",command,colors];
    
    [self addLog:[NSString stringWithFormat:@"Making request: %@", urlString]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setTimeoutInterval:30];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               [self addLog:[NSString stringWithFormat:@"Request complete => %@ => %@", connectionError, response]];
                               [self addLog:[NSString stringWithFormat:@"DATA => %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]];
                           }];
}

- (IBAction) saveToFavorites:(id)sender
{
    [self sendCommand:@"blink"];
    
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
    [self sendCommand:@"blink_fast"];

    //switch to the recent tab
    [[AppDelegate shared].masterViewController.segment setSelectedSegmentIndex:1];
    [[AppDelegate shared].masterViewController segmentChanged:self];
    
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
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void) changeConfiguration:(UITapGestureRecognizer*)gesture
{
    TVIcon *icon = (TVIcon*)gesture.view;
    [_previewTV configure:icon.configuration withColors:icon.colors];
    
    [self addLog:[NSString stringWithFormat:@"Changing configuration: %d", icon.configuration]];
}

- (void)configureView
{
    CGFloat y = round(_configurations.frame.size.height/2);
    
    NSArray *colors = @[[UIColor redColor],
                        [UIColor orangeColor],
                        [UIColor greenColor],
                        [UIColor blueColor]];
    
    for(int i=TVConfigurationWhole; i<TVConfigurationSplitQuadrants+1; i++) {

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeConfiguration:)];
        TVIcon *icon = [TVIcon iconWithWidth:80];
        icon.center = CGPointMake(60 + 100 * i, y);
        
        NSArray *useColors = nil;
        if(i == TVConfigurationWhole) {
            useColors = [colors objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)]];
        } else if(i == TVConfigurationSplitHorizontal || i == TVConfigurationSplitVertical) {
            useColors = [colors objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]];
        } else if(i == TVConfigurationSplitHorizontalThirds || i == TVConfigurationSplitVerticalThirds) {
            useColors = [colors objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
        } else if(i == TVConfigurationSplitQuadrants) {
            useColors = [colors objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
        }
        
        [icon configure:i withColors:useColors];
        [_configurations addSubview:icon];
        [icon addGestureRecognizer:tap];

    }

}

- (void) previewTapped:(UITapGestureRecognizer*)tap
{
    CGPoint pt = [tap locationInView:_previewTV];
    
    _selectingIndex = [_previewTV indexAtTapPosition:pt];
    
    [self addLog:[NSString stringWithFormat:@"Selected color group: %d", _selectingIndex]];
    
    if(_selectingIndex > -1) {
        
        CGPoint superPoint = [self.view convertPoint:pt fromView:_previewTV];
        
        CGRect f = CGRectMake(superPoint.x, superPoint.y, 0, 0);
        
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ColorPickerViewController *vc = [story instantiateViewControllerWithIdentifier:@"ColorPicker"];
        
        _colorPopover = [[UIPopoverController alloc] initWithContentViewController:vc];
        [_colorPopover presentPopoverFromRect:f
                                 inView:self.view
               permittedArrowDirections:UIPopoverArrowDirectionRight
                               animated:YES];
        
//        [_previewTV replaceColorAtIndex:_selectingIndex withColor:[UIColor purpleColor]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [AppDelegate shared].detailViewController = self;
    
    _log = [[NSMutableArray alloc] initWithCapacity:2];

    [self configureView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapped:)];
    
    _previewTV = [TVIcon iconWithWidth:370];
    _previewTV.center = CGPointMake(352, 370);
    [_previewTV configure:TVConfigurationWhole withColors:@[[UIColor blackColor]]];
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
