//
//  MusicVC.m
//  QCY_Demo
//
//  Created by JL_HoPe on 2021/1/8.
//  Copyright © 2021 杰理科技. All rights reserved.
//

#import "MusicVC.h"

@interface MusicVC ()<UITableViewDelegate,UITableViewDataSource>{


    __weak IBOutlet UITableView *subTableView;
    __weak IBOutlet UILabel *subLabel;
    
    NSArray         *dataArray;
}

@end

@implementation MusicVC

- (void)viewDidLoad {
    [super viewDidLoad];


    
    [self updateUI];
}

-(void)updateUI{
    subTableView.delegate = self;
    subTableView.dataSource = self;
    subTableView.rowHeight = 45;
    subTableView.tableFooterView = [UIView new];
}

- (IBAction)btn_delete:(id)sender {
    
}
- (IBAction)btn_reflash:(id)sender {
    
}
- (IBAction)btn_musicInfo:(id)sender {

}

- (IBAction)btn_Root:(id)sender {

}

- (IBAction)btn_back:(id)sender {

}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
