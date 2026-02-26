//
//  StoreIAPManager.m
//  01-内购
//
//  Created by hp on 2022/5/15.
//  Copyright © 2022 itheima. All rights reserved.
//

#import "StoreIAPManager.h"
#import "NSData+Base64.h"

@interface StoreIAPManager ()<SKPaymentTransactionObserver,SKProductsRequestDelegate>{
    NSString            *_purchID;
    IAPCompletionHandle  _handle;
}
@end

@implementation StoreIAPManager

+ (instancetype)shareSIAPManager{
    static StoreIAPManager *IAPManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        IAPManager = [[StoreIAPManager alloc] init];
    });
    return IAPManager;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        // 购买监听写在程序入口,程序挂起时移除监听,这样如果有未完成的订单将会自动执行并回调 paymentQueue:updatedTransactions:方法
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)dealloc{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}


#pragma mark - 🚪public
- (void)startPurchWithID:(NSString *)purchID completeHandle:(IAPCompletionHandle)handle{
    if (purchID) {
        if ([SKPaymentQueue canMakePayments]) {
            // 开始购买服务
            _purchID = purchID;
            _handle = handle;
            NSSet *nsset = [NSSet setWithArray:@[purchID]];
            SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
            request.delegate = self;
            [request start];
        }else{
            [self handleActionWithType:SIAPPurchNotArrow data:nil];
        }
    }
}
#pragma mark - 🔒private
- (void)handleActionWithType:(SIAPPurchType)type data:(NSString *)data{
    switch (type) {
        case SIAPPurchSuccess:
            kJLLog(JLLOG_DEBUG, @"购买成功");
            break;
        case SIAPPurchFailed:
            kJLLog(JLLOG_DEBUG, @"购买失败");
            break;
        case SIAPPurchCancell:
            kJLLog(JLLOG_DEBUG, @"用户取消购买");
            break;
        case SIAPPurchVerFailed:
            kJLLog(JLLOG_DEBUG, @"订单校验失败");
            break;
        case SIAPPurchVerSuccess:
            kJLLog(JLLOG_DEBUG, @"订单校验成功");
            break;
        case SIAPPurchNotArrow:
            kJLLog(JLLOG_DEBUG, @"不允许程序内付费");
            break;
        case SIAPPurchVerFailedNoReply:
            kJLLog(JLLOG_DEBUG, @"订单校验失败,连接失败.");
            break;
        case SIAPPurchSellOut:
            kJLLog(JLLOG_DEBUG, @"商品已售罄.");
            break;
        case SIAPPurchasing:
            kJLLog(JLLOG_DEBUG, @"正在购买中.");
            break;
        default:
            break;
    }
    if(_handle){
        _handle(type,data);
    }
}
#pragma mark - 🍐delegate
// 交易结束
- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    
    // Your application should implement these two methods.

    
    [self verifyPurchaseWithPaymentTransaction:transaction isTestServer:NO];
}




