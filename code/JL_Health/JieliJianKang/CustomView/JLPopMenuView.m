//
//  JLPopMenuView.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/7/14.
//

#import "JLPopMenuView.h"

@interface JLPopMenuViewItemObject()

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) TapBlock tapBlock;

@end

@implementation JLPopMenuViewItemObject

- (instancetype)initWithName:(NSString *)name withImageName:(NSString *)imageName withTapBlock:(TapBlock)tapBlock {
    self = [super init];
    if (self) {
        self.name = name;
        self.imageName = imageName;
        self.tapBlock = tapBlock;
    }
    return self;
}

@end

@interface JLPopMenuView ()

@property (strong, nonatomic) NSArray<JLPopMenuViewItemObject*> *itemObjectArray;
@property (strong, nonatomic) UIView *popMenu;
@property (strong, nonatomic) NSMutableArray<UIButton *> *btns;
@property (nonatomic, strong) TapBlock tapBlock;

@end

@implementation JLPopMenuView

- (instancetype)initWithStartPoint:(CGPoint)startPoint withItemObjectArray:(NSArray<JLPopMenuViewItemObject *> *)itemObjectArray {
    self = [super init];
    if (self) {
        
        self.itemObjectArray = itemObjectArray;
        self.btns = [NSMutableArray new];
        // 设置背景图
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        __weak typeof(self) weakSelf = self;
        self.tapBlock = ^{
            [weakSelf removeFromSuperview];
        };
        
        if (itemObjectArray.count > 0) {
            // 设置点击菜单
            _popMenu = [[UIView alloc] initWithFrame:CGRectMake(startPoint.x, startPoint.y, 160, 25 + 45 * itemObjectArray.count)];
            [self addSubview:_popMenu];
            _popMenu.layer.contents = (id)([UIImage imageNamed:@"img_textbox_nol"].CGImage);
            _popMenu.hidden = YES;
            
            // 设置菜单按钮
            for (int i = 0; i < itemObjectArray.count; i++) {
                JLPopMenuViewItemObject *object = itemObjectArray[i];
                
                UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 15 + 45 * i, _popMenu.frame.size.width, 44)];
                [btn addTarget:self action:@selector(handleEditEvent:) forControlEvents:UIControlEventTouchUpInside];
                [btn setTitle:object.name forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:object.imageName] forState:UIControlStateNormal];
                [btn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC" size:15]];
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [_popMenu addSubview:btn];
                btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                [btn setContentEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
                btn.tag = i;
                [self.btns addObject:btn];
                // 设置底部line
                if (i != (itemObjectArray.count - 1)) {
                    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, btn.frame.origin.y + btn.frame.size.height + 0.5, _popMenu.frame.size.width - 40, 0.5)];
                    [_popMenu addSubview:lineView];
                    lineView.backgroundColor = [UIColor colorWithRed:((238)/255.0) green:((238)/255.0) blue:((238)/255.0) alpha:(1.0f)];
                }
            }
        }
        
        [self addNote];
    }
    return self;
}

-(void)setTitleName:(NSArray *)array{
    if (array.count == self.itemObjectArray.count) {
        for (int i = 0; i<self.btns.count; i++) {
            UIButton *btn = self.btns[i];
            [btn setTitle:array[i] forState:UIControlStateNormal];
        }
    }
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    _popMenu.userInteractionEnabled = YES;
    _popMenu.hidden = hidden;
}

- (void)handleEditEvent:(UIButton *)btn {
    [self removeFromSuperview];
    JLPopMenuViewItemObject *object = [self.itemObjectArray objectAtIndex:btn.tag];
    if (object != nil && object.tapBlock != nil) {
        object.tapBlock();
    }
}

- (void)noteDeviceChange:(NSNotification*)note {
    JLDeviceChangeType type = [[note object] integerValue];
    if (type == JLDeviceChangeTypeInUseOffline || type == JLDeviceChangeTypeBleOFF) {
        self.hidden = YES;
    }
}


-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

- (void)dealloc {
    kJLLog(JLLOG_DEBUG, @"JLPopMenuView - dealloc");
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}

#pragma mark - Init Methods

- (instancetype)init {
    self = [super init];
    if (self) {
        [self innerInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self innerInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self innerInit];
    }
    return self;
}

- (void)innerInit {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBtnFunc:)];
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (void)tapBtnFunc:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (self.tapBlock) {
        self.tapBlock();
    }
}

@end
