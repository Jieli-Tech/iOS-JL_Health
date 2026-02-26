//
//  MyPhoneVC.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/16.
//

#import "MyPhoneVC.h"
#import "JL_RunSDK.h"
#import "JHContactManager.h"
#import "JHTableViewCell.h"
#import "ChineseToPinyin.h"
#import <ContactsUI/ContactsUI.h>
#import "MyContactsVC.h"
#import "ContactsTool.h"
#import "JLFileTransferHelper.h"
#import "JHPersonModel.h"
#import "JLUI_Effect.h"

@interface MyPhoneVC ()<UITableViewDelegate,UITableViewDataSource,CNContactViewControllerDelegate,UISearchBarDelegate>{
    
    __weak IBOutlet UIView *subTitleView;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet UIButton *addContacts;
    __weak IBOutlet NSLayoutConstraint *titleHeight;
    
    UIImageView *noContactsImv;
    UILabel     *noContactsLabel;
    
    NSArray<JHPersonModel *> *persons;
    NSArray<NSArray * > *sortedPersons;
    NSArray *sectionTitles;
    UITableView *tableView;
    float sw;
    float sh;
    UISearchBar *searchBar;
    NSMutableArray *selectArray;//选中数据的数组
    NSMutableArray<JHPersonModel*> *searchResult;
    BOOL isSearchFlag; //是否开始搜索
    UITapGestureRecognizer *tapgs;
    
    JLModel_Device *modelDevice;
    
}



@end

@implementation MyPhoneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self addNote];

    modelDevice = [kJL_BLE_CmdManager outputDeviceModel];
    
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //[self refresh];
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(246, 247, 248, 1.0);
    titleHeight.constant = kJL_HeightNavBar;
    isSearchFlag = NO;
    selectArray = [NSMutableArray array];
    sw = [UIScreen mainScreen].bounds.size.width;
    sh = [UIScreen mainScreen].bounds.size.height;
    
    subTitleView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    cancelBtn.frame  = CGRectMake(16, kJL_HeightStatusBar-5, 55, 44);
    [cancelBtn setTitle:kJL_TXT("取消") forState:UIControlStateNormal];
    cancelBtn.hidden = YES;
    backBtn.frame  = CGRectMake(16, kJL_HeightStatusBar-5, 44, 44);
    backBtn.hidden = YES;
    addContacts.frame  = CGRectMake(sw-16-44, kJL_HeightStatusBar-5, 44, 44);
    [addContacts setTitle:kJL_TXT("添加") forState:UIControlStateNormal];
    addContacts.hidden = YES;
    titleName.text = kJL_TXT("未选择");
    titleName.bounds = CGRectMake(0, 0, self.view.frame.size.width, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+16);
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(16, kJL_HeightNavBar+20, sw-32, sh-kJL_HeightNavBar-20-10)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 70.0;
    tableView.tableFooterView = [UIView new];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.bounces = NO;
    tableView.scrollEnabled = NO;
    [self.view addSubview:tableView];
    tableView.sectionIndexColor = kDF_RGBA(133, 133, 133, 1.0);
    tableView.hidden = YES;
    
    searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 64, sw, 40)];
    searchBar.backgroundImage = [self imageWithColor:[UIColor clearColor] size:searchBar.bounds.size];
    searchBar.placeholder = @"搜索联系人";
    [searchBar setImage:[UIImage imageNamed:@"icon_search_nol"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    if (@available(iOS 13.0, *)) {
        searchBar.searchTextField.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
    } else {
        // Fallback on earlier versions
    }
    searchBar.delegate = self;
    tableView.tableHeaderView = searchBar;
    tableView.tableHeaderView.backgroundColor = kDF_RGBA(244, 246, 247, 1.0);
    [tableView reloadData];
    
    [self initSearchBar];
    
    noContactsImv = [[UIImageView alloc] initWithFrame:CGRectMake(sw/2-210/2, kJL_HeightNavBar+101, 210, 170)];
    noContactsImv.image = [UIImage imageNamed:@"img_empty_01"];
    noContactsImv.contentMode = UIViewContentModeCenter;
    [self.view addSubview:noContactsImv];
    noContactsImv.hidden = YES;
    
    noContactsLabel = [[UILabel alloc] init];
    noContactsLabel.frame = CGRectMake(sw/2-135/2,noContactsImv.frame.origin.y+noContactsImv.frame.size.height+24,135,21);
    noContactsLabel.numberOfLines = 0;
    [self.view addSubview:noContactsLabel];
    
    noContactsLabel.contentMode = UIViewContentModeCenter;
    NSMutableAttributedString *noContactsStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("当前手机通讯录为空") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 15],NSForegroundColorAttributeName: [UIColor colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1.0]}];
    noContactsLabel.attributedText = noContactsStr;
    noContactsLabel.hidden = YES;
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//            [self refresh];
//        });
    tapgs = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
}