// 交易失败
- (void)failedTransaction:(SKPaymentTransaction *)transaction{
    kJLLog(JLLOG_DEBUG, @"Failed--->交易失败： %ld", (long)transaction.error.code);
    if (transaction.error.code != SKErrorPaymentCancelled) {
        [self handleActionWithType:SIAPPurchFailed data:nil];
    }else{
        [self handleActionWithType:SIAPPurchCancell data:nil];
    }

    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


- (void)verifyPurchaseWithPaymentTransaction:(SKPaymentTransaction *)transaction isTestServer:(BOOL)flag{
    
    //NSString *productIdentifier = transaction.payment.productIdentifier;
    NSData *transactionReceiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    NSString *receiptStr = [transactionReceiptData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    receiptStr = [receiptStr stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    kJLLog(JLLOG_DEBUG, @"---> Receipt:%@",[receiptStr substringToIndex:64]);
    
    [self handleActionWithType:SIAPPurchVerSuccess data:receiptStr];

//    if(!receiptStr){
//        // 交易凭证为空验证失败
//        [self handleActionWithType:SIAPPurchVerFailed data:nil];
//        return;
//    }
//    // 购买成功将交易凭证发送给服务端进行再次校验
//    [self handleActionWithType:SIAPPurchSuccess data:nil];
//
//    NSError *error;
//    NSDictionary *requestContents = @{ @"receipt-data": [transactionReceiptData base64EncodedStringWithOptions:0] };
//    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents
//                                                          options:0
//                                                            error:&error];
//
//    if (!requestData) { // 交易凭证为空验证失败
//        [self handleActionWithType:SIAPPurchVerFailed data:nil];
//        return;
//    }
//
//    //In the test environment, use https://sandbox.itunes.apple.com/verifyReceipt
//    //In the real environment, use https://buy.itunes.apple.com/verifyReceipt
//
//    NSString *serverString = @"https://buy.itunes.apple.com/verifyReceipt";
//    if (flag) {
//        serverString = @"https://sandbox.itunes.apple.com/verifyReceipt";
//    }
//    NSURL *storeURL = [NSURL URLWithString:serverString];
//    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
//    [storeRequest setHTTPMethod:@"POST"];
//    [storeRequest setHTTPBody:requestData];
//
//    [[[NSURLSession sharedSession] dataTaskWithRequest:storeRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (error) {
//            // 无法连接服务器,购买校验失败
//            [self handleActionWithType:SIAPPurchVerFailedNoReply data:nil];
//        } else {
//            NSError *error;
//            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//            if (!jsonResponse) {
//                // 苹果服务器校验数据返回为空校验失败
//                [self handleActionWithType:SIAPPurchVerFailed data:nil];
//            }
//            // 先验证正式服务器,如果正式服务器返回21007再去苹果测试服务器验证,沙盒测试环境苹果用的是测试服务器
//            NSString *status = [NSString stringWithFormat:@"%@",jsonResponse[@"status"]];
//            if (status && [status isEqualToString:@"21007"]) {
//                [self verifyPurchaseWithPaymentTransaction:transaction isTestServer:YES];
//            }else if(status && [status isEqualToString:@"0"]){
//                kJLLog(JLLOG_DEBUG, @"----验证结果 %@",jsonResponse);
//                [self handleActionWithType:SIAPPurchVerSuccess data:receiptStr];
//            }
//        }
//    }] resume];
     //验证成功与否都注销交易,否则会出现虚假凭证信息一直验证不通过,每次进程序都得输入苹果账号
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    NSArray *product = response.products;
    if([product count] <= 0){
        kJLLog(JLLOG_DEBUG, @"--------------没有商品------------------");
        [self handleActionWithType:SIAPPurchSellOut data:nil];
        return;
    }

    SKProduct *p = nil;
    for(SKProduct *pro in product){
        if([pro.productIdentifier isEqualToString:_purchID]){
            p = pro;
            break;
        }
    }
    kJLLog(JLLOG_DEBUG, @"productID:%@", response.invalidProductIdentifiers);
    kJLLog(JLLOG_DEBUG, @"产品付费数量:%lu",(unsigned long)[product count]);
    kJLLog(JLLOG_DEBUG, @"%@",[p description]);
    kJLLog(JLLOG_DEBUG, @"%@",[p localizedTitle]);
    kJLLog(JLLOG_DEBUG, @"%@",[p localizedDescription]);
    kJLLog(JLLOG_DEBUG, @"%@",[p price]);
    kJLLog(JLLOG_DEBUG, @"%@",[p productIdentifier]);
    kJLLog(JLLOG_DEBUG, @"发送购买请求");

    SKPayment *payment = [SKPayment paymentWithProduct:p];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    kJLLog(JLLOG_DEBUG, @"------------------错误-----------------:%@", error);
}

- (void)requestDidFinish:(SKRequest *)request{
    kJLLog(JLLOG_DEBUG, @"------------反馈信息结束-----------------");
}

#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    for (SKPaymentTransaction *tran in transactions) {
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:{
                kJLLog(JLLOG_DEBUG, @"购买商品 --- %@",tran.payment.productIdentifier);
                [self completeTransaction:tran];
                //[self handleActionWithType:SIAPPurchSuccess data:nil];
                //[[SKPaymentQueue defaultQueue] finishTransaction:tran];
            }break;
            case SKPaymentTransactionStatePurchasing:{
                kJLLog(JLLOG_DEBUG, @"商品添加进列表");
            }break;
            case SKPaymentTransactionStateRestored:{
                kJLLog(JLLOG_DEBUG, @"已经购买过商品 --- %@",tran.payment.productIdentifier);
                
                // 消耗型不支持恢复购买
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
            }break;
            case SKPaymentTransactionStateFailed:{
                [self failedTransaction:tran];
            }break;
            case SKPaymentTransactionStateDeferred:{
                kJLLog(JLLOG_DEBUG, @"Deferred等待确认，儿童模式需要询问家长同意");
            }break;
                
            default: break;
        }
    }
    kJLLog(JLLOG_DEBUG, @"===>updatedTransactions:%lu",(unsigned long)transactions.count);
}

