//
//  TransferView.h
//  JieliJianKang
//
//  Created by kaka on 2021/3/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TransferViewDelegate <NSObject>

-(void)transferAllMusicFinish;


@end

@interface TransferView : UIView
@property (weak, nonatomic) id<TransferViewDelegate> delegate;
@property (assign, nonatomic) int totalCount;
@property (assign, nonatomic) NSArray *selectArray;
@end

NS_ASSUME_NONNULL_END
