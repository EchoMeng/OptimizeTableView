//
//  MXBestTableView.m
//  OptimizedTableView
//
//  Created by mac on 2018/5/6.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "MXBestTableView.h"
#import "MXBestTableViewCell.h"
#import "MXContent.h"
#import <MJExtension.h>
#import "MXCellLayout.h"

#define BestCellReuseID (@"bestCell")

@interface MXBestTableView() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *datas;

@property (nonatomic, strong) NSMutableArray *needUpdataDatas;

@end

@implementation MXBestTableView
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        _datas = [NSMutableArray array];
        _needUpdataDatas = [NSMutableArray array];
        [self registerClass:[MXBestTableViewCell class] forCellReuseIdentifier:BestCellReuseID];
        self.delegate = self;
        self.dataSource = self;
        [self loadDatas];
        [self reloadData];
        self.backgroundColor = [UIColor grayColor];
    }
    return self;
}

#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MXBestTableViewCell *cell = [self dequeueReusableCellWithIdentifier:BestCellReuseID];
    [self drawCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)drawCell:(MXBestTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell clear];
    MXContent *data = self.datas[indexPath.row];
    cell.data = data;
    [cell draw];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MXCellLayout *layout = [[MXCellLayout alloc] init];
    MXContent *data = self.datas[indexPath.row];
    layout.data = data;
    return layout.frame.size.height;
}

#pragma UITableViewDelegate


#pragma data
- (void)loadDatas {
    self.datas = [MXContent mj_objectArrayWithFilename:@"data.plist"];
}

@end