-(void)initSearchBar{
    UITextField *searchField = [searchBar valueForKey:@"searchField"];
    if (searchField) {
        searchField.backgroundColor = [UIColor clearColor];
        searchField.layer.borderColor  = [UIColor clearColor].CGColor;
        [searchBar setBackgroundColor:[UIColor whiteColor]];
        searchBar.layer.borderWidth = 1;
        searchBar.layer.borderColor = [UIColor colorWithRed:212/255.0 green:212/255.0 blue:212/255.0 alpha:1.0].CGColor;
        searchBar.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
        searchBar.layer.cornerRadius = 19;
        //searchBar.layer.masksToBounds = YES;
    }
    
}

/** 取消searchBar背景色 */

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size

{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);

    UIGraphicsBeginImageContext(rect.size);

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

#pragma mark - UISearchBarDelegate
#pragma mark 搜索文字改变
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    isSearchFlag = YES;
    if (searchText.length>0){
        [self searchString:searchText];
    }
}

#pragma mark 搜索开始编辑
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.backgroundColor = [UIColor clearColor];
    searchBar.layer.borderColor = [UIColor clearColor].CGColor;
    
    UITextField *searchField = [searchBar valueForKey:@"searchField"];
    if (searchField) {
        [searchField setBackgroundColor:[UIColor whiteColor]];
        searchField.layer.borderWidth = 1;
        searchField.layer.borderColor = [UIColor colorWithRed:85/255.0 green:140/255.0 blue:255/255.0 alpha:1.0].CGColor;
        searchField.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
        searchField.layer.cornerRadius = 17;
        searchField.layer.masksToBounds = YES;
    }
    
    //设置取消按钮样式
    //首先取出cancelBtn
    UIButton *cancelBtn = [searchBar valueForKey:@"cancelButton"];
    //取消按钮文字
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    //取消按钮文字颜色
    [cancelBtn setTitleColor:kDF_RGBA(85, 140, 255, 1.0) forState:UIControlStateNormal];
    
}

#pragma mark  编辑
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    //展示取消按钮
    searchBar.showsCancelButton = YES;
    [self.view addGestureRecognizer:tapgs];
    return YES;
}
#pragma mark  编辑
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self tapAction];
}

-(void)tapAction{
    [searchBar resignFirstResponder];
    [self.view removeGestureRecognizer:tapgs];
}
#pragma mark 取消按钮点击
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self initSearchBar];
    
    searchBar.text = @"";
    //收起键盘
    [self tapAction];
    //隐藏取消按钮
    [searchBar setShowsCancelButton:NO animated:YES];
    
    isSearchFlag = NO;
    if(selectArray.count>0){
        [selectArray removeAllObjects];
    }
    [tableView reloadData];
}


- (BOOL)getData {
    JHContactManager *contactManager = [JHContactManager sharedInstance];
    if (![contactManager isAuthorized]) {
        [contactManager requestContactAuthorization:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refresh];
            });
        }];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.scrollEnabled = NO;
        return NO;
    } else {
        if(contactManager!=nil){
            
            [contactManager fetchAllPerson:^(NSArray<JHPersonModel *> *allPersons) {
                // 获取数据
                NSMutableArray<JHPersonModel *> *finalPersons = [NSMutableArray array];
                for (JHPersonModel *personModel in allPersons) {
                    // 过滤已经选择的数据
                    for (JHValue *jv in personModel.phones) {
                        JHPersonModel *md = [personModel copy];
                        md.phoneNum = jv.value;
                        BOOL addToLocal = true;
                        for (JHPersonModel *originalPersonModel in self.originalContactArray) {
                            if ([md.phoneNum isEqualToString:originalPersonModel.phoneNum]){
                                addToLocal = false;
                            }
                        }
                        if (addToLocal) {
                            [finalPersons addObject:md];
                        }
                    }
                }
                self->persons = [NSArray arrayWithArray:finalPersons];
                
                // 把表格恢复为可以滑动
                self->tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                self->tableView.separatorColor = [JLColor colorWithString:@"#F6F6F6"];
                self->tableView.scrollEnabled = YES;
            }];
        }
    }
    return YES;
}

- (void)refresh {
    // 数据刷新
    if ([self getData]) {
        // 排序
        [self sortPerson];
        // 填充数据
        [tableView reloadData];
    }
}

