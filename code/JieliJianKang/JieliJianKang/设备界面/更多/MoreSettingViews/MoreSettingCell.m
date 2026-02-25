//
//  MoreSettingCell.m
//  JieliJianKang
//
//  Created by EzioChan on 2022/11/2.
//

#import "MoreSettingCell.h"

@implementation MoreSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(instancetype)cellWithTable:(UITableView *)tableView{
    static NSString *identifier = @"MoreSettingCell";
    //从缓存池中找
    MoreSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //设置背景色
    [cell setBackgroundColor:[UIColor whiteColor]];
    
    if (cell == nil) {
        cell = [[MoreSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    return cell;
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){

        self.mainLab = [[DFLabel alloc] initWithFrame:CGRectZero];
        self.mainLab.labelType = DFLeftRight;
        self.mainLab.textAlignment = NSTextAlignmentLeft;
        self.mainLab.font = [UIFont systemFontOfSize:15];
        self.mainLab.textColor = [JLColor colorWithString:@"#242424"];
        self.mainLab.numberOfLines = 0;
        
        self.secLab = [[DFLabel alloc] initWithFrame:CGRectZero];
        self.secLab.labelType = DFLeftRight;
        self.secLab.textAlignment = NSTextAlignmentLeft;
        self.secLab.font = [UIFont systemFontOfSize:12];
        self.secLab.textColor = [JLColor colorWithString:@"#919191"];
        self.secLab.numberOfLines = 0;
        
        self.rightLab = [[DFLabel alloc] initWithFrame:CGRectZero];
        self.rightLab.labelType = DFLeftRight;
        self.rightLab.textAlignment = NSTextAlignmentLeft;
        self.rightLab.font = [UIFont systemFontOfSize:13];
        self.rightLab.textAlignment = NSTextAlignmentRight;
        self.rightLab.textColor = [JLColor colorWithString:@"#919191"];
        self.rightLab.numberOfLines = 0;
        
        self.imgv = [UIImageView new];
        self.imgv.image = [UIImage imageNamed:@"icon_next_nol"];
        
        self.swView = [[UISwitch alloc] init];
        self.swView.onTintColor = kDF_RGBA(137, 94, 233, 1.0);
        self.swView.on = YES;
        [self.swView addTarget:self action:@selector(statusClick:) forControlEvents:UIControlEventValueChanged];
        
        
        [self.contentView addSubview:self.mainLab];
        [self.contentView addSubview:self.secLab];
        [self.contentView addSubview:self.rightLab];
        [self.contentView addSubview:self.imgv];
        [self.contentView addSubview:self.swView];
        
        
        [self.mainLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(10);
            make.left.equalTo(self.contentView.mas_right).offset(16);
            make.right.equalTo(self.rightLab.mas_left).offset(-8);
            make.height.offset(20);
        }];
        
        [self.secLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mainLab.mas_bottom).offset(2);
            make.left.equalTo(self.contentView.mas_left).offset(16);
            make.right.equalTo(self.rightLab.mas_left).offset(-8);
            make.height.offset(20);
        }];
        
        [self.rightLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.imgv.mas_left).offset(0);
            make.width.offset(100);
            make.centerY.offset(0);
        }];
        [self.imgv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.offset(22);
            make.centerY.offset(0);
            make.right.equalTo(self.contentView.mas_right).offset(-12);
        }];
        
        [self.swView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.offset(0);
            make.right.equalTo(self.contentView.mas_right).offset(-16);
        }];
    }
    return self;
}

-(void)weatherHaveDetail:(BOOL)status{
    
    if(status){
        [self.mainLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(10);
            make.left.equalTo(self.contentView.mas_left).offset(16);
            make.right.equalTo(self.rightLab.mas_left).offset(-8);
            make.height.offset(20);
        }];
    }else{
        [self.mainLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.offset(0);
            make.left.equalTo(self.contentView.mas_left).offset(16);
            make.right.equalTo(self.rightLab.mas_left).offset(-8);
            make.height.offset(20);
        }];
    }
}



-(void)statusClick:(UISwitch *)status{
    if([_delegate respondsToSelector:@selector(settingSwitchBack:onStatus:)]){
        [_delegate settingSwitchBack:self.mainLab.text onStatus:status.on];
    }
}




@end





@implementation MoreSettingObjc

+ (instancetype)initBasic:(NSString *)main Sec:(NSString *)sec{
    
    MoreSettingObjc *objc = [MoreSettingObjc new];
    objc.mainStr = main;
    objc.secStr = sec;
    return objc;
    
}

@end
