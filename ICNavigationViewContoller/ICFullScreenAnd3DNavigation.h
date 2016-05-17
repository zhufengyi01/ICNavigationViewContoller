//
//  ICFullScreenAnd3DNavigation.h
//  ICNavigationViewContoller
//
//  Created by 朱封毅 on 10/05/16.
//  Copyright © 2016年 taihe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICFullScreenAnd3DNavigation : UINavigationController  <UIGestureRecognizerDelegate>

// Enable the drag to back interaction, Defalt is YES.
@property (nonatomic,assign) BOOL dragBackEnable;


@end
