//
//  JLGPSView.m
//  JieliJianKang
//
//  Created by 凌煊峰 on 2021/4/9.
//

#import "JLGPSView.h"
#import "JLGPSIntensityManager.h"

@interface JLGPSView () <JLGPSIntensityManagerDelegate>

@property (weak, nonatomic) IBOutlet UIView *lowSignalView;
@property (weak, nonatomic) IBOutlet UIView *middleSignalView;
@property (weak, nonatomic) IBOutlet UIView *highSignalView;
@property (nonatomic, assign) JLPSSignalStrength gpsSignalStrength;

@end

@implementation JLGPSView

+ (instancetype)gpsView {
    JLGPSView *gpsView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([JLGPSView class]) owner:nil options:nil] lastObject];
    gpsView.layer.cornerRadius = gpsView.height / 2;
    [gpsView setGpsSignalStrength:JLPSSignalStrengthUnknow];
    [JLGPSIntensityManager sharedInstance].delegate = gpsView;
    return gpsView;
}

- (void)resetIntensityManagerDelegate {
    [JLGPSIntensityManager sharedInstance].delegate = self;
}

- (void)setGpsSignalStrength:(JLPSSignalStrength)gpsSignalStrength {
    switch (gpsSignalStrength) {
        case JLPSSignalStrengthWeak:
            self.lowSignalView.backgroundColor = [UIColor greenColor];
            self.middleSignalView.backgroundColor = [JLColor colorWithString:@"#D8D8D8"];
            self.highSignalView.backgroundColor = [JLColor colorWithString:@"#D8D8D8"];
            break;
        case JLPSSignalStrengthSimple:
            self.lowSignalView.backgroundColor = [UIColor greenColor];
            self.middleSignalView.backgroundColor = [UIColor greenColor];
            self.highSignalView.backgroundColor = [JLColor colorWithString:@"#D8D8D8"];
            break;
        case JLPSSignalStrengthStrong:
            self.lowSignalView.backgroundColor = [UIColor greenColor];
            self.middleSignalView.backgroundColor = [UIColor greenColor];
            self.highSignalView.backgroundColor = [UIColor greenColor];
            break;
        default:
            self.lowSignalView.backgroundColor = [JLColor colorWithString:@"#D8D8D8"];
            self.middleSignalView.backgroundColor = [JLColor colorWithString:@"#D8D8D8"];
            self.highSignalView.backgroundColor = [JLColor colorWithString:@"#D8D8D8"];
            break;
    }
}

#pragma mark - JLGPSIntensityManagerDelegate

- (void)gpsIntensityManagerDidReceiveSignalStrength:(JLPSSignalStrength)gpsSignalStrength {
    [self setGpsSignalStrength:gpsSignalStrength];
}

@end
