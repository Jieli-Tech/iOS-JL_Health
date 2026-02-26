//
//  MindListView.h
//  NewJieliZhiNeng
//
//  Created by kaka on 2021/3/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JL_BLEKit/JL_BLEKit.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MindListMusicDelegate <NSObject>

-(void)editMusic; //添加音乐;
-(void)transferMusicWithSelectArray:(NSArray<NSString *> *)selectArray; //传输音乐到手表;


@end
@interface MindListView : UIView

@property(nonatomic,weak)id<MindListMusicDelegate> delegate;

@property(nonatomic,strong)UITableView *listTable;

-(void)getMusicList; //获取本地音乐列表
-(void)scrollToNowMusic;
-(void)selectAll;
-(void)cancelMusic;

@end

NS_ASSUME_NONNULL_END
