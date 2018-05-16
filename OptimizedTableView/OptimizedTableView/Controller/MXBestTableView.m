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

@property (nonatomic, assign) BOOL scrollToTop;

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
    if (self.needUpdataDatas.count>0 && [self.needUpdataDatas indexOfObject:indexPath] == NSNotFound) { //不需要加载的cell不加载
        [cell clear];
        return;
    }
    [cell draw];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MXCellLayout *layout = [[MXCellLayout alloc] init];
    MXContent *data = self.datas[indexPath.row];
    layout.data = data;
    return layout.frame.size.height;
}

#pragma UITableViewDelegate

#pragma scrollViewDelegate
//在拖拽结束的时候计算即将展示的cell并计算其中布局相关
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    //labs()取整数的绝对值函数
    NSIndexPath *targetIP = [self indexPathForRowAtPoint:CGPointMake(0, targetContentOffset->y)];
    NSIndexPath *showIP = [[self indexPathsForVisibleRows] firstObject];
    NSInteger loadCount = LoadCellCount;
    if (labs(targetIP.row - showIP.row) > loadCount) {
        //temp中为滑动停止后展示在屏幕中的cell的indexpath
        NSArray *temp = [self indexPathsForRowsInRect:CGRectMake(0, targetContentOffset->y, ScreenWidth, ScreenHeight)];
        NSMutableArray *arr = [NSMutableArray arrayWithArray:temp];
        if (velocity.y < 0) { //向上滑动
            //indexPath是滑动停止后在屏幕中的最后一个cell的indexpath
            NSIndexPath *indexPath = [temp lastObject];
            if (indexPath.row+3<self.datas.count) {
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]];
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row+2 inSection:indexPath.section]];
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row+3 inSection:indexPath.section]];
            }
        } else { //向下滑动
            NSIndexPath *indexPath = [temp firstObject];
            if (indexPath.row > 3) {
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]];
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row-2 inSection:indexPath.section]];
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row-3 inSection:indexPath.section]];
            }
        }
        [self.needUpdataDatas addObjectsFromArray:arr];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.needUpdataDatas removeAllObjects];
}

-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    self.scrollToTop = YES;
    return YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.scrollToTop = NO;
    [self loadContents];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    self.scrollToTop = NO;
    [self loadContents];
    
}

//触摸事件一开始，就加载内容
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.scrollToTop) {
        [self.needUpdataDatas removeAllObjects];
        [self loadContents];
    }
    return [super hitTest:point withEvent:event];
}

- (void)loadContents {
    if (self.scrollToTop) {
        return;
    }
    if (self.indexPathsForVisibleRows.count <= 0) {
        return;
    }
    if (self.visibleCells && self.visibleCells.count > 0) {
        for (MXBestTableViewCell *cell in [self.visibleCells copy]) {
            [cell draw];
        }
    }
}

#pragma data
- (void)loadDatas {
    self.datas = [MXContent mj_objectArrayWithFilename:@"data.plist"];
}

@end
