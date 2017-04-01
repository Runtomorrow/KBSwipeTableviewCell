//
//  KBSwipeCell.m
//  KBSwipeTableviewCell
//
//  Created by kobe on 2017/3/28.
//  Copyright © 2017年 kobe. All rights reserved.
//

#import "KBSwipeCell.h"
#import "Masonry.h"

@interface KBSwipeCell () <UIGestureRecognizerDelegate>
{
    NSUserDefaults *userDefaults;
}

@property (nonatomic, strong) UIButton *btnOne;
@property (nonatomic, strong) UIButton *btnTwo;

@property (nonatomic, strong) UIView *myContentView;
@property (nonatomic, strong) UILabel *textLab;


@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startRight;
@property (nonatomic, assign) CGFloat contentViewLeft;
@property (nonatomic, assign) CGFloat contentViewRight;
@property (nonatomic, strong) MASConstraint *contentView_Left;
@property (nonatomic, strong) MASConstraint *contentView_Right;

@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, strong) NSIndexPath *openIndexPath;
@end



@implementation KBSwipeCell

#pragma mark <lazyLoad>
- (UIButton *)btnOne{
    if (!_btnOne) {
        _btnOne = [UIButton buttonWithType:0];
        [_btnOne setTitle:@"Confirm" forState:0];
        _btnOne.backgroundColor = [UIColor blueColor];
        _btnOne.titleLabel.font = [UIFont systemFontOfSize:14];
        [_btnOne setTitleColor:[UIColor blackColor] forState:0];
    }
    return _btnOne;
}

- (UIButton *)btnTwo{
    if (!_btnTwo) {
        _btnTwo = [UIButton buttonWithType:0];
        [_btnTwo setTitle:@"Cancel" forState:0];
        _btnTwo.backgroundColor = [UIColor redColor];
        _btnTwo.titleLabel.font = [UIFont systemFontOfSize:14];
        [_btnTwo setTitleColor:[UIColor blackColor] forState:0];
    }
    return _btnTwo;
}

- (UIView *)myContentView{
    if (!_myContentView) {
        _myContentView = [UIView new];
        _myContentView.backgroundColor = [UIColor whiteColor];
    }
    return _myContentView;
}

- (UILabel *)textLab{
    if (!_textLab) {
        _textLab = [UILabel new];
        _textLab.font = [UIFont systemFontOfSize:14];
        _textLab.text = @"测试侧滑";
        _textLab.textColor = [UIColor blackColor];
    }
    return _textLab;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    [self.contentView addSubview:self.btnOne];
    [self.contentView addSubview:self.btnTwo];
    [self.contentView addSubview:self.myContentView];
    [_myContentView addSubview:self.textLab];
    
    self.panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panThisCell:)];
    self.panRecognizer.delegate = self;
    _myContentView.userInteractionEnabled = YES;
    [_myContentView addGestureRecognizer:_panRecognizer];
    
    self.contentViewLeft = 0;
    self.contentViewRight = 0;
    self.isOpen = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeAllCell:) name:@"CellStatus" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellForIndexPath:) name:@"CellStatusIndexPath" object:nil];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
}


- (void)panThisCell:(UIPanGestureRecognizer *)recognizer{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            //计算手势开始的起始坐标点
            self.panStartPoint = [recognizer translationInView:_myContentView];
            self.startRight = self.contentViewRight;
          
            
            
            NSDictionary *tempDict = [userDefaults objectForKey:@"CellIndexDict"];
            NSIndexPath *tempIndex = [NSIndexPath indexPathForRow:[tempDict[@"Row"] integerValue] inSection:[tempDict[@"Section"] integerValue]];
            
            if (tempIndex == _indexPath) {
                
            }else{
                
                NSDictionary *_tempDict = @{@"Row":@(_indexPath.row),@"Section":@(_indexPath.section)};
                [userDefaults setObject:_tempDict forKey:@"CellIndexDict"];
                [userDefaults synchronize];
                [self postNotification];
            }
            
        }
            break;
        case UIGestureRecognizerStateChanged:{
            //获取当前的位置
            CGPoint currentPoint = [recognizer translationInView:_myContentView];
            //手指滑动的距离
            CGFloat deltaX = currentPoint.x - _panStartPoint.x;
            BOOL panningLeft = NO;
            //手指往左边滑动
            if (currentPoint.x < _panStartPoint.x) {
                panningLeft = YES;
            }
            
            //处于的关闭的状态
            if (_startRight == 0) {
                //手指往右边滑动的时候
                if (!panningLeft) {
                    CGFloat constant = MAX(-deltaX, 0);
                    if (constant == 0) {
                        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
                    }else{
//                        self.contentViewRight = constant;
//                        [self changeFrame:constant];
                    }
                }
                //手指往左边滑动
                else{
                    CGFloat constant = MIN(-deltaX, [self buttonTotalWidth]);
                    if (constant == [self buttonTotalWidth]) {
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                    }else{
                        self.contentViewRight = constant;
                        [self changeFrame:constant];
                    }
                }
            }
            //处于打开的状态
            else{
                
                CGFloat adjustment = _startRight - deltaX;
                //手指往右边滑动
                if (!panningLeft) {
                    CGFloat constant = MAX(adjustment, 0);
                    if (constant == 0) {
                        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
                    }else{
                        self.contentViewRight = constant;
                          [self changeFrame:constant];
                    }
                }
                //手指往左边滑动
                else{
                    CGFloat constant = MIN(adjustment, [self buttonTotalWidth]);
                    if (constant == [self buttonTotalWidth]) {
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                    }else{
                        _contentViewRight = constant;
                        [self changeFrame:constant];
                    }
                }
            }
            self.contentViewLeft = -self.contentViewRight;
        }
            break;
        case UIGestureRecognizerStateEnded:
            //关闭状态
            if (_startRight == 0) {
                CGFloat halfButtonOne = CGRectGetWidth(self.btnOne.frame)/2;
                if (_contentViewRight >= halfButtonOne) {
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                }else{
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
                }
            }
            //打开状态
            else{
                CGFloat buttonTotal = CGRectGetWidth(_btnTwo.frame) + (CGRectGetWidth(_btnOne.frame)/2);
                if (_contentViewRight >= buttonTotal) {
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                }else{
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
                }
            }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            //关闭状态
            if (_startRight == 0) {
                [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
            }
            //打开状态
            else{
                [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
            }
        }
            break;
        default:
            break;
    }
}



