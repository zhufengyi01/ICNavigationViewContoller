//
//  ICFullScreenAnd3DNavigation.m
//  ICNavigationViewContoller
//
//  Created by 朱封毅 on 10/05/16.
//  Copyright © 2016年 taihe. All rights reserved.
//

#import "ICFullScreenAnd3DNavigation.h"
#define DEVICE_SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
@interface ICFullScreenAnd3DNavigation ()
{
    //开始移动点
    CGPoint startTouch;
    
    // 遮罩
    UIView *blackMask;
    
    //上个view的截图
    UIImageView * lastScreenShotView;

    UIImage *lastScreenImage;
}

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, assign) BOOL isMoving;


@end

@implementation ICFullScreenAnd3DNavigation

- (void)dealloc {
    
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
}


- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    
    self = [super initWithRootViewController:rootViewController];
    
    if (self) {
        
        self.dragBackEnable = YES;
    }
    
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        self.dragBackEnable = YES;
    }
    
    return self;
}



- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.interactivePopGestureRecognizer.delegate = nil;
    
    self.navigationBar.translucent = NO;
    
    [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    
    
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(paningGestureReceive:)];
    recognizer.delegate = self;
    //[recognizer delaysTouchesBegan];
    [self.view addGestureRecognizer:recognizer];
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:(BOOL)animated];
    
}


// override the push method
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    
    if ([viewController isKindOfClass:[UIViewController class]]) {
        
        lastScreenImage  = [self capture];
    }
    
    [super pushViewController:viewController animated:animated];
}


#pragma mark - Utility Methods


// get the current view screen shot
- (UIImage *)capture {
    
    
    UIView * currentView = nil;
    
    if (self.tabBarController) {
        
        currentView = self.tabBarController.view;
        
    } else {
        
        currentView = self.view;
    }
    
    //DEVICE_CURRENT_VIEW;
    
    UIGraphicsBeginImageContextWithOptions(currentView.bounds.size, currentView.opaque, 0.0);
    [currentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    //[self.view drawViewHierarchyInRect:<#(CGRect)#> afterScreenUpdates:<#(BOOL)#>]
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}


// set lastScreenShotView 's position and alpha when paning
- (void)moveViewWithX:(float)x {
    
    x = x > DEVICE_SCREEN_WIDTH ? DEVICE_SCREEN_WIDTH : x;
    x = x < 0 ? 0 : x;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    //NSLog(@"Move to:%f", x);
    
    //float scale = (x/6400)+0.95;
    //lastScreenShotView.transform = CGAffineTransformMakeScale(scale, scale);
    
    float alpha = 0.6 - (x/800);
    
    CGFloat s  = x *( 0.06 /DEVICE_SCREEN_WIDTH ) + 0.94;
    
    lastScreenShotView.transform = CGAffineTransformMakeScale(s , s);
    
    blackMask.alpha = alpha;
    
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (self.viewControllers.count <= 1 || !self.dragBackEnable)
        return NO;
    
    return YES;
}

#pragma mark - Gesture Recognizer -

- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    // If the viewControllers has only one vc or disable the interaction, then return.
    if (self.viewControllers.count <= 1 || !self.dragBackEnable)
        return;
    
    // we get the touch position by the window's coordinate
    CGPoint touchPoint = [recoginzer locationInView:self.view.superview];
    
    switch (recoginzer.state) {
            
        case UIGestureRecognizerStateBegan: {
            
            NSLog(@"UIGestureRecognizerStateBegan");
            
            _isMoving = YES;
            startTouch = touchPoint;
            
            
            if (self.backgroundView) {
                
                [self.backgroundView removeFromSuperview];
                self.backgroundView = nil;
            }
            
            
            self.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
            self.backgroundView.backgroundColor  =[UIColor blackColor];
            [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
            
            blackMask = [[UIView alloc]initWithFrame:self.backgroundView.bounds];
            blackMask.backgroundColor = [UIColor blackColor];
            [self.backgroundView addSubview:blackMask];
            
            lastScreenShotView = [[UIImageView alloc] initWithImage:lastScreenImage];
            [self.backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            
            if (_isMoving) {
                [self moveViewWithX:touchPoint.x - startTouch.x];
            }
            
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            
            NSLog(@"UIGestureRecognizerStateEnded");
            
            if (touchPoint.x - startTouch.x > 50)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    
                    [self moveViewWithX:DEVICE_SCREEN_WIDTH];
                    
                } completion:^(BOOL finished) {
                    
                    [self popViewControllerAnimated:NO];
                    CGRect frame = self.view.frame;
                    frame.origin.x = 0;
                    self.view.frame = frame;
                    
                    _isMoving = NO;
                    self.backgroundView.hidden = YES;
                    
                }];
                
            } else {
                
                [UIView animateWithDuration:0.3 animations:^{
                    [self moveViewWithX:0];
                } completion:^(BOOL finished) {
                    _isMoving = NO;
                    self.backgroundView.hidden = YES;
                }];
                
            }
            
            break;
        }
            
        default:
            return;
            break;
    }
}


@end
