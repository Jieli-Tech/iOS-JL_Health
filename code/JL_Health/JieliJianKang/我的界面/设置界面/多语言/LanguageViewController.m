//
//  LanguageViewController.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/12/27.
//

#import "LanguageViewController.h"
#import "LanguageTbc.h"

@interface LanguageViewController ()<UITableViewDataSource,UITableViewDelegate,LanguagePtl>
@property (weak, nonatomic) IBOutlet UITableView *languageTable;
@property (weak, nonatomic) IBOutlet UIButton *existBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleHeight;
@property (strong,nonatomic) NSArray *itemArray;
@property (assign,nonatomic) NSInteger indexRow;
@property (assign,nonatomic) NSInteger selectedRow;
@end

@implementation LanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[LanguageCls share] add:self];
    _indexRow = [self setLanguage];
    _selectedRow = _indexRow;
    _titleLabel.text = kJL_TXT("设置语言");
    _itemArray = @[kJL_TXT("跟随系统"),kJL_TXT("简体中文"),kJL_TXT("英语"),kJL_TXT("日语"),
                   kJL_TXT("韩语"),kJL_TXT("法语"),kJL_TXT("德语"),kJL_TXT("意大利语")
                   ,kJL_TXT("葡萄牙语"),kJL_TXT("西班牙语"),kJL_TXT("瑞典语"),kJL_TXT("波兰语")
                   ,kJL_TXT("俄语"),kJL_TXT("土耳其语"),kJL_TXT("希伯来语"),kJL_TXT("泰语")
                   ,kJL_TXT("阿拉伯语"),kJL_TXT("越南语"),kJL_TXT("印尼语"),kJL_TXT("马来语")
                   ,kJL_TXT("波斯语")];
    _languageTable.delegate = self;
    _languageTable.dataSource = self;
    _languageTable.rowHeight = 55;
    _languageTable.tableFooterView = [UIView new];
    [_languageTable registerNib:[UINib nibWithNibName:@"LanguageTbc" bundle:nil] forCellReuseIdentifier:@"LanguageTbc"];
    
    CGFloat width = [self getWidthWithText:kJL_TXT("确定") height:45 font:15]+25;
   
    _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-width, kJL_HeightNavBar - 32, width, 45)];
    [_confirmBtn setTitleColor:[JLColor colorWithString:@"#919191"] forState:UIControlStateNormal];
    _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_confirmBtn setTitle:kJL_TXT("确定") forState:UIControlStateNormal];
    [_confirmBtn addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [_confirmBtn setUserInteractionEnabled:false];
    [self.view addSubview:_confirmBtn];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    _titleHeight.constant = kJL_HeightNavBar+10;
}

- (IBAction)existBtnAction:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