- (void)prepareForReuse{
    [super prepareForReuse];
    [self resetConstraintContstantsToZero:NO notifyDelegateDidClose:YES];
}

- (CGFloat)buttonTotalWidth{
    return CGRectGetWidth(self.frame) - CGRectGetMinX(self.btnTwo.frame);
}


- (void)changeFrame:(CGFloat)distance{
    
    [_myContentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).with.offset(-distance);
        make.right.mas_equalTo(self.mas_right).with.offset(-distance);
    }];
    
    [_myContentView setNeedsUpdateConstraints];
    [_myContentView updateConstraintsIfNeeded];
    [UIView animateWithDuration:.25 animations:^{
        [self layoutIfNeeded];
    }];

}

- (void)resetConstraintContstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)endEditing{
    
   
    
    //如果是关闭状态
    if (_startRight == 0 && _contentViewRight == 0) {
        return;
    }
    _isOpen = NO;
    _contentViewRight = 0;
    _contentViewLeft = 0;
    
    _startRight = _contentViewRight;
    [_myContentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).with.offset(_contentViewLeft);
        make.right.mas_equalTo(self.mas_right).with.offset(_contentViewRight);
    }];
    
    [_myContentView setNeedsUpdateConstraints];
    [_myContentView updateConstraintsIfNeeded];
    [UIView animateWithDuration:.25 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)setConstraintsToShowAllButtons:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate{
    
    
    //处于打开状态
    if (_startRight == [self buttonTotalWidth] && _contentViewRight == [self buttonTotalWidth]) {
        return;
    }
    _isOpen = YES;
    //重新计算约束
    _contentViewLeft = -[self buttonTotalWidth];
    _contentViewRight = [self buttonTotalWidth];
    
    _startRight = _contentViewRight;
    [_myContentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).with.offset(_contentViewLeft);
        make.right.mas_equalTo(self.mas_right).with.offset(-_contentViewRight);
    }];
    
    [_myContentView setNeedsUpdateConstraints];
    [_myContentView updateConstraintsIfNeeded];
    [UIView animateWithDuration:.25 animations:^{
        [self layoutIfNeeded];
    }];
    
}


- (void)postCellForIndexPath{
    
     [[NSNotificationCenter defaultCenter]postNotificationName:@"CellStatusIndexPath" object:nil userInfo:nil];
}

- (void)postNotification{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CellStatus" object:nil userInfo:nil];
   
}

- (void)cellForIndexPath:(NSNotification *)notification{
    
    if (_openIndexPath == _indexPath) {
        
    }else{
        
        NSLog(@"%ld------->%ld",_openIndexPath.row,_indexPath.row);
        self.openIndexPath = _indexPath;
        [self postNotification];
    }
}

- (void)closeAllCell:(NSNotification *)notification{
    

//     NSLog(@"_isOpen value: %@" ,_isOpen ? @"YES":@"NO");
    
    if (_isOpen) {
        self.isOpen = NO;
        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


- (void)setIndexPath:(NSIndexPath *)indexPath{
    _indexPath = indexPath;
}

+ (BOOL)requiresConstraintBasedLayout{
    return YES;
}

- (void)updateConstraints{
    
    __weak typeof(self) weakSelf = self;
    
    [_btnOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.mas_right).with.offset(0);
        make.top.equalTo(weakSelf.mas_top).with.offset(0);
        make.bottom.equalTo(weakSelf.mas_bottom).offset(0);
        make.width.mas_equalTo(@(80));
    }];
    
    [_btnTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_btnOne.mas_left).with.offset(0);
        make.top.equalTo(weakSelf.mas_top).with.offset(0);
        make.bottom.equalTo(weakSelf.mas_bottom).offset(0);
        make.width.mas_equalTo(@(80));
    }];
    
    [_myContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.mas_top);
        make.bottom.equalTo(weakSelf.mas_bottom);
        make.left.equalTo(weakSelf.mas_left).with.offset(_contentViewLeft);
        make.right.equalTo(weakSelf.mas_right).with.offset(_contentViewRight);
    }];
    
    [_textLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_myContentView).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [super updateConstraints];
}


@end
