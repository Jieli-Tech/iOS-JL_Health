//
//  BodyDataView.h
//  JieliJianKang
//
//  Created by kaka on 2021/2/19.
//

#import <UIKit/UIKit.h>

@class BodyDataView;
NS_ASSUME_NONNULL_BEGIN
@interface BodyDataObject : NSObject

@property(nonatomic,strong)UIImage *img;
@property(nonatomic,strong)NSString *funcStr;
@property(nonatomic,strong)NSAttributedString *detailStr;
@property(nonatomic,assign)int funType;
@end

@protocol BodyDataViewDelegate <NSObject>

-(void)bodyData:(BodyDataView *) view Selected:(BodyDataObject *)object;

@end

@interface BodyDataView : UIView
@property(nonatomic,weak)id<BodyDataViewDelegate> delegate;

/// 健康数据的内容
/// @param array 我的数据列表
-(void)config:(NSArray<BodyDataObject *>*)array;

@end

NS_ASSUME_NONNULL_END
