//
//  DocumentView.m
//  JLWatchDemo
//
//  Created by 杰理科技 on 2022/3/7.
//

#import "DocumentView.h"
#import "JLHeadFile.h"
#import "JLUI_Effect.h"

@interface DocumentView()<UITableViewDelegate,UITableViewDataSource>{
    
    __weak IBOutlet UITableView *subTableView;
    __weak IBOutlet UIButton *btnCancel;
    NSArray  *dataArray;
    
    DocumentResult documentResult;
}

@end

@implementation DocumentView

- (instancetype)init
{
    self = [DFUITools loadNib:@"DocumentView"];
    if (self) {
        float sW = [DFUITools screen_2_W];
        float sH = [DFUITools screen_2_H];
        
        subTableView.tableFooterView = [UIView new];
        subTableView.dataSource = self;
        subTableView.delegate   = self;
        subTableView.rowHeight  = 50.0;
        
        self.bounds = CGRectMake(0, 0, sW*0.9, sH*0.7);
        self.center = CGPointMake(sW/2.0, sH/2.0);
        
        self.layer.shadowColor  = [UIColor lightGrayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0,1);
        self.layer.shadowOpacity= 1;
        self.layer.shadowRadius = 10;
        self.layer.cornerRadius = 13;
        
        btnCancel.layer.cornerRadius = 13.0;
    }
    return self;
}

-(void)showWithPath:(NSString*)path Result:(DocumentResult)result{
    NSMutableArray *fileArray = [NSMutableArray new];
    NSArray *array = [JL_Tools subPaths:path];

    for (NSString *itemPath in array) {
//        NSString *file = [itemPath uppercaseString];
//        if ([file hasPrefix:@"WATCH"] ||
//            [file hasPrefix:@"BGP_W"]) {
            [fileArray addObject:itemPath];
//        }
    }
    dataArray = fileArray;
    documentResult = result;
    [subTableView reloadData];
}

-(void)showZipWithPath:(NSString*)path Result:(DocumentResult)result{
    NSMutableArray *fileArray = [NSMutableArray new];
    NSArray *array = [JL_Tools subPaths:path];

    for (NSString *itemPath in array) {
        if ([itemPath hasSuffix:@".zip"]) {
            [fileArray addObject:itemPath];
        }
    }
    dataArray = fileArray;
    documentResult = result;
    [subTableView reloadData];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* IDCell = @"FatsCELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDCell];
    }
    NSString *txt = dataArray[indexPath.row];
    NSString *file = [txt lastPathComponent];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    cell.textLabel.text = file;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
    
    if (documentResult) {
        NSString *file = dataArray[indexPath.row];
        documentResult(file);
        
        [self removeFromSuperview];
    }
}
- (IBAction)btn_Cancel:(id)sender {
    [self removeFromSuperview];
    if (documentResult) { documentResult = nil; }
}

@end
