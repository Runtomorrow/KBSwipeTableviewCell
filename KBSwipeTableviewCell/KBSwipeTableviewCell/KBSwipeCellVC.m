//
//  KBSwipeCellVC.m
//  KBSwipeTableviewCell
//
//  Created by kobe on 2017/3/28.
//  Copyright © 2017年 kobe. All rights reserved.
//

#import "KBSwipeCellVC.h"
#import "KBSwipeCell.h"

@interface KBSwipeCellVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *indexPath;
@end

@implementation KBSwipeCellVC
static NSString *const CellID = @"CellID";

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
    [_tableView registerClass:[KBSwipeCell class] forCellReuseIdentifier:CellID];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    KBSwipeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    self.indexPath = indexPath;
    if (_indexPath == nil) {
        
    }else{
        KBSwipeCell *cell = [tableView cellForRowAtIndexPath:_indexPath];
//        [cell resetCellCloseStatus];
    }
}

@end
