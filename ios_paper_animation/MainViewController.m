//
//  MainViewController.m
//  ios_paper_animation
//
//  Created by Stanley Ng on 6/18/14.
//  Copyright (c) 2014 Stanley Ng. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UIView *sectionView;
@property (weak, nonatomic) IBOutlet UIImageView *sectionCoverImageView;
@property (weak, nonatomic) IBOutlet UIView *sectionCoverTitleView;

- (IBAction)onTap:(id)sender;

- (void)sectionViewTapped:(id)sender;
- (bool)isTappedSectionView;

@end

@implementation MainViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTap:(id)sender
{
    NSLog(@"onTap");
    [self sectionViewTapped:sender];
}

- (void)sectionViewTapped:(id)sender
{
    NSLog(@"sectionViewTapped");
    
    if ([self isTappedSectionView]) {
        // Move up section view
        CGRect frame = self.sectionView.frame;
        frame.origin.y = 0;
        self.sectionView.frame = frame;
    }
    else {
        // Move down section view
        
        CGRect screen = [[UIScreen mainScreen] bounds];
        NSLog(@"screen %@", NSStringFromCGRect(screen));
        
        CGRect title = self.sectionCoverTitleView.frame;
        NSLog(@"title %@", NSStringFromCGRect(title));
        
        CGRect frame = self.sectionView.frame;
        frame.origin.y = screen.size.height - title.size.height;
        self.sectionView.frame = frame;
    }
}

- (bool)isTappedSectionView
{
    return self.sectionView.frame.origin.y != 0;
}

@end