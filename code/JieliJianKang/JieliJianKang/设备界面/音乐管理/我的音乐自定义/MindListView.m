//
//  MindListView.m
//  NewJieliZhiNeng
//
//  Created by kaka on 2021/3/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "MindListView.h"
#import "JLMusicTableViewCell.h"

@interface MindListView() <UITableViewDelegate, UITableViewDataSource> {
    NSArray    *dataArray;
    NSMutableArray<NSString *> *selectArray;//选中数据的数组

    UIImageView *imvNull; //暂无歌曲显示的图片
    UILabel *label_music_null; //暂无本地音乐的文字
    UIButton *editBtn; //添加音乐
    UIButton *transBtn; //传输音乐
    
    float       sw;
    float       sh;
}

@end

@implementation MindListView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        
        sw = frame.size.width;
        sh = frame.size.height;
    
        [self initUI];
        [self setupUI];
        [self getMusicList];
        
        [self mulSelectMusic:editBtn];
    }
    return self;
}

-(void)initUI{
    selectArray = [NSMutableArray array];
    
    //暂无歌曲显示的图片
    imvNull = [[UIImageView alloc] initWithFrame:CGRectMake(sw/2-158.5/2, 129, 158.5, 109.5)];
    imvNull.image = [UIImage imageNamed:@"local_img_empty"];
    imvNull.contentMode = UIViewContentModeCenter;
    [self addSubview:imvNull];
    imvNull.hidden = YES;
    
    //暂无本地音乐的文字
    label_music_null = [[UILabel alloc] init];
    label_music_null.frame = CGRectMake(sw/2-100/2,imvNull.frame.origin.y+imvNull.frame.size.height+12,100,15);
    label_music_null.numberOfLines = 0;
    [self addSubview:label_music_null];
    label_music_null.contentMode = UIViewContentModeCenter;
    NSMutableAttributedString *label_music_null_str = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("暂无本地音乐") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 16],NSForegroundColorAttributeName: [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1.0]}];
    label_music_null.attributedText = label_music_null_str;
    label_music_null.hidden = YES;
}

