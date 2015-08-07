//
//  ViewController.m
//  keyChain
//
//  Created by GoBeta on 15/5/6.
//  Copyright (c) 2015年 Marshal. All rights reserved.
//

#import "ViewController.h"
#import "Tool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   NSLog(@"uuid = %@", [Tool readUDID]);
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [Tool deleteUUID];
}
@end
