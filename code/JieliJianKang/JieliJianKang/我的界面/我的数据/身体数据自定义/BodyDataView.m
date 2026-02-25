//
//  BodyDataView.m
//  JieliJianKang
//
//  Created by kaka on 2021/2/19.
//

#import "BodyDataView.h"
#import "DeviceInfoTVCell.h"

@interface BodyDataView()<UITableViewDelegate,UITableViewDataSource>{
    NSArray *bodyDataArray;
    UITableView *subTable;
}

@end

@implementation BodyDataView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        subTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        subTable.rowHeight = 50.0;
        subTable.delegate = self;
        subTable.dataSource =self;
        subTable.scrollEnabled = NO;
        subTable.backgroundColor = [UIColor clearColor];
        subTable.separatorStyle = UITableViewCellSelectionStyleNone;
        [subTable registerNib:[UINib nibWithNibName:@"DeviceInfoTVCell" bundle:nil] forCellReuseIdentifier:@"normalTableCell"];
        [self addSubview:subTable];
    }
    return self;
}

-(void)config:(NSArray<BodyDataObject *>*)array{
    bodyDataArray = array;
    [subTable reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return bodyDataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceInfoTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normalTableCell" forIndexPath:indexPath];
    BodyDataObject *item = bodyDataArray[indexPath.row];
    cell.imgv.image = item.img;
    cell.funcTitle.text = item.funcStr;
    cell.detailTitle.attributedText = item.detailStr;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([_delegate respondsToSelector:@selector(bodyData:Selected:)]) {
        [_delegate bodyData:self Selected:bodyDataArray[indexPath.row]];
    }
}

@end

@implementation BodyDataObject

@end