-(void)setupUI{
    _listTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-54-48)];
    _listTable.tableFooterView = [UIView new];
    _listTable.rowHeight = 60;
    _listTable.backgroundColor = [UIColor clearColor];
    _listTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _listTable.dataSource = self;
    _listTable.delegate = self;
    [_listTable setSeparatorInset:(UIEdgeInsetsMake(0, 0, 0, 0))];
    [self addSubview:_listTable];
    [_listTable registerNib:[UINib nibWithNibName:NSStringFromClass(JLMusicTableViewCell.class) bundle:nil] forCellReuseIdentifier:NSStringFromClass(JLMusicTableViewCell.class)];
    
    editBtn = [[UIButton alloc] initWithFrame:CGRectMake(24,_listTable.frame.origin.y+_listTable.frame.size.height+10,sw-48,48)];
    [editBtn addTarget:self action:@selector(mulSelectMusic:) forControlEvents:UIControlEventTouchUpInside];
    [editBtn setTitle:kJL_TXT("添加音乐") forState:UIControlStateNormal];
    [editBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC" size:15]];
    [editBtn setTitleColor:kDF_RGBA(85, 140, 255, 1.0) forState:UIControlStateNormal];
    [editBtn setBackgroundColor:kDF_RGBA(240, 241, 241, 1.0)];
    editBtn.layer.cornerRadius = 24;
    editBtn.tag = 0;
    
    transBtn = [[UIButton alloc] initWithFrame:CGRectMake(24,_listTable.frame.origin.y+_listTable.frame.size.height+10,sw-48,48)];
    [transBtn addTarget:self action:@selector(mulSelectMusic:) forControlEvents:UIControlEventTouchUpInside];
    [transBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC" size:15]];
    [transBtn setTitleColor:kDF_RGBA(85, 140, 255, 1.0) forState:UIControlStateNormal];
    [transBtn setBackgroundColor:kDF_RGBA(240, 241, 241, 1.0)];
    transBtn.layer.cornerRadius = 24;
    [self addSubview:transBtn];
    transBtn.tag = 1;
    transBtn.hidden = YES;
}

//获取本地音乐列表
-(void)getMusicList{
    NSString *docPath = [DFFile listPath:NSDocumentDirectory MiddlePath:@"music" File:nil];
    dataArray = [DFFile subPaths:docPath];
    
    if (dataArray > 0) {
        [_listTable reloadData];
    }
    if (dataArray == 0) {
        imvNull.hidden = NO;
        label_music_null.hidden = NO;
    }else{
        imvNull.hidden = YES;
        label_music_null.hidden = YES;
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    JLMusicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(JLMusicTableViewCell.class)];
    if (cell == nil) {
        cell = [[JLMusicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(JLMusicTableViewCell.class)];
    }
    
    NSArray *array = [dataArray[indexPath.row] componentsSeparatedByString:@"-"];
    NSString *songName = @"";
    NSString *artist = @"";
    CGFloat fileSize = 0;
    BOOL selected = [selectArray containsObject:dataArray[indexPath.row]];
    if (array.count > 1) {
        songName = array[1];
        artist = array[0];
    } else {
        songName = dataArray[indexPath.row];
    }
    NSString *path = [DFFile listPath:NSDocumentDirectory MiddlePath:@"music" File:dataArray[indexPath.row]];
    NSError *attributesError;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&attributesError];
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    fileSize = [fileSizeNumber floatValue];
    
    [cell setTitle:songName description:artist fileSize:fileSize withIsSelected:selected];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([selectArray containsObject:[dataArray objectAtIndex:indexPath.row]]) {
        [selectArray removeObject:[dataArray objectAtIndex:indexPath.row]];
        [JL_Tools post:@"CLEAN_MUSIC_LIST" Object:nil];
    } else {
        [selectArray addObject:[dataArray objectAtIndex:indexPath.row]];
        if (selectArray.count == dataArray.count) {
            [JL_Tools post:@"CLEAN_MUSIC_LIST2" Object:nil];
        }
    }
    
    if (selectArray.count > 0) {
        NSString *title = [NSString stringWithFormat:@"%@ %@%lu%@%lu%@",kJL_TXT("同步音乐至手表"), @"(",(unsigned long)selectArray.count,@"/",(unsigned long)dataArray.count,@")"];
        [transBtn setTitle:title forState:UIControlStateNormal];
        transBtn.hidden = NO;
    } else {
        transBtn.hidden = YES;
    }
    editBtn.hidden = YES;
    
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

#pragma mark 编辑状态
- (void)mulSelectMusic:(UIButton *)btn {
    if(dataArray.count>0){
        if (btn.tag == 0) {
            if ([_delegate respondsToSelector:@selector(editMusic)]) {
                [_delegate editMusic];
            }
            
            if (selectArray.count > 0) {
                NSString *title = [NSString stringWithFormat:@"%@ %@%lu%@%lu%@",kJL_TXT("同步音乐至手表"), @"(",(unsigned long)selectArray.count,@"/",(unsigned long)dataArray.count,@")"];
                [transBtn setTitle:title forState:UIControlStateNormal];
                transBtn.hidden = NO;
            } else {
                transBtn.hidden = YES;
            }
            editBtn.hidden = YES;
            
            [_listTable reloadData];
        }
        if (btn.tag == 1) {
            if ([_delegate respondsToSelector:@selector(transferMusicWithSelectArray:)]) {
                [_delegate transferMusicWithSelectArray:selectArray];
            }
        }
    }
}

-(void)selectAll{
    [selectArray removeAllObjects];
    
    for (int i = 0; i < dataArray.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [selectArray addObject:[dataArray objectAtIndex:indexPath.row]];
    }
    
    if (selectArray.count > 0) {
        NSString *title = [NSString stringWithFormat:@"%@ %@%lu%@%lu%@",kJL_TXT("同步音乐至手表"), @"(",(unsigned long)selectArray.count,@"/",(unsigned long)dataArray.count,@")"];
        [transBtn setTitle:title forState:UIControlStateNormal];
        transBtn.hidden = NO;
    } else {
        transBtn.hidden = YES;
    }
    editBtn.hidden = YES;
    
    [_listTable reloadData];
}

#pragma mark 取消状态
- (void)cancelMusic {
    if (dataArray.count > 0) {
        [selectArray removeAllObjects];
        
        [editBtn setTitle:kJL_TXT("添加音乐") forState:UIControlStateNormal];
        transBtn.hidden = YES;
        editBtn.hidden = YES;
        [_listTable reloadData];
    }
}

- (void)scrollToNowMusic {
    if (dataArray.count == 0) return;
    
}

#pragma mark 媒体音乐播放状态
-(void)notePlayerState:(NSNotification *)note{
    [self->_listTable reloadData];
}




@end