-(void)confirmAction{
    switch (_selectedRow) {
        case 0:{
            kJL_SET("auto");
        }break;
        case 1:{
            kJL_SET("zh-Hans");
        }break;
        case 2:{
            kJL_SET("en-GB");
        }break;
        case 3:{
            kJL_SET("ja");
        }break;
        case 4:{
            kJL_SET("ko");
        }break;
        case 5:{
            kJL_SET("fr");
        }break;
        case 6:{
            kJL_SET("de");
        }break;
        case 7:{
            kJL_SET("it");
        }break;
        case 8:{
            kJL_SET("pt-PT");
        }break;
        case 9:{
            kJL_SET("es");
        }break;
        case 10:{
            kJL_SET("sv");
        }break;
        case 11:{
            kJL_SET("pl");
        }break;
        case 12:{
            kJL_SET("ru");
        }break;
        case 13:{
            kJL_SET("tr");
        }break;
        case 14:{
            kJL_SET("he");
        }break;
        case 15:{
            kJL_SET("th");
        }break;
        case 16:{
            kJL_SET("ar");
        }break;
        case 17:{
            kJL_SET("vi");
        }break;
        case 18:{
            kJL_SET("id");
        }break;
        case 19:{
            kJL_SET("ms");
        }break;
        case 20:{
            kJL_SET("fa");
        }break;
        default:
            break;
    }
    [_confirmBtn setTitleColor:[JLColor colorWithString:@"#919191"] forState:UIControlStateNormal];
    _indexRow = [self setLanguage];
    _selectedRow = _indexRow;
    [_confirmBtn setUserInteractionEnabled:false];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _itemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LanguageTbc *cell = [tableView dequeueReusableCellWithIdentifier:@"LanguageTbc" forIndexPath:indexPath];
    cell.titleLab.text = _itemArray[indexPath.row];
    if (indexPath.row == _indexRow){
        cell.selectImgv.hidden = false;
    }else{
        cell.selectImgv.hidden = true;
    }
    if (indexPath.row == _selectedRow) {
        cell.selectImgv.hidden = false;
    }else{
        cell.selectImgv.hidden = true;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    _selectedRow = indexPath.row;
    if (_indexRow == _selectedRow) {
        [_confirmBtn setTitleColor:[JLColor colorWithString:@"#919191"] forState:UIControlStateNormal];
        [_confirmBtn setUserInteractionEnabled:false];
    }else{
        [_confirmBtn setTitleColor:[JLColor colorWithString:@"#558CFF"] forState:UIControlStateNormal];
        [_confirmBtn setUserInteractionEnabled:true];
    }
    [tableView reloadData];
}

-(NSInteger)setLanguage{
    if ([kJL_GET isEqualToString:@"zh-Hans"]) {
        return 1;
    }else if ([kJL_GET isEqualToString:@"en-GB"]) {
        return 2;
    }else if ([kJL_GET hasPrefix:@"ja"]) {
        return 3;
    }else if ([kJL_GET hasPrefix:@"ko"]){
        return 4;
    }else if ([kJL_GET hasPrefix:@"fr"]){
        return 5;
    }else if ([kJL_GET hasPrefix:@"de"]){
        return 6;
    }else if ([kJL_GET hasPrefix:@"it"]){
        return 7;
    }else if ([kJL_GET hasPrefix:@"pt"]){
        return 8;
    }else if ([kJL_GET hasPrefix:@"es"]){
        return 9;
    }else if ([kJL_GET hasPrefix:@"sv"]){
        return 10;
    }else if ([kJL_GET hasPrefix:@"pl"]){
        return 11;
    }else if ([kJL_GET hasPrefix:@"ru"]){
        return 12;
    }else if ([kJL_GET hasPrefix:@"tr"]){
        return 13;
    }else if ([kJL_GET hasPrefix:@"he"]){
        return 14;
    }else if ([kJL_GET hasPrefix:@"th"]){
        return 15;
    }else if ([kJL_GET hasPrefix:@"ar"]){
        return 16;
    }else if ([kJL_GET hasPrefix:@"vi"]){
        return 17;
    }else if ([kJL_GET hasPrefix:@"id"]){
        return 18;
    }else if ([kJL_GET hasPrefix:@"ms"]){
        return 19;
    }else if ([kJL_GET hasPrefix:@"fa"]){
        return 20;
    }else{
        return 0;
    }
}

-(void)languageChange{
    _titleLabel.text = kJL_TXT("设置语言");
   
    CGFloat width = [self getWidthWithText:kJL_TXT("确定") height:45 font:15]+25;
    
    _confirmBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-width, kJL_HeightNavBar - 32, width, 45);
    [_confirmBtn setTitle:kJL_TXT("确定") forState:UIControlStateNormal];
    _indexRow = [self setLanguage];
    _itemArray = @[kJL_TXT("跟随系统"),kJL_TXT("简体中文"),kJL_TXT("英语"),kJL_TXT("日语"),
                   kJL_TXT("韩语"),kJL_TXT("法语"),kJL_TXT("德语"),kJL_TXT("意大利语")
                   ,kJL_TXT("葡萄牙语"),kJL_TXT("西班牙语"),kJL_TXT("瑞典语"),kJL_TXT("波兰语")
                   ,kJL_TXT("俄语"),kJL_TXT("土耳其语"),kJL_TXT("希伯来语"),kJL_TXT("泰语")
                   ,kJL_TXT("阿拉伯语"),kJL_TXT("越南语"),kJL_TXT("印尼语"),kJL_TXT("马来语")
                   ,kJL_TXT("波斯语")];
    [_languageTable reloadData];
}

/// 计算宽度
/// @param text 文字
/// @param height 高度
/// @param font 字体
- (CGFloat)getWidthWithText:(NSString *)text height:(CGFloat)height font:(CGFloat)font{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil];
    return rect.size.width;
}

@end
