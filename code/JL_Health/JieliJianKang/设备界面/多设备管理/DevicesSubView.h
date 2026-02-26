//
//  DevicesSubView.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/7/21.
//

#import <UIKit/UIKit.h>

@class UserDeviceModel;
@protocol DevSubViewDelegate <NSObject>

-(void)devSubViewscrollToSomeModel:(UserDeviceModel *_Nonnull)model;

-(void)devSubViewAddBtnAction;

@end

NS_ASSUME_NONNULL_BEGIN

@interface DevicesSubView : UIView<UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property(nonatomic,strong)UICollectionView *colView;
@property(nonatomic,weak)id<DevSubViewDelegate> delegate;
-(void)cutEntityConnecting;
@end

NS_ASSUME_NONNULL_END
