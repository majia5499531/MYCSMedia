//
//  GYRollingNoticeView.m
//  RollingNotice
//
//  Created by qm on 2017/12/4.
//  Copyright © 2017年 qm. All rights reserved.
//

#import "GYRollingNoticeView.h"
#import "GYNoticeViewCell.h"


#define kGYNotiWeakSelf(type)  __weak typeof(type) weak##type = type;
#define kGYNotiStrongSelf(type) __strong typeof(type) type = weak##type;

@interface GYRollingNoticeView ()
{
    int _cIdx;
    BOOL _needTryRoll;
}

@property (nonatomic, strong) NSMutableDictionary *cellClsDict;
@property (nonatomic, strong) NSMutableArray *reuseCells;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) GYNoticeViewCell *currentCell;
@property (nonatomic, strong) GYNoticeViewCell *willShowCell;
@property (nonatomic, assign) BOOL isAnimating;


@end

@implementation GYRollingNoticeView

@dynamic currentIndex;



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.clipsToBounds = YES;
        _stayInterval = 2;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleCellTapAction)];
        [self addGestureRecognizer:tap];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_needTryRoll)
    {
        [self reloadDataAndStartRoll];
        _needTryRoll = NO;
    }
}

-(void)dealloc
{
    NSLog(@"gyrooling dead");
}

- (void)registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier
{
    [self.cellClsDict setObject:NSStringFromClass(cellClass) forKey:identifier];
}


- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier
{
    [self.cellClsDict setObject:nib forKey:identifier];
}


- (__kindof GYNoticeViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    for (GYNoticeViewCell *cell in self.reuseCells)
    {
        
        if ([cell.reuseIdentifier isEqualToString:identifier])
        {
            return cell;
        }
    }
    
    id cellClass = self.cellClsDict[identifier];
    
    if ([cellClass isKindOfClass:[UINib class]])
    {
        UINib *nib = (UINib *)cellClass;
        
        NSArray *arr = [nib instantiateWithOwner:nil options:nil];
        GYNoticeViewCell *cell = [arr firstObject];
        [cell setValue:identifier forKeyPath:@"reuseIdentifier"];
        return cell;
    }
    else
    {
        Class cellCls = NSClassFromString(self.cellClsDict[identifier]);
        GYNoticeViewCell *cell = [[cellCls alloc] initWithReuseIdentifier:identifier];
        return cell;
    }
    
}


#pragma mark- rolling
- (void)layoutCurrentCellAndWillShowCell
{
    int count = (int)[self.dataSource numberOfRowsForRollingNoticeView:self];
    if (_cIdx > count - 1)
    {
        _cIdx = 0;
    }
    
    int willShowIndex = _cIdx + 1;
    if (willShowIndex > count - 1)
    {
        willShowIndex = 0;
    }
//    NSLog(@">>>>%d", _cIdx);
    
    float w = self.frame.size.width;
    float h = self.frame.size.height;
    
//    NSLog(@"count: %d,  _cIdx:%d  willShowIndex: %d", count, _cIdx, willShowIndex);

    if (!(w > 0 && h > 0))
    {
        _needTryRoll = YES;
        return;
    }
    if (!_currentCell)
    {
        // 第一次没有currentcell
        // currentcell is null at first time
        _currentCell = [self.dataSource rollingNoticeView:self cellAtIndex:_cIdx];
        _currentCell.frame  = CGRectMake(0, 0, w, h);
        [self addSubview:_currentCell];
        return;
    }
    
    
    
    _willShowCell = [self.dataSource rollingNoticeView:self cellAtIndex:willShowIndex];
    _willShowCell.frame = CGRectMake(0, h, w, h);
    [self addSubview:_willShowCell];
    
    
    if (GYRollingDebugLog) {
        NSLog(@"_currentCell  %p", _currentCell);
        NSLog(@"_willShowCell %p", _willShowCell);
    }

    [self.reuseCells removeObject:_currentCell];
    [self.reuseCells removeObject:_willShowCell];
    
    
}




#pragma mark - 操作API
-(void)reloadDataAndStartRoll
{
    [self stopRoll];

    NSInteger count = [self.dataSource numberOfRowsForRollingNoticeView:self];
    
    //没有则return
    if (count < 1)
    {
        return;
    }
    
    //重新布局
    [self layoutCurrentCellAndWillShowCell];
    
    
    //只有一行则不滚动
    if (count == 1)
    {
        return;
    }
    
    //不会马上执行，而是等待timeInterval后执行
    _timer = [NSTimer scheduledTimerWithTimeInterval:_stayInterval target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
}


- (void)stopRoll
{
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    _status = GYRollingNoticeViewStatusIdle;
    _isAnimating = NO;
    _cIdx = 0;
    [_currentCell removeFromSuperview];
    [_willShowCell removeFromSuperview];
    _currentCell = nil;
    _willShowCell = nil;
    [self.reuseCells removeAllObjects];
}


- (void)pause
{
    if (_timer)
    {
        [_timer setFireDate:[NSDate distantFuture]];
        _status = GYRollingNoticeViewStatusPause;
    }
}


- (void)resume
{
    if (_timer)
    {
        [_timer setFireDate:[NSDate distantPast]];
        _status = GYRollingNoticeViewStatusWorking;
    }
}


#pragma mark - Action
-(void)timerAction
{
    
    if (self.isAnimating)
    {
        return;
    }
    
    
    //重新布局
    [self layoutCurrentCellAndWillShowCell];
    
    
    float w = self.frame.size.width;
    float h = self.frame.size.height;
    
    self.isAnimating = YES;
    
    kGYNotiWeakSelf(self);
    [UIView animateWithDuration:0.5 animations:^{
        kGYNotiStrongSelf(self);
        
        self.currentCell.frame = CGRectMake(0, -h, w, h);
        self.willShowCell.frame = CGRectMake(0, 0, w, h);
        
        self.currentCell.alpha=0.1;
        self.willShowCell.alpha=1;
        
    } completion:^(BOOL finished) {
        kGYNotiStrongSelf(self);
        
        // fixed bug: reload data when animate running
        if (self.currentCell && self.willShowCell)
        {
            [self.reuseCells addObject:self.currentCell];
            [self.currentCell removeFromSuperview];
            self.currentCell = self.willShowCell;
        }
        self.isAnimating = NO;
        
        self -> _cIdx ++;
    }];
}


-(void)handleCellTapAction
{
    if ([self.delegate respondsToSelector:@selector(didClickRollingNoticeView:forIndex:)])
    {
        [self.delegate didClickRollingNoticeView:self forIndex:self.currentIndex];
    }
}



#pragma mark - 当前行
- (int)currentIndex
{
    int count = (int)[self.dataSource numberOfRowsForRollingNoticeView:self];
    if (_cIdx > count - 1)
    {
        _cIdx = 0;
    }
    return _cIdx;
}


#pragma mark- Getter
- (NSMutableDictionary *)cellClsDict
{
    if (nil == _cellClsDict)
    {
        _cellClsDict = [[NSMutableDictionary alloc]init];
    }
    return _cellClsDict;
}

- (NSMutableArray *)reuseCells
{
    if (nil == _reuseCells)
    {
        _reuseCells = [[NSMutableArray alloc]init];
    }
    return _reuseCells;
}


@end