- (void)sortPerson {
    UILocalizedIndexedCollation *indexedCollation = [UILocalizedIndexedCollation currentCollation];
    NSMutableArray *mutableTitles = [[NSMutableArray alloc] initWithArray:[indexedCollation sectionTitles]];
    NSMutableArray<NSMutableArray *> *mutablePersons = [NSMutableArray arrayWithCapacity:mutableTitles.count];
    // 先把 27 个数组构建出来
    for (int i = 0; i < mutableTitles.count; ++i) {
        [mutablePersons addObject:[NSMutableArray array]];
    }
//    NSLog(@"%@", mutableTitles);
    // 开始用框架排序
    for (JHPersonModel *person in persons) {
        person.select = NO;
        NSInteger index = [indexedCollation sectionForObject:person collationStringSelector:@selector(fullName)];
        [mutablePersons[index] addObject:person];
    }

    // 移除为 0 的数组
    for (NSInteger j = [indexedCollation sectionTitles].count - 1; j >= 0; j--) {
//        NSLog(@"%d", j);
        if (mutablePersons[j].count == 0) {
            [mutablePersons removeObjectAtIndex:j];
            [mutableTitles removeObjectAtIndex:j];
        }
    }

    sectionTitles = [mutableTitles copy];
    sortedPersons = [mutablePersons copy];
    
    if(sortedPersons.count == 0){
        titleName.text = kJL_TXT("通讯录");
        backBtn.hidden = NO;
        noContactsImv.hidden = NO;
        noContactsLabel.hidden = NO;
        
        cancelBtn.hidden = YES;
        addContacts.hidden = YES;
        tableView.hidden = YES;
    } else {
        titleName.text = kJL_TXT("未选择");
        backBtn.hidden = YES;
        noContactsImv.hidden = YES;
        noContactsLabel.hidden = YES;
        
        cancelBtn.hidden = NO;
        addContacts.hidden = NO;
        tableView.hidden  = NO;
    }
}

// 编辑结束时推出返回
- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact {
    [viewController.navigationController popViewControllerAnimated:YES];  // 手动返回
}

#pragma mark Table View Delegate
// 返回组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(isSearchFlag){
        return 1;
    }else{
        return sortedPersons.count;
    }
}

// 返回每组的行数 section是组数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(isSearchFlag){
        return searchResult.count;
    }else{
        return sortedPersons[(NSUInteger) section].count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section

{
    UIView *myView = [[UIView alloc] init];
    myView.backgroundColor = kDF_RGBA(244, 246, 247, 1.0);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 18, 30, 30)];
    titleLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    titleLabel.text=sectionTitles[section];

    [myView addSubview:titleLabel];

    return myView;
}

// 获取头部标题
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return sectionTitles[section];
}

// 开启索引显示
- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return sectionTitles;
}

// 索引
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

// 单元格高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [JHTableViewCell getCellHeight:JHTableViewCellStyleDetail];
}

// 数据刷新  获取数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *str = @"Cell";
    JHTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (cell == nil) {
        cell = [[JHTableViewCell alloc] initWithMyStyle:JHTableViewCellStyleDetail reuseIdentifier:str];
    }
    JHPersonModel *personModel;
    if (isSearchFlag == YES) {
        JHPersonModel *person = searchResult[indexPath.row];
        personModel = person;
    }
    if (isSearchFlag == NO) {
        personModel = sortedPersons[indexPath.section][indexPath.row];
    }
    
    cell.personModel = personModel;
    
    if (personModel.select) {
        cell.backgroundColor = kDF_RGBA(241, 236, 255, 1.0);
        cell.selectImv.image =  [UIImage imageNamed:@"icon_music_sel"];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectImv.image =  [UIImage imageNamed:@"icon_music_unsel"];
    }
    
    cell.separatorInset = UIEdgeInsetsMake(0, 72, 0, 0);
    cell.layoutMargins = UIEdgeInsetsMake(0, 72, 0, 0);
    cell.layer.cornerRadius = 8;
    cell.layer.masksToBounds = YES;
    return cell;
}

// 选中时
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JHPersonModel *personModel;
    
    if(isSearchFlag){
        JHPersonModel *person = searchResult[indexPath.row];
        personModel = person;
        
        if(personModel.select){
            personModel.select = NO;
            [selectArray removeObject:searchResult[indexPath.row]];
        }else{
            personModel.select = YES;
            [selectArray addObject:searchResult[indexPath.row]];
        }
    }else{
        personModel = sortedPersons[indexPath.section][indexPath.row];
        if(personModel.select){
            personModel.select = NO;
            [selectArray removeObject:[sortedPersons[indexPath.section] objectAtIndex:indexPath.row]];
        }else{
            personModel.select = YES;
            [selectArray addObject:[sortedPersons[indexPath.section] objectAtIndex:indexPath.row]];
        }
    }
    
    if(selectArray.count == 0){
        titleName.text = kJL_TXT("未选择");
    }else{
        NSString *str;
        if([kJL_GET hasPrefix:@"zh"]){
            str = [NSString stringWithFormat:@"%@%d%@",kJL_TXT("已选择"),(int)selectArray.count,kJL_TXT("个")];
        }else{
            str = [NSString stringWithFormat:@"%@ %d %@",kJL_TXT("已选择"),(int)selectArray.count,kJL_TXT("个")];
        }
        titleName.text = str;
    }
    
    [tableView reloadData];
}

