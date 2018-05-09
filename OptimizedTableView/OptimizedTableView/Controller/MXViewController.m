//
//  MXViewController.m
//  OptimizedTableView
//
//  Created by mac on 2018/5/6.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "MXViewController.h"
#import "MXBestTableView.h"

@interface MXViewController ()

@property (nonatomic, strong) MXBestTableView *bestTableView;

@end

@implementation MXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"关注的微博";
    [self.view addSubview:self.bestTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma getter and setter
- (MXBestTableView *)bestTableView {
    if (!_bestTableView) {
        _bestTableView = [[MXBestTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _bestTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return _bestTableView;
}

@end
