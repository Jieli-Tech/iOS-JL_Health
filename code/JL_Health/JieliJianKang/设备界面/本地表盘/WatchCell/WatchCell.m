//
//  WatchCell.m
//  JieliJianKang
//
//  Created by 杰理科技 on 2021/2/22.
//

#import "WatchCell.h"
#import "JLPhoneUISetting.h"

@interface WatchCell(){
}
@end

@implementation WatchCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)setSubType:(WatchCellType)subType{
    _subType = subType;
    
    _subBtn.layer.cornerRadius = 12;
    [_subBtn setBackgroundColor:kDF_RGBA(240, 241, 245, 1.0)];
    [_subBtn setTitleColor:kDF_RGBA(85, 140, 255, 1.0) forState:UIControlStateNormal];
    
    
    [_subEditBtn setTitle:kJL_TXT("编辑") forState:UIControlStateNormal];

    //根据设备表盘形状，变更蒙版
    if ([[JL_RunSDK sharedMe] configModel].exportFunc.spDialInfoExtend) {    
        JLDialInfoExtentedModel *dialModel = [[JL_RunSDK sharedMe] dialInfoExtentedModel];
        if(dialModel.shape == 0x01){//圆
            [_subEditBgBtn setImage:[UIImage imageNamed:@"watch_bg_90"] forState:UIControlStateNormal];
        }else{//非圆时使用方形背景
            [_subEditBgBtn setImage:[UIImage imageNamed:@"watch_bg_88_quadrate"] forState:UIControlStateNormal];
        }
    }
    
    //闲置，可使用
    if (subType == WatchCellTypeUnUsed) {
        [_subBtn setTitle:kJL_TXT("使用") forState:UIControlStateNormal];
    }
    //正在使用
    if (subType == WatchCellTypeUsed) {
        [_subBtn setTitle:kJL_TXT("正在使用") forState:UIControlStateNormal];
    }
    //更新
    if (subType == WatchCellTypeUpdate) {
        [_subBtn setBackgroundColor:kDF_RGBA(126, 201, 125, 1.0)];
        [_subBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_subBtn setTitle:kJL_TXT("更新") forState:UIControlStateNormal];
    }
    //下载
    if (subType == WatchCellTypeDownload) {
        [_subBtn setTitle:kJL_TXT("下载") forState:UIControlStateNormal];
    }
}

-(void)setBuyPrice:(float)buyPrice{
    
    if (buyPrice == 0.0f) {
        [_subBtn setTitle:kJL_TXT("免费") forState:UIControlStateNormal];
    }else{
        [_subBtn setTitle:[NSString stringWithFormat:@"%@ %d",kJL_TXT("杰币"),(int)buyPrice] forState:UIControlStateNormal];
        
        if (buyPrice < 1.0f) {
            [_subBtn setTitle:[NSString stringWithFormat:@"%@ 1",kJL_TXT("杰币")] forState:UIControlStateNormal];
        }
    }
}
- (IBAction)tapWatch:(id)sender {
    if ([_delegate respondsToSelector:@selector(onWatchCell:didSelectIndex:)]) {
        NSLog(@"Watch face Select ---> %ld",(long)index);
        [_delegate onWatchCell:self didSelectIndex:self.subIndex];
    }
}

- (IBAction)btn_tap:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(onWatchCell:didSelectIndex:)]) {
        [_delegate onWatchCell:self didSelectIndex:self.subIndex];
    }
}
- (IBAction)btn_del:(id)sender {
    if ([_delegate respondsToSelector:@selector(onWatchCell:didDeleteIndex:)]) {
        [_delegate onWatchCell:self didDeleteIndex:self.subIndex];
    }
}

- (IBAction)btn_edit:(id)sender {
    if ([_delegate respondsToSelector:@selector(onWatchCell:didEditIndex:)]) {
        [_delegate onWatchCell:self didEditIndex:self.subIndex];
    }
}



@end