@end

/*注意事项：
 1.沙盒环境测试appStore内购流程的时候，请使用没越狱的设备。
 2.请务必使用真机来测试，一切以真机为准。
 3.项目的Bundle identifier需要与您申请AppID时填写的bundleID一致，不然会无法请求到商品信息。
 4.如果是你自己的设备上已经绑定了自己的AppleID账号请先注销掉,否则你哭爹喊娘都不知道是怎么回事。
 5.订单校验 苹果审核app时，仍然在沙盒环境下测试，所以需要先进行正式环境验证，如果发现是沙盒环境则转到沙盒验证。
 识别沙盒环境订单方法：
 1.根据字段 environment = sandbox。
 2.根据验证接口返回的状态码,如果status=21007，则表示当前为沙盒环境。
 苹果反馈的状态码：
 21000 App Store无法读取你提供的JSON数据
 21002 订单数据不符合格式，数据缺失了
 21003 订单无法被验证
 21004 你提供的共享密钥和账户的共享密钥不一致
 21005 订单服务器当前不可用
 21006 订单是有效的，但订阅服务已经过期。当收到这个信息时，解码后的收据信息也包含在返回内容中
 21007 订单信息是测试用（sandbox），但却被发送到产品环境中验证
 21008 订单信息是产品环境中使用，但却被发送到测试环境中验证
 
 Printing description of jsonResponse:
 {
     environment = Sandbox;
     receipt =     {
         "adam_id" = 0;
         "app_item_id" = 0;
         "application_version" = 10545;
         "bundle_id" = "com.JLApp.JieliJianKang";
         "download_id" = 0;
         "in_app" =         (
                         {
                 "in_app_ownership_type" = PURCHASED;
                 "is_trial_period" = false;
                 "original_purchase_date" = "2022-05-15 13:07:15 Etc/GMT";
                 "original_purchase_date_ms" = 1652620035000;
                 "original_purchase_date_pst" = "2022-05-15 06:07:15 America/Los_Angeles";
                 "original_transaction_id" = 2000000054718451;
                 "product_id" = JLPAYTEST0089;
                 "purchase_date" = "2022-05-15 13:07:15 Etc/GMT";
                 "purchase_date_ms" = 1652620035000;
                 "purchase_date_pst" = "2022-05-15 06:07:15 America/Los_Angeles";
                 quantity = 1;
                 "transaction_id" = 2000000054718451;
             },
                         {
                 "in_app_ownership_type" = PURCHASED;
                 "is_trial_period" = false;
                 "original_purchase_date" = "2022-05-16 07:34:52 Etc/GMT";
                 "original_purchase_date_ms" = 1652686492000;
                 "original_purchase_date_pst" = "2022-05-16 00:34:52 America/Los_Angeles";
                 "original_transaction_id" = 2000000055091164;
                 "product_id" = JLPAYTEST0090;
                 "purchase_date" = "2022-05-16 07:34:52 Etc/GMT";
                 "purchase_date_ms" = 1652686492000;
                 "purchase_date_pst" = "2022-05-16 00:34:52 America/Los_Angeles";
                 quantity = 1;
                 "transaction_id" = 2000000055091164;
             },
                         {
                 "in_app_ownership_type" = PURCHASED;
                 "is_trial_period" = false;
                 "original_purchase_date" = "2022-06-14 08:02:25 Etc/GMT";
                 "original_purchase_date_ms" = 1655193745000;
                 "original_purchase_date_pst" = "2022-06-14 01:02:25 America/Los_Angeles";
                 "original_transaction_id" = 2000000079029386;
                 "product_id" = JLPAYTEST0093;
                 "purchase_date" = "2022-06-14 08:02:25 Etc/GMT";
                 "purchase_date_ms" = 1655193745000;
                 "purchase_date_pst" = "2022-06-14 01:02:25 America/Los_Angeles";
                 quantity = 1;
                 "transaction_id" = 2000000079029386;
             },
                         {
                 "in_app_ownership_type" = PURCHASED;
                 "is_trial_period" = false;
                 "original_purchase_date" = "2022-06-14 07:55:32 Etc/GMT";
                 "original_purchase_date_ms" = 1655193332000;
                 "original_purchase_date_pst" = "2022-06-14 00:55:32 America/Los_Angeles";
                 "original_transaction_id" = 2000000079018136;
                 "product_id" = JLPAYTEST0094;
                 "purchase_date" = "2022-06-14 07:55:32 Etc/GMT";
                 "purchase_date_ms" = 1655193332000;
                 "purchase_date_pst" = "2022-06-14 00:55:32 America/Los_Angeles";
                 quantity = 1;
                 "transaction_id" = 2000000079018136;
             },
                         {
                 "in_app_ownership_type" = PURCHASED;
                 "is_trial_period" = false;
                 "original_purchase_date" = "2022-06-14 08:04:39 Etc/GMT";
                 "original_purchase_date_ms" = 1655193879000;
                 "original_purchase_date_pst" = "2022-06-14 01:04:39 America/Los_Angeles";
                 "original_transaction_id" = 2000000079034123;
                 "product_id" = JLPAYTEST0095;
                 "purchase_date" = "2022-06-14 08:04:39 Etc/GMT";
                 "purchase_date_ms" = 1655193879000;
                 "purchase_date_pst" = "2022-06-14 01:04:39 America/Los_Angeles";
                 quantity = 1;
                 "transaction_id" = 2000000079034123;
             }
         );
         "original_application_version" = "1.0";
         "original_purchase_date" = "2013-08-01 07:00:00 Etc/GMT";
         "original_purchase_date_ms" = 1375340400000;
         "original_purchase_date_pst" = "2013-08-01 00:00:00 America/Los_Angeles";
         "receipt_creation_date" = "2022-06-14 09:28:25 Etc/GMT";
         "receipt_creation_date_ms" = 1655198905000;
         "receipt_creation_date_pst" = "2022-06-14 02:28:25 America/Los_Angeles";
         "receipt_type" = ProductionSandbox;
         "request_date" = "2022-06-14 09:28:30 Etc/GMT";
         "request_date_ms" = 1655198910155;
         "request_date_pst" = "2022-06-14 02:28:30 America/Los_Angeles";
         "version_external_identifier" = 0;
     };
     status = 0;
 }
 
 Printing description of jsonResponse:
 {
     environment = Sandbox;
     receipt =     {
         "adam_id" = 0;
         "app_item_id" = 0;
         "application_version" = 10545;
         "bundle_id" = "com.JLApp.JieliJianKang";
         "download_id" = 0;
         "in_app" =         (
                         {
                 "in_app_ownership_type" = PURCHASED;
                 "is_trial_period" = false;
                 "original_purchase_date" = "2022-05-15 13:07:15 Etc/GMT";
                 "original_purchase_date_ms" = 1652620035000;
                 "original_purchase_date_pst" = "2022-05-15 06:07:15 America/Los_Angeles";
                 "original_transaction_id" = 2000000054718451;
                 "product_id" = JLPAYTEST0089;
                 "purchase_date" = "2022-05-15 13:07:15 Etc/GMT";
                 "purchase_date_ms" = 1652620035000;
                 "purchase_date_pst" = "2022-05-15 06:07:15 America/Los_Angeles";
                 quantity = 1;
                 "transaction_id" = 2000000054718451;
             },
                         {
                 "in_app_ownership_type" = PURCHASED;
                 "is_trial_period" = false;
                 "original_purchase_date" = "2022-05-16 07:34:52 Etc/GMT";
                 "original_purchase_date_ms" = 1652686492000;
                 "original_purchase_date_pst" = "2022-05-16 00:34:52 America/Los_Angeles";
                 "original_transaction_id" = 2000000055091164;
                 "product_id" = JLPAYTEST0090;
                 "purchase_date" = "2022-05-16 07:34:52 Etc/GMT";
                 "purchase_date_ms" = 1652686492000;
                 "purchase_date_pst" = "2022-05-16 00:34:52 America/Los_Angeles";
                 quantity = 1;
                 "transaction_id" = 2000000055091164;
             },
                         {
                 "in_app_ownership_type" = PURCHASED;
                 "is_trial_period" = false;
                 "original_purchase_date" = "2022-06-14 08:02:25 Etc/GMT";
                 "original_purchase_date_ms" = 1655193745000;
                 "original_purchase_date_pst" = "2022-06-14 01:02:25 America/Los_Angeles";
                 "original_transaction_id" = 2000000079029386;
                 "product_id" = JLPAYTEST0093;
                 "purchase_date" = "2022-06-14 08:02:25 Etc/GMT";
                 "purchase_date_ms" = 1655193745000;
                 "purchase_date_pst" = "2022-06-14 01:02:25 America/Los_Angeles";
                 quantity = 1;
                 "transaction_id" = 2000000079029386;
             },
                         {
                 "in_app_ownership_type" = PURCHASED;
                 "is_trial_period" = false;
                 "original_purchase_date" = "2022-06-14 07:55:32 Etc/GMT";
                 "original_purchase_date_ms" = 1655193332000;
                 "original_purchase_date_pst" = "2022-06-14 00:55:32 America/Los_Angeles";
                 "original_transaction_id" = 2000000079018136;
                 "product_id" = JLPAYTEST0094;
                 "purchase_date" = "2022-06-14 07:55:32 Etc/GMT";
                 "purchase_date_ms" = 1655193332000;
                 "purchase_date_pst" = "2022-06-14 00:55:32 America/Los_Angeles";
                 quantity = 1;
                 "transaction_id" = 2000000079018136;
             },
                         {
                 "in_app_ownership_type" = PURCHASED;
                 "is_trial_period" = false;
                 "original_purchase_date" = "2022-06-14 08:04:39 Etc/GMT";
                 "original_purchase_date_ms" = 1655193879000;
                 "original_purchase_date_pst" = "2022-06-14 01:04:39 America/Los_Angeles";
                 "original_transaction_id" = 2000000079034123;
                 "product_id" = JLPAYTEST0095;
                 "purchase_date" = "2022-06-14 08:04:39 Etc/GMT";
                 "purchase_date_ms" = 1655193879000;
                 "purchase_date_pst" = "2022-06-14 01:04:39 America/Los_Angeles";
                 quantity = 1;
                 "transaction_id" = 2000000079034123;
             }
         );
         "original_application_version" = "1.0";
         "original_purchase_date" = "2013-08-01 07:00:00 Etc/GMT";
         "original_purchase_date_ms" = 1375340400000;
         "original_purchase_date_pst" = "2013-08-01 00:00:00 America/Los_Angeles";
         "receipt_creation_date" = "2022-06-14 08:39:47 Etc/GMT";
         "receipt_creation_date_ms" = 1655195987000;
         "receipt_creation_date_pst" = "2022-06-14 01:39:47 America/Los_Angeles";
         "receipt_type" = ProductionSandbox;
         "request_date" = "2022-06-14 08:40:01 Etc/GMT";
         "request_date_ms" = 1655196001499;
         "request_date_pst" = "2022-06-14 01:40:01 America/Los_Angeles";
         "version_external_identifier" = 0;
     };
     status = 0;
 }
 */

