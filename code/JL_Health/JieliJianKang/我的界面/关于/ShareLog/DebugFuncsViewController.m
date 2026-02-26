//
//  DebugFuncsViewController.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/10/17.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "DebugFuncsViewController.h"
#import "JLShareLogViewController.h"


@interface DebugFuncsViewController ()

@end

@implementation DebugFuncsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.itemArray setArray:@[@"share log",@"customer command"]];
    self.title = @"Debug Helper";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    switch (indexPath.row) {
        case 0:{
            JLShareLogViewController *vc = [[JLShareLogViewController alloc] init];
            [self.navigationController pushViewController:vc animated:true];
        }break;
        
        default:
            break;
    }
}

-(void)backBtnAction{
    [self dismissViewControllerAnimated:true completion:nil];
}


@end
