//
//  TransferView.h
//  JieliJianKang
//
//  Created by 李放 on 2021/3/15.
//  Modify By EzioChan 2024/03/08

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TransferViewDelegate <NSObject>

-(void)transferAllMusicFinish;


@end

@interface TransferView : UIView
@property (weak, nonatomic) id<TransferViewDelegate> delegate;
@property (assign, nonatomic) NSArray *selectArray;
@end

NS_ASSUME_NONNULL_END
