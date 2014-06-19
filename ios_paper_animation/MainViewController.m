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

@property (strong, nonatomic) NSMutableDictionary *viewPointMap;
@property (strong, nonatomic) NSMutableDictionary *handPointMap;

- (void)onSectionViewPan:(UIPanGestureRecognizer *)panGestureRecognizer;
- (void)onSectionViewTap:(id)sender;

- (void)moveSectionViewDown;
- (void)moveSectionViewUp;

- (bool)isSectionViewOutofBounds;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.viewPointMap = [@{
                               @"begin": [NSNull null],
                               @"changed": [NSNull null],
                               @"ended": [NSNull null]
                               } mutableCopy];
        
        self.handPointMap = [@{
                               @"begin": [NSNull null],
                               @"changed": [NSNull null],
                               @"ended": [NSNull null]
                               } mutableCopy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onSectionViewPan:)];
    [self.sectionView addGestureRecognizer:panGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onSectionViewPan:(UIPanGestureRecognizer *)panGestureRecognizer
{
    NSLog(@"onSectionViewPan");

    //if ([self isSectionViewOutofBounds]) {
    //    return;
    //}
    
    CGPoint point = [panGestureRecognizer locationInView:self.view];
    CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
    
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Gesture began at: %@ v: %@", NSStringFromCGPoint(point), NSStringFromCGPoint(velocity));
        
        self.viewPointMap[@"begin"] = [NSValue valueWithCGPoint:self.sectionView.frame.origin];
        self.handPointMap[@"begin"] = [NSValue valueWithCGPoint:point];
        
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"Gesture changed: %@ v: %@", NSStringFromCGPoint(point), NSStringFromCGPoint(velocity));

        self.viewPointMap[@"changed"] = [NSValue valueWithCGPoint:self.sectionView.frame.origin];
        self.handPointMap[@"changed"] = [NSValue valueWithCGPoint:point];
        
        CGRect frame = self.sectionView.frame;
        frame.origin.y =
            [self.viewPointMap[@"begin"] CGPointValue].y +
            ([self.handPointMap[@"changed"] CGPointValue].y - [self.handPointMap[@"begin"] CGPointValue].y);
        
        self.sectionView.frame = frame;
        
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Gesture ended: %@ v: %@", NSStringFromCGPoint(point), NSStringFromCGPoint(velocity));

        self.viewPointMap[@"ended"] = [NSValue valueWithCGPoint:self.sectionView.frame.origin];
        self.handPointMap[@"ended"] = [NSValue valueWithCGPoint:point];
        
        if (velocity.y > 0) {
            // drag down
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self moveSectionViewDown];
            } completion:nil];
        }
        else {
            // drag up
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self moveSectionViewUp];
            } completion:nil];
        }
    }
}

- (void)onSectionViewTap:(id)sender
{
    NSLog(@"onSectionViewTap");
    
    /*
    if ([self isSectionViewMovedDown]) {
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
     */
}

- (void) moveSectionViewDown
{
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGRect title = self.sectionCoverTitleView.frame;

    CGRect frame = self.sectionView.frame;
    frame.origin.y = screen.size.height - title.size.height;
    self.sectionView.frame = frame;
}

- (void) moveSectionViewUp
{
    CGRect screen = [[UIScreen mainScreen] bounds];
    
    CGRect frame = self.sectionView.frame;
    frame.origin.y = screen.origin.y;
    self.sectionView.frame = frame;
}

- (bool)isSectionViewOutofBounds
{
    CGRect screen = [[UIScreen mainScreen] bounds];
    //NSLog(@"screen %@", NSStringFromCGRect(screen));
    
    CGRect title = self.sectionCoverTitleView.frame;
    //NSLog(@"title %@", NSStringFromCGRect(title));

    CGRect view = self.sectionView.frame;
    //NSLog(@"view %@", NSStringFromCGRect(view));

    // case 1: view.y < screen.y
    if (view.origin.y < screen.origin.y) {
        NSLog(@"case 1: view.y < screen.y");
        return true;
    }
    // case 2: view.y + title.h > screen.h
    else if (view.origin.y + title.size.height > screen.size.height) {
        NSLog(@"case 2: view.y + title.h > screen.h");
        return true;
    }
    
    return false;
}

@end