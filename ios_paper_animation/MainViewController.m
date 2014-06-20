//
//  MainViewController.m
//  ios_paper_animation
//
//  Created by Stanley Ng on 6/18/14.
//  Copyright (c) 2014 Stanley Ng. All rights reserved.
//

#import "MainViewController.h"
#import "AVHexColor.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UIView *sectionView;
@property (weak, nonatomic) IBOutlet UIImageView *sectionCoverImageView;
@property (weak, nonatomic) IBOutlet UIView *sectionCoverTitleView;
@property (weak, nonatomic) IBOutlet UIImageView *menuImageView;

@property (strong, nonatomic) NSMutableDictionary *viewPointMap;
@property (strong, nonatomic) NSMutableDictionary *handPointMap;

@property (assign, nonatomic) NSInteger sectionCoverImageIndex;

/* Section View */
- (void)onSectionViewPan:(UIPanGestureRecognizer *)panGestureRecognizer;
- (void)onSectionViewTap:(UITapGestureRecognizer *)tapGestureRecognizer;
- (void)moveSectionViewDown;
- (void)moveSectionViewUp;
- (bool)isSectionViewOutofBounds;
- (bool)isSectionViewDown;

- (void)customizeSectionCoverImages;
- (void)loadSectionCoverImage;

- (void)customizeSectionStories;
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
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(onSectionViewPan:)];
    [self.sectionView addGestureRecognizer:panGestureRecognizer];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(onSectionViewTap:)];
    [self.sectionView addGestureRecognizer:tapGestureRecognizer];
    
    [self customizeSectionCoverImages];
    [self customizeSectionStories];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onSectionViewPan:(UIPanGestureRecognizer *)panGestureRecognizer
{
    NSLog(@"onSectionViewPan");
    
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
        
        if ([self isSectionViewOutofBounds]) {
            float scale = 1 / log10(fabsf([self.handPointMap[@"changed"] CGPointValue].y - [self.handPointMap[@"begin"] CGPointValue].y));
            NSLog(@"%f", scale);
            
            CGRect frame = self.sectionView.frame;
            frame.origin.y =
            [self.viewPointMap[@"begin"] CGPointValue].y +
            ([self.handPointMap[@"changed"] CGPointValue].y - [self.handPointMap[@"begin"] CGPointValue].y) * scale;
            self.sectionView.frame = frame;
        }
        else {
            CGRect frame = self.sectionView.frame;
            frame.origin.y =
            [self.viewPointMap[@"begin"] CGPointValue].y +
            ([self.handPointMap[@"changed"] CGPointValue].y - [self.handPointMap[@"begin"] CGPointValue].y);
            self.sectionView.frame = frame;
        }
        
        {
            CGRect screen = [[UIScreen mainScreen] bounds];
            CGRect title = self.sectionCoverTitleView.frame;
            CGRect view = self.sectionView.frame;

            float d2 = screen.size.height - title.size.height;
            float d1 = view.origin.y;
            
            float a = d1 / d2;
            NSLog(@"alpha: %f", a);
            self.menuImageView.alpha = a;
        }
        
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Gesture ended: %@ v: %@", NSStringFromCGPoint(point), NSStringFromCGPoint(velocity));

        self.viewPointMap[@"ended"] = [NSValue valueWithCGPoint:self.sectionView.frame.origin];
        self.handPointMap[@"ended"] = [NSValue valueWithCGPoint:point];
        
        if (velocity.y > 0) {
            // drag down
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self moveSectionViewDown];
                
                self.menuImageView.alpha = 0.9;

            } completion:nil];
        }
        else {
            // drag up
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self moveSectionViewUp];
                
                self.menuImageView.alpha = 0;

            } completion:nil];
        }
    }
}

- (void)onSectionViewTap:(UIPanGestureRecognizer *)panGestureRecognizer
{
    NSLog(@"onSectionViewTap");
    
    if ([self isSectionViewDown]) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self moveSectionViewUp];
        } completion:nil];
    }
    
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

- (bool)isSectionViewDown
{
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGRect title = self.sectionCoverTitleView.frame;
    CGRect view = self.sectionView.frame;

    return view.origin.y + title.size.height == screen.size.height;
}

- (void)customizeSectionCoverImages
{
    NSLog(@"customizeSectionCoverImages");
    
    self.sectionCoverImageIndex = 1;
    [self loadSectionCoverImage];
    
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(loadSectionCoverImage) userInfo:nil repeats:YES];
}

- (void)loadSectionCoverImage
{
    NSLog(@"loadSectionCoverImage");
    
    int idx = self.sectionCoverImageIndex;
    NSString *imageName = [NSString stringWithFormat:@"section-cover-%d", idx];
    NSLog(@"imageName: %@", imageName);
    self.sectionCoverImageIndex = idx % 10 + 1;

    [UIView
     animateWithDuration:1.0f
     delay:0.0f
     options:UIViewAnimationOptionCurveEaseIn
     animations:^{
    
        self.sectionCoverImageView.alpha = 0.1;
     
     } completion:^(BOOL finished) {
        
        [self.sectionCoverImageView setImage: [UIImage imageNamed:imageName]];
        
        [UIView
         animateWithDuration:1.0f
         delay:0.0f
         options:UIViewAnimationOptionCurveEaseOut
         animations:^{
         
             self.sectionCoverImageView.alpha = 1;
             
         }
         completion:nil];
        
    }];
}

- (void)customizeSectionStories
{
    NSLog(@"customizeSectionStories");

    UIScrollView *scrollView;
    UIImageView *imageView;
    
    scrollView = [[UIScrollView alloc] init];
    imageView = [[UIImageView alloc] init];
    
    [imageView setImage:[UIImage imageNamed:@"section-headlines-posts"]];
    [imageView sizeToFit];
    
    [self.sectionView insertSubview:scrollView aboveSubview:self.sectionCoverImageView];
    [scrollView addSubview:imageView];
    
    scrollView.translatesAutoresizingMaskIntoConstraints  = NO;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    NSLog(@"%f", screen.size.height);
    NSLog(@"%f", imageView.frame.size.height);
    NSLog(@"%f", screen.size.height - imageView.frame.size.height);
    
    NSDictionary *viewsDictionary = @{
                                      @"scrollView":scrollView,
                                      @"imageView":imageView
                                      };
    [self.sectionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.sectionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-314.0-[scrollView]|" options:0 metrics: 0 views:viewsDictionary]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics: 0 views:viewsDictionary]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics: 0 views:viewsDictionary]];
}
@end