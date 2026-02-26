//
//  HealthFuncCell.m
//  JieliJianKang
//
//  Created by EzioChan on 2022/11/2.
//

#import "HealthFuncCell.h"

@interface HealthFuncCell(){

    
}

@end

@implementation HealthFuncCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


+(instancetype)cellWithTable:(UITableView *)tableView{
    static NSString *identifier = @"healthCell";
    //从缓存池中找
    HealthFuncCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //设置背景色
    [cell setBackgroundColor:[UIColor whiteColor]];
    
    if (cell == nil) {
        cell = [[HealthFuncCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    return cell;
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){

        self.mainLab = [UILabel new];
        self.mainLab.font = [UIFont systemFontOfSize:15];
        self.mainLab.textColor = [JLColor colorWithString:@"#242424"];
        self.mainLab.numberOfLines = 0;
        
        self.secLab = [UILabel new];
        self.secLab.font = [UIFont systemFontOfSize:12];
        self.secLab.textColor = [JLColor colorWithString:@"#919191"];
        self.secLab.numberOfLines = 0;
        
        self.rightLab = [UILabel new];
        self.rightLab.font = [UIFont systemFontOfSize:13];
        self.rightLab.textAlignment = NSTextAlignmentRight;
        self.rightLab.textColor = [JLColor colorWithString:@"#919191"];
        self.rightLab.numberOfLines = 0;
        
        self.imgv = [UIImageView new];
        self.imgv.image = [UIImage imageNamed:@"icon_next_nol"];
        
        [self.contentView addSubview:self.mainLab];
        [self.contentView addSubview:self.secLab];
        [self.contentView addSubview:self.rightLab];
        [self.contentView addSubview:self.imgv];
        
        
        [self.mainLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(10);
            make.left.equalTo(self.contentView.mas_left).offset(16);
            make.height.offset(20);
        }];
        
        [self.secLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mainLab.mas_bottom).offset(2);
            make.left.equalTo(self.contentView.mas_left).offset(16);
            make.height.offset(20);
        }];
        
        [self.rightLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.imgv.mas_left).offset(0);
            make.centerY.offset(0);
        }];
        [self.imgv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.offset(22);
            make.centerY.offset(0);
            make.right.equalTo(self.contentView.mas_right).offset(-12);
        }];
        
    }
    return self;
}

-(void)weatherHaveDetail:(BOOL)status{
    
    if(status){
        [self.mainLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(10);
            make.left.equalTo(self.contentView.mas_left).offset(16);
            make.height.offset(20);
        }];
    }else{
        [self.mainLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.offset(0);
            make.left.equalTo(self.contentView.mas_left).offset(16);
            make.height.offset(20);
        }];
    }
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

@implementation HealthCellObj

+(instancetype)initBasic:(NSString *)main Sec:(NSString *)sec{
    HealthCellObj *objc = [HealthCellObj new];
    objc.mainStr = main;
    objc.secStr = sec;
    return objc;
}



- (BOOL)supportSec{
    if(self.secStr && [self.secStr isEqualToString:@""]){
        return false;
    }else{
        return true;
    }
}



@end
