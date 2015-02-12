//
//  ComposeViewController.m
//  TW33Tme
//
//  Created by Amie Kweon on 6/21/14.
//  Copyright (c) 2014 Amie Kweon. All rights reserved.
//

#import "ComposeViewController.h"
#import "TwitterClient.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"


@interface ComposeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;

@end

@implementation ComposeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupUI];

    self.nameLabel.text = [[User currentUser] name];
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", [[User currentUser] screenName]];
    [self.imageView setImageWithURL:[NSURL URLWithString:[User currentUser].profileImageUrl]];


    self.textView.delegate = self;

    if (self.replyTo != nil) {
        self.textView.text = [NSString stringWithFormat:@"@%@", self.replyTo.user.screenName];
        self.placeholderLabel.hidden = YES;
        [self.textView becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)save {
  
    
    [[TwitterClient sharedInstance] postStatus:[self.textView text]];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)textViewDidChange:(UITextView *)textView {
    self.placeholderLabel.hidden = YES;
}

- (void)setupUI {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = NO;

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Cancel"
                                      style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(cancel)];
    cancelButton.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [[UIColor alloc ]initWithRed:(CGFloat)0.333
                                                                                  green:(CGFloat)0.67
                                                                                   blue:(CGFloat)0.93
                                                                                  alpha:(CGFloat)0.0];
    
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Save"
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(save)];
    saveButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    // Round image view corners
    CALayer *layer = [self.imageView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:7.0];

}
@end
