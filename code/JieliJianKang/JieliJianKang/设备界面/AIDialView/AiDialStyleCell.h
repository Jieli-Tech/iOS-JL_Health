//
//  AiDialStyleCell.h
//  JieliJianKang
//
//  Created by EzioChan on 2023/10/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AiDialStyleCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *mainImgv;
@property (weak, nonatomic) IBOutlet UIImageView *selectImgv;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;


-(void)setSelectStatus:(BOOL)status;

@end

NS_ASSUME_NONNULL_END