- (NSMutableArray<JHPersonModel *> *)searchResult {
    if (searchResult == nil)
        searchResult = [[NSMutableArray alloc] init];
    return searchResult;
}

- (void)searchString: (NSString *)str{
    if(selectArray.count>0){
        [selectArray removeAllObjects];
    }
    // 先清空当前搜索结果
    [self.searchResult removeAllObjects];
    // 遍历当前所有结果
    for (JHPersonModel *person in persons) {
        // 先匹配手机号  只有纯数字匹配
        NSRange findResult;
        if ([self isNumber:str]){
            for (JHValue *phone in person.phones) {
                // 找到匹配
                findResult = [phone.value rangeOfString:str];
                if (findResult.location != NSNotFound){
                    JHPersonModel *result = [[JHPersonModel alloc] init];
                    result = person;
                    // 加入已找到队列中
                    [self.searchResult addObject:result];
                }
            }
        }

        // 全字匹配
        findResult = [person.fullName rangeOfString:str];
        if (findResult.location != NSNotFound){
            JHPersonModel *result = [[JHPersonModel alloc] init];
            result = person;
            // 加入已找到队列中
            [self.searchResult addObject:result];
        } else{  // 简拼
            str = [str lowercaseString];
            // 先查找姓氏 简拼
            findResult = [person.py rangeOfString:str];
            if (findResult.location != NSNotFound){
                JHPersonModel *result = [[JHPersonModel alloc] init];
                result = person;
                // 加入已找到队列中
                [self.searchResult addObject:result];

            }
            // 中文模糊搜索
            NSString *strPinYin;
            if ([self isChinese:str]){
                strPinYin = [ChineseToPinyin pinyinFromChineseString:str withSpace:NO];
            } else
                strPinYin = str;
            // 后查找全拼
            findResult = [person.pinyin rangeOfString:strPinYin];
            if (findResult.location != NSNotFound){
                JHPersonModel *result = [[JHPersonModel alloc] init];
                result = person;
                // 加入已找到队列中
                [self.searchResult addObject:result];
            }
        }
    }
    
    [tableView reloadData];
}

// 使用正则表达式判断输入是否全为数字
- (BOOL) isNumber:(NSString *)str
{
    if (str.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:str];
}

// 判断是否是中文
- (BOOL)isChinese:(NSString *)str {
    if (str.length == 0) {
        return NO;
    }
    NSString *match = @"(^.*[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:str];
}

- (IBAction)addMyContacts:(UIButton *)sender {
    if (selectArray.count == 0) {
        [DFUITools showText:kJL_TXT("请先选择联系人") onView:self.view delay:1.5];
        return;
    }
    
    NSInteger originalContactArrayCount = 0;
    if (_originalContactArray) {
        originalContactArrayCount = _originalContactArray.count;
    }
    if ((selectArray.count + originalContactArrayCount) > 10) {
        [DFUITools showText:kJL_TXT("只能添加10位常用联系人到手表") onView:self.view delay:1.5];
        return;
    }
    
    if (originalContactArrayCount > 0) {
        [selectArray addObjectsFromArray:_originalContactArray];
    }

    searchBar.text = @"";
    //收起键盘
    [searchBar resignFirstResponder];
    //隐藏取消按钮
    [searchBar setShowsCancelButton:NO animated:YES];
    isSearchFlag = NO;

    [self setContactsList];

}

- (IBAction)actionExit:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 发送生成的联系人数据
- (void)setContactsList {
    NSString *path;
    if(path == nil){
        path = [JL_Tools createOn:NSLibraryDirectory MiddlePath:@"" File:@"CALL.TXT"];
    }
    [JL_Tools writeData:[ContactsTool setContactsToData:selectArray] fillFile:path];
    [[ContactsTool share] syncContactsListWithPath:path Result:^(BOOL status) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
}


-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)removeNote{
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType type = [note.object intValue];
    if (type == JLDeviceChangeTypeInUseOffline ||
        type == JLDeviceChangeTypeBleOFF) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(void)dealloc{
    [self removeNote];
}

@end
