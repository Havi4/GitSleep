//
//  DoubleQuarterReportViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/11/26.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "DoubleQuarterReportViewController.h"
#import "SLPagingViewController.h"
#import "HaviGetNewClient.h"
#import "ReportTableViewCell.h"
#import "NewWeekReport.h"
#import "ReportDataTableViewCell.h"
#import "SleepTimeTagView.h"
#import "QuaterCalenderView.h"
#import "NSDate+NSDateLogic.h"

@interface DoubleQuarterReportViewController ()

@property (nonatomic, strong) UIButton *leftMenuButton;
@property (nonatomic, strong) UIButton *rightMenuButton;

//左侧数据
//切换月份
@property (nonatomic,strong) UIButton *leftCalButton;
@property (nonatomic,strong) UIButton *rightCalButton;
@property (nonatomic,strong) UILabel *monthTitleLabel;
@property (nonatomic,strong) UIImageView *calenderImage;
@property (nonatomic,strong) UILabel *monthLabel;
@property (nonatomic,strong) NSDateFormatter *dateFormmatter;
@property (nonatomic,strong) NSDateFormatter *dateFormmatter1;

@property (nonatomic,strong) NSCalendar *calender;
@property (nonatomic,strong) NSTimeZone *tmZone;
@property (nonatomic,strong) NSDateComponents *dateComponents;
@property (nonatomic,strong) UIView *calenderBackView;
//
@property (nonatomic,strong) UITableView *reportTableView;
@property (nonatomic,strong) NewWeekReport *secondWeekReport;
@property (nonatomic,strong) SleepTimeTagView *longSleepView;
@property (nonatomic,strong) SleepTimeTagView *shortSleepView;
@property (nonatomic,strong) SleepTimeTagView *longRightSleepView;
@property (nonatomic,strong) SleepTimeTagView *shortRightSleepView;

//
//保存数据
@property (nonatomic,strong) NSDictionary *reportData;
@property (nonatomic,strong) NSMutableArray *mutableArr;
@property (nonatomic,strong) NSMutableArray *mutableTimeArr;
@property (nonatomic,strong) NSArray *dataTitleArr;
@property (nonatomic,strong) NSArray *dataCellArr;
//
@property (nonatomic,strong) UIView *sleepNightBottomLine;
@property (nonatomic,strong) UIView *noDataImageView;
@property (nonatomic,strong) UIView *noDataImageView1;

@property (nonatomic,strong) NSArray *dataRightCellArr;
//右侧数据
////
@property (nonatomic,strong) NSMutableArray *rightMutableArr;
@property (nonatomic,strong) NSMutableArray *rightMutableTimeArr;
@property (nonatomic,strong) NSDictionary *rightReportData;
@property (nonatomic,strong) UITableView *reportRightTableView;
@property (nonatomic,strong) NewWeekReport *secondRightWeekReport;


@end

@implementation DoubleQuarterReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataTitleArr = @[@[@"心率平均值",@"呼吸平均值"],@[@"心率异常数",@"呼吸异常数"],@[@"心率异常数高于",@"呼吸异常数高于"]];
    [self setPageViewController];
    [self.view addSubview:self.calenderBackView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (isDoubleDevice) {
        [self getLeftUserData];
        [self getRightUserData];
        
    }else{
        [self getLeftUserData];
        
    }
}


- (void)setPageViewController
{
    // Do any additional setup after loading the view.
    if (isDoubleDevice) {
        UILabel *navTitleLabel1 = [UILabel new];
        navTitleLabel1.text = thirdLeftDeviceName.length==0?@"Left":thirdLeftDeviceName;
        navTitleLabel1.font = [UIFont fontWithName:@"Helvetica" size:17];
        navTitleLabel1.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        
        UILabel *navTitleLabel2 = [UILabel new];
        navTitleLabel2.text = thirdRightDeviceName.length==0?@"Right":thirdRightDeviceName;;
        navTitleLabel2.font = [UIFont fontWithName:@"Helvetica" size:17];
        navTitleLabel2.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        
        SLPagingViewController *pageViewController = [[SLPagingViewController alloc] initWithNavBarItems:@[navTitleLabel1,navTitleLabel2]
                                                                                        navBarBackground:[UIColor clearColor]
                                                                                                   views:@[self.reportTableView,self.reportRightTableView]
                                                                                         showPageControl:YES];
        [pageViewController setCurrentPageControlColor:[UIColor whiteColor]];
        [pageViewController setTintPageControlColor:[UIColor colorWithWhite:0.799 alpha:1.000]];
        [pageViewController updateUserInteractionOnNavigation:NO];
        pageViewController.tintPageControlColor = [UIColor grayColor];
        pageViewController.currentPageControlColor = selectedThemeIndex == 0? DefaultColor: [UIColor whiteColor];
        
        
        // Twitter Like
        pageViewController.pagingViewMovingRedefine = ^(UIScrollView *scrollView, NSArray *subviews){
            float mid   = [UIScreen mainScreen].bounds.size.width/2 - 45.0;
            float width = [UIScreen mainScreen].bounds.size.width;
            CGFloat xOffset = scrollView.contentOffset.x;
            int i = 0;
            for(UILabel *v in subviews){
                CGFloat alpha = 0.0;
                if(v.frame.origin.x < mid)
                    alpha = 1 - (xOffset - i*width) / width;
                else if(v.frame.origin.x >mid)
                    alpha=(xOffset - i*width) / width + 1;
                else if(v.frame.origin.x == mid-5)
                    alpha = 1.0;
                i++;
                v.alpha = alpha;
            }
        };
        
        pageViewController.didChangedPage = ^(NSInteger currentPageIndex){
            // Do something
            NSLog(@"index %ld", (long)currentPageIndex);
        };
        pageViewController.navigationBarView.image = [UIImage imageNamed:@""];
        [pageViewController.navigationBarView addSubview:self.leftMenuButton];
        [pageViewController.navigationBarView addSubview:self.rightMenuButton];
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:pageViewController];
        [self addChildViewController:navi];
        navi.navigationBarHidden = YES;
        [self.view addSubview:navi.view];
    }else{
        UILabel *navTitleLabel2 = [UILabel new];
        navTitleLabel2.text = thirdHardDeviceName;
        navTitleLabel2.font = [UIFont fontWithName:@"Helvetica" size:17];
        navTitleLabel2.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        
        SLPagingViewController *pageViewController = [[SLPagingViewController alloc] initWithNavBarItems:@[navTitleLabel2]
                                                                                        navBarBackground:[UIColor clearColor]
                                                                                                   views:@[self.reportTableView]
                                                                                         showPageControl:YES];
        [pageViewController setCurrentPageControlColor:[UIColor whiteColor]];
        [pageViewController setTintPageControlColor:[UIColor colorWithWhite:0.799 alpha:1.000]];
        [pageViewController updateUserInteractionOnNavigation:NO];
        pageViewController.tintPageControlColor = [UIColor grayColor];
        if (thirdHardDeviceUUID.length == 0) {
            pageViewController.currentPageControlColor = [UIColor clearColor];
        }else{
            pageViewController.currentPageControlColor = selectedThemeIndex == 0? DefaultColor: [UIColor whiteColor];
        }
        
        // Twitter Like
        pageViewController.pagingViewMovingRedefine = ^(UIScrollView *scrollView, NSArray *subviews){
            float mid   = [UIScreen mainScreen].bounds.size.width/2 - 45.0;
            float width = [UIScreen mainScreen].bounds.size.width;
            CGFloat xOffset = scrollView.contentOffset.x;
            int i = 0;
            for(UILabel *v in subviews){
                CGFloat alpha = 0.0;
                if(v.frame.origin.x < mid)
                    alpha = 1 - (xOffset - i*width) / width;
                else if(v.frame.origin.x >mid)
                    alpha=(xOffset - i*width) / width + 1;
                else if(v.frame.origin.x == mid-5)
                    alpha = 1.0;
                i++;
                v.alpha = alpha;
            }
        };
        
        pageViewController.didChangedPage = ^(NSInteger currentPageIndex){
            // Do something
            NSLog(@"index %ld", (long)currentPageIndex);
        };
        pageViewController.navigationBarView.image = [UIImage imageNamed:@""];
        [pageViewController.navigationBarView addSubview:self.leftMenuButton];
        [pageViewController.navigationBarView addSubview:self.rightMenuButton];
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:pageViewController];
        [self addChildViewController:navi];
        navi.navigationBarHidden = YES;
        [self.view addSubview:navi.view];
    }
}

#pragma mark setter

- (UIButton *)leftMenuButton
{
    if (!_leftMenuButton) {
        _leftMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftMenuButton.backgroundColor = [UIColor clearColor];
        UIImage *i = [UIImage imageNamed:[NSString stringWithFormat:@"re_order_%d",selectedThemeIndex]];
        [_leftMenuButton setImage:i forState:UIControlStateNormal];
        [_leftMenuButton setFrame:CGRectMake(0, 20, 44, 44)];
        [_leftMenuButton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftMenuButton;
}

- (UIButton *)rightMenuButton
{
    if (!_rightMenuButton) {
        _rightMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightMenuButton.backgroundColor = [UIColor clearColor];
        UIImage *i = [UIImage imageNamed:[NSString stringWithFormat:@"btn_share_%d",selectedThemeIndex]];
        [_rightMenuButton setImage:i forState:UIControlStateNormal];
        [_rightMenuButton setFrame:CGRectMake(self.view.frame.size.width-50, 20, 44, 44)];
        [_rightMenuButton addTarget:self action:@selector(shareApp:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightMenuButton;
}


#pragma mark 获取用户数据

- (void)getLeftUserData
{
    NSString *year = [self.monthTitleLabel.text substringWithRange:NSMakeRange(0, 4)];
    NSString *fromMonth = [self.monthLabel.text substringWithRange:NSMakeRange(0, 2)];
    NSString *fromDateString = [NSString stringWithFormat:@"%@%@%@",year,fromMonth,@"01"];
    NSString *toMonth = [self.monthLabel.text substringWithRange:NSMakeRange(4, 2)];
    NSString *toDateString = [NSString stringWithFormat:@"%@%@%ld",year,toMonth,(long)[self getCurrentMonthDayNum:year month:toMonth]];
    [self getLeftTodayUserData:fromDateString endDate:toDateString withCompareDate:nil];
}

- (void)getLeftTodayUserData:(NSString *)fromDate endDate:(NSString *)endTime withCompareDate:(NSDate *)compDate
{
    if (![self isNetworkExist]) {
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
        return;
    }
    if ([thirdHardDeviceUUID isEqualToString:@""]) {
        [self.view makeToast:@"您还没有绑定设备,无法查看数据" duration:2 position:@"center"];
        return;
    }
    if (!fromDate) {
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&UserId=%@&FromDate=%@&EndDate=%@&FromTime=&EndTime=",thirdLeftDeviceUUID.length==0?thirdHardDeviceUUID:thirdLeftDeviceUUID,thirdPartyLoginUserId,fromDate,endTime];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    
    NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
                        [UIImage imageNamed:@"havi1_1"],
                        [UIImage imageNamed:@"havi1_2"],
                        [UIImage imageNamed:@"havi1_3"],
                        [UIImage imageNamed:@"havi1_4"],
                        [UIImage imageNamed:@"havi1_5"]];
    [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
    [MMProgressHUD showWithTitle:nil status:nil images:images];
    
    [WTRequestCenter getWithURL:[NSString stringWithFormat:@"%@%@",BaseUrl,urlString] headers:header parameters:nil option:WTRequestCenterCachePolicyNormal finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *resposeDic = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        [MMProgressHUD dismiss];
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        HaviLog(@"请求左侧周报数据%@和url%@",resposeDic,urlString);
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [self reloadLeftUserUI:(NSDictionary *)resposeDic];
            [MMProgressHUD dismiss];
        }else{
            [MMProgressHUD dismissWithError:[resposeDic objectForKey:@"ErrorMessage"] afterDelay:2];
        }
        
    } failed:^(NSURLResponse *response, NSError *error) {
        [MMProgressHUD dismiss];
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
}

- (void)reloadLeftUserUI:(NSDictionary *)dic
{
    HaviLog(@"周报数据是%@",dic);
    self.reportData = dic;
    self.dataCellArr = @[@[[NSString stringWithFormat:@"%d次/分钟",[[self.reportData objectForKey:@"AverageHeartRate"] intValue]],[NSString stringWithFormat:@"%d次/分钟",[[self.reportData objectForKey:@"AverageRespiratoryRate"] intValue]]],@[[NSString stringWithFormat:@"%d次",[[self.reportData objectForKey:@"FastHeartRateTimes"] intValue]+[[self.reportData objectForKey:@"SlowHeartRateTimes"] intValue]],[NSString stringWithFormat:@"%d次",[[self.reportData objectForKey:@"SlowRespiratoryRateTimes"] intValue]+[[self.reportData objectForKey:@"SlowHeartRateTimes"] intValue]]],@[[NSString stringWithFormat:@"%d%@",[[self.reportData objectForKey:@"AbnormalHeartRatePercent"] intValue],@"%用户"],[NSString stringWithFormat:@"%d%@",[[self.reportData objectForKey:@"AbnormalRespiratoryRatePercent"] intValue],@"%用户"]]];
    [self.reportTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1],[NSIndexPath indexPathForRow:2 inSection:1],[NSIndexPath indexPathForRow:3 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    [self.reportTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
    //
    NSArray *sleepArr = [self.reportData objectForKey:@"Data"];
    NSDictionary *longDic = nil;
    NSDictionary *shortDic = nil;
    for (NSDictionary *dic in sleepArr) {
        if ([[dic objectForKey:@"TagFlag"]intValue]==1) {
            longDic = dic;
        }else if ([[dic objectForKey:@"TagFlag"]intValue]==-1){
            shortDic = dic;
        }
    }
    
    self.longSleepView.grade = [[longDic objectForKey:@"SleepDuration"]floatValue]/24;
    self.shortSleepView.grade = [[shortDic objectForKey:@"SleepDuration"]floatValue]/24;
    if ([[NSString stringWithFormat:@"%@",[longDic objectForKey:@"Date"]]isEqualToString:@"(null)"]) {
        self.longSleepView.sleepYearMonthDayString = @"";
    }else{
        self.longSleepView.sleepYearMonthDayString = [NSString stringWithFormat:@"%@",[longDic objectForKey:@"Date"]];
    }
    float duration = [[longDic objectForKey:@"SleepDuration"]floatValue]<0?-[[longDic objectForKey:@"SleepDuration"]floatValue]:[[longDic objectForKey:@"SleepDuration"]floatValue];
    double second = 0.0;
    if (duration>0) {
        double subsecond = modf(duration, &second);
        self.longSleepView.sleepTimeLongString = [NSString stringWithFormat:@"%d小时%d分",(int)duration,(int)(subsecond*60)];
    }else if (duration==0){
        self.longSleepView.sleepTimeLongString = [NSString stringWithFormat:@""];
    }
    if ([[NSString stringWithFormat:@"%@",[shortDic objectForKey:@"Date"]]isEqualToString:@"(null)"]) {
        self.shortSleepView.sleepYearMonthDayString = @"";
    }else{
        self.shortSleepView.sleepYearMonthDayString = [NSString stringWithFormat:@"%@",[shortDic objectForKey:@"Date"]];
    }
    
    float duration1 = [[shortDic objectForKey:@"SleepDuration"]floatValue]<0?-[[shortDic objectForKey:@"SleepDuration"]floatValue]:[[shortDic objectForKey:@"SleepDuration"]floatValue];
    if (duration1>0) {
        double subsecond1 = modf(duration1, &second);
        self.shortSleepView.sleepTimeLongString = [NSString stringWithFormat:@"%d小时%d分",(int)duration1,(int)(subsecond1*60)];
    }else if (duration1==0){
        self.shortSleepView.sleepTimeLongString = [NSString stringWithFormat:@""];
    }
    [self reloadLeftReportChart:[self.reportData objectForKey:@"Data"]];
    
}

- (void)reloadLeftReportChart:(NSArray *)dataArr
{
    if (self.mutableArr.count>0) {
        [self.mutableArr removeAllObjects];
    }
    if (self.mutableTimeArr.count>0) {
        [self.mutableTimeArr removeAllObjects];
    }
    for (int i=0; i<3; i++) {
        [self.mutableArr addObject:[NSString stringWithFormat:@"0"]];
        [self.mutableTimeArr addObject:[NSString stringWithFormat:@"0"]];
    }
    
    NSString *monthFrom = [self.monthLabel.text substringWithRange:NSMakeRange(0, 2)];
    
    for (int i=0; i<dataArr.count; i++) {
        NSDictionary *dic = [dataArr objectAtIndex:i];
        NSString *dateString = [dic objectForKey:@"Date"];
        NSString *month = [dateString substringWithRange:NSMakeRange(5, 2)];
        int path = [month intValue]-[monthFrom intValue];
        [self.mutableArr replaceObjectAtIndex:path withObject:[NSString stringWithFormat:@"%@",[dic objectForKey:@"SleepQuality"]]];
        [self.mutableTimeArr replaceObjectAtIndex:path withObject:[NSString stringWithFormat:@"%@",[dic objectForKey:@"SleepDuration"]]];
        
    }
    if (dataArr.count>0) {
        [self.noDataImageView removeFromSuperview];
    }else{
        [self.secondWeekReport addSubview:self.noDataImageView];
        self.noDataImageView.center = self.secondWeekReport.center;
    }
    
    self.secondWeekReport.sleepQulityDataValues = self.mutableArr;
    self.secondWeekReport.sleepTimeDataValues = self.mutableTimeArr;
    [self.secondWeekReport reloadChartView];
}

- (void)getRightUserData
{
    NSString *year = [self.monthTitleLabel.text substringWithRange:NSMakeRange(0, 4)];
    NSString *fromMonth = [self.monthLabel.text substringWithRange:NSMakeRange(0, 2)];
    NSString *fromDateString = [NSString stringWithFormat:@"%@%@%@",year,fromMonth,@"01"];
    NSString *toMonth = [self.monthLabel.text substringWithRange:NSMakeRange(4, 2)];
    NSString *toDateString = [NSString stringWithFormat:@"%@%@%ld",year,toMonth,(long)[self getCurrentMonthDayNum:year month:toMonth]];
    [self getRightTodayUserData:fromDateString endDate:toDateString withCompareDate:nil];
}

- (void)getRightTodayUserData:(NSString *)fromDate endDate:(NSString *)endTime withCompareDate:(NSDate *)compDate
{
    if (![self isNetworkExist]) {
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
        return;
    }
    if ([thirdHardDeviceUUID isEqualToString:@""]) {
        [self.view makeToast:@"您还没有绑定设备,无法查看数据" duration:2 position:@"center"];
        return;
    }
    if (!fromDate) {
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&UserId=%@&FromDate=%@&EndDate=%@&FromTime=&EndTime=",thirdRightDeviceUUID,thirdPartyLoginUserId,fromDate,endTime];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    
    NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
                        [UIImage imageNamed:@"havi1_1"],
                        [UIImage imageNamed:@"havi1_2"],
                        [UIImage imageNamed:@"havi1_3"],
                        [UIImage imageNamed:@"havi1_4"],
                        [UIImage imageNamed:@"havi1_5"]];
    [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
    [MMProgressHUD showWithTitle:nil status:nil images:images];
    
    [WTRequestCenter getWithURL:[NSString stringWithFormat:@"%@%@",BaseUrl,urlString] headers:header parameters:nil option:WTRequestCenterCachePolicyNormal finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *resposeDic = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        [MMProgressHUD dismiss];
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        HaviLog(@"请求左侧周报数据%@和url%@",resposeDic,urlString);
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [self reloadRightUserUI:(NSDictionary *)resposeDic];
            [MMProgressHUD dismiss];
        }else{
            [MMProgressHUD dismissWithError:[resposeDic objectForKey:@"ErrorMessage"] afterDelay:2];
        }
        
    } failed:^(NSURLResponse *response, NSError *error) {
        [MMProgressHUD dismiss];
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
}

- (void)reloadRightUserUI:(NSDictionary *)dic
{
    self.rightReportData = dic;
    self.dataRightCellArr = @[@[[NSString stringWithFormat:@"%d次/分钟",[[self.rightReportData objectForKey:@"AverageHeartRate"] intValue]],[NSString stringWithFormat:@"%d次/分钟",[[self.rightReportData objectForKey:@"AverageRespiratoryRate"] intValue]]],@[[NSString stringWithFormat:@"%d次",[[self.rightReportData objectForKey:@"FastHeartRateTimes"] intValue]+[[self.rightReportData objectForKey:@"SlowHeartRateTimes"] intValue]],[NSString stringWithFormat:@"%d次",[[self.rightReportData objectForKey:@"SlowRespiratoryRateTimes"] intValue]+[[self.rightReportData objectForKey:@"SlowHeartRateTimes"] intValue]]],@[[NSString stringWithFormat:@"%d%@",[[self.rightReportData objectForKey:@"AbnormalHeartRatePercent"] intValue],@"%用户"],[NSString stringWithFormat:@"%d%@",[[self.rightReportData objectForKey:@"AbnormalRespiratoryRatePercent"] intValue],@"%用户"]]];
    [self.reportRightTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1],[NSIndexPath indexPathForRow:2 inSection:1],[NSIndexPath indexPathForRow:3 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    [self.reportRightTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
    //
    NSArray *sleepArr = [self.rightReportData objectForKey:@"Data"];
    NSDictionary *longDic = nil;
    NSDictionary *shortDic = nil;
    for (NSDictionary *dic in sleepArr) {
        if ([[dic objectForKey:@"TagFlag"]intValue]==1) {
            longDic = dic;
        }else if ([[dic objectForKey:@"TagFlag"]intValue]==-1){
            shortDic = dic;
        }
    }
    
    self.longRightSleepView.grade = [[longDic objectForKey:@"SleepDuration"]floatValue]/24;
    self.shortRightSleepView.grade = [[shortDic objectForKey:@"SleepDuration"]floatValue]/24;
    if ([[NSString stringWithFormat:@"%@",[longDic objectForKey:@"Date"]]isEqualToString:@"(null)"]) {
        self.longRightSleepView.sleepYearMonthDayString = @"";
    }else{
        self.longRightSleepView.sleepYearMonthDayString = [NSString stringWithFormat:@"%@",[longDic objectForKey:@"Date"]];
    }
    float duration = [[longDic objectForKey:@"SleepDuration"]floatValue]<0?-[[longDic objectForKey:@"SleepDuration"]floatValue]:[[longDic objectForKey:@"SleepDuration"]floatValue];
    double second = 0.0;
    if (duration>0) {
        double subsecond = modf(duration, &second);
        self.longRightSleepView.sleepTimeLongString = [NSString stringWithFormat:@"%d小时%d分",(int)duration,(int)(subsecond*60)];
    }else if (duration==0){
        self.longRightSleepView.sleepTimeLongString = [NSString stringWithFormat:@""];
    }
    if ([[NSString stringWithFormat:@"%@",[shortDic objectForKey:@"Date"]]isEqualToString:@"(null)"]) {
        self.shortRightSleepView.sleepYearMonthDayString = @"";
    }else{
        self.shortRightSleepView.sleepYearMonthDayString = [NSString stringWithFormat:@"%@",[shortDic objectForKey:@"Date"]];
    }
    
    float duration1 = [[shortDic objectForKey:@"SleepDuration"]floatValue]<0?-[[shortDic objectForKey:@"SleepDuration"]floatValue]:[[shortDic objectForKey:@"SleepDuration"]floatValue];
    if (duration1>0) {
        double subsecond1 = modf(duration1, &second);
        self.shortRightSleepView.sleepTimeLongString = [NSString stringWithFormat:@"%d小时%d分",(int)duration1,(int)(subsecond1*60)];
    }else if (duration1==0){
        self.shortRightSleepView.sleepTimeLongString = [NSString stringWithFormat:@""];
    }
    [self reloadRightReportChart:[self.rightReportData objectForKey:@"Data"]];
    
}

- (void)reloadRightReportChart:(NSArray *)dataArr
{
    if (self.rightMutableArr.count>0) {
        [self.rightMutableArr removeAllObjects];
    }
    if (self.rightMutableTimeArr.count>0) {
        [self.rightMutableTimeArr removeAllObjects];
    }
    for (int i=0; i<3; i++) {
        [self.rightMutableArr addObject:[NSString stringWithFormat:@"0"]];
        [self.rightMutableTimeArr addObject:[NSString stringWithFormat:@"0"]];
    }
    
    NSString *monthFrom = [self.monthLabel.text substringWithRange:NSMakeRange(0, 2)];
    
    for (int i=0; i<dataArr.count; i++) {
        NSDictionary *dic = [dataArr objectAtIndex:i];
        NSString *dateString = [dic objectForKey:@"Date"];
        NSString *month = [dateString substringWithRange:NSMakeRange(5, 2)];
        int path = [month intValue]-[monthFrom intValue];
        [self.rightMutableArr replaceObjectAtIndex:path withObject:[NSString stringWithFormat:@"%@",[dic objectForKey:@"SleepQuality"]]];
        [self.rightMutableTimeArr replaceObjectAtIndex:path withObject:[NSString stringWithFormat:@"%@",[dic objectForKey:@"SleepDuration"]]];
        
    }
    if (dataArr.count>0) {
        [self.noDataImageView1 removeFromSuperview];
    }else{
        [self.secondRightWeekReport addSubview:self.noDataImageView1];
        self.noDataImageView1.center = self.secondRightWeekReport.center;
    }
    
    self.secondRightWeekReport.sleepQulityDataValues = self.rightMutableArr;
    self.secondRightWeekReport.sleepTimeDataValues = self.rightMutableTimeArr;
    [self.secondRightWeekReport reloadChartView];
}


#pragma mark 日历delegate

- (void)selectedQuater:(NSString *)monthString
{
    self.monthTitleLabel.text = monthString;
    NSRange range = [monthString rangeOfString:@"年第"];
    NSString *quater = [monthString substringWithRange:NSMakeRange(range.location + range.length, 1)];
    NSString *selectedMonth = [self changeQuaterToMonth:[quater intValue]];
    if ([quater intValue]==1) {
        self.secondWeekReport.xValues = @[@"一月",@"二月",@"三月"];
    }else if ([quater intValue]==2){
        self.secondWeekReport.xValues = @[@"四月",@"五月",@"六月"];
    }else if ([quater intValue]==3){
        self.secondWeekReport.xValues = @[@"七月",@"八月",@"九月"];
    }else if ([quater intValue]==4){
        self.secondWeekReport.xValues = @[@"十月",@"十一月",@"十二月"];
    }
    
    self.monthLabel.text = selectedMonth;
    //更新数据
    if (isDoubleDevice) {
        [self getLeftUserData];
        [self getRightUserData];
        
    }else{
        [self getLeftUserData];
        
    }
}

- (NSInteger)getCurrentMonthDayNum:(NSString *)year month:(NSString *)month
{
    NSString *dateString = [NSString stringWithFormat:@"%@年%@月01",year,month];
    NSDate *date = [self.dateFormmatter1 dateFromString:dateString];
    NSInteger dayNum = [date getdayNumsInOneMonth];
    return dayNum;
}



#pragma mark setter

- (NSMutableArray *)rightMutableTimeArr
{
    if (!_rightMutableTimeArr) {
        _rightMutableTimeArr = [[NSMutableArray alloc]init];
    }
    return _rightMutableTimeArr;
}

- (NSMutableArray *)rightMutableArr
{
    if (!_rightMutableArr) {
        _rightMutableArr = [[NSMutableArray alloc]init];
    }
    return _rightMutableArr;
}


- (UITableView *)reportRightTableView
{
    if (_reportRightTableView == nil) {
        _reportRightTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStylePlain];
        _reportRightTableView.backgroundColor = [UIColor clearColor];
        _reportRightTableView.delegate = self;
        _reportRightTableView.dataSource = self;
        _reportRightTableView.showsVerticalScrollIndicator = NO;
        _reportRightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _reportRightTableView;
}


- (UIView*)noDataImageView
{
    if (!_noDataImageView) {
        _noDataImageView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, 105)];
        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(59, 16, 32.5, 32.5)];
        image.image = [UIImage imageNamed:[NSString stringWithFormat:@"sad-75_%d",selectedThemeIndex]];
        [_noDataImageView addSubview:image];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 49, 150, 30)];
        label.text= @"没有数据哦!";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:17];
        label.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        [_noDataImageView addSubview:label];
    }
    return _noDataImageView;
}

- (UIView*)noDataImageView1
{
    if (!_noDataImageView1) {
        _noDataImageView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, 105)];
        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(59, 16, 32.5, 32.5)];
        image.image = [UIImage imageNamed:[NSString stringWithFormat:@"sad-75_%d",selectedThemeIndex]];
        [_noDataImageView1 addSubview:image];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 49, 150, 30)];
        label.text= @"没有数据哦!";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:17];
        label.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        [_noDataImageView1 addSubview:label];
    }
    return _noDataImageView1;
}

- (UIView *)sleepNightBottomLine
{
    if (!_sleepNightBottomLine) {
        _sleepNightBottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, 59.5, self.view.frame.size.width, 0.5)];
        _sleepNightBottomLine.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.161f green:0.251f blue:0.365f alpha:1.00f]:[UIColor colorWithRed:0.349f green:0.608f blue:0.780f alpha:1.00f];
    }
    return _sleepNightBottomLine;
}

- (NSMutableArray *)mutableTimeArr
{
    if (!_mutableTimeArr) {
        _mutableTimeArr = [[NSMutableArray alloc]init];
    }
    return _mutableTimeArr;
}

- (NSMutableArray *)mutableArr
{
    if (!_mutableArr) {
        _mutableArr = [[NSMutableArray alloc]init];
    }
    return _mutableArr;
}

- (NewWeekReport*)secondWeekReport
{
    if (!_secondWeekReport) {
        _secondWeekReport = [[NewWeekReport alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216)];
        NSString *currentDate = [[NSString stringWithFormat:@"%@",[NSDate date]]substringToIndex:7];
        NSString *month = [currentDate substringWithRange:NSMakeRange(5, 2)];
        NSString *quater = [self changeMonthToQuater:month];
        if ([quater intValue]==1) {
            self.secondWeekReport.xValues = @[@"一月",@"二月",@"三月"];
        }else if ([quater intValue]==2){
            self.secondWeekReport.xValues = @[@"四月",@"五月",@"六月"];
        }else if ([quater intValue]==3){
            self.secondWeekReport.xValues = @[@"七月",@"八月",@"九月"];
        }else if ([quater intValue]==4){
            self.secondWeekReport.xValues = @[@"十月",@"十一月",@"十二月"];
        }
        _secondWeekReport.sleepQulityDataValues = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0"]];
        _secondWeekReport.sleepTimeDataValues = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0"]];
    }
    return _secondWeekReport;
}

- (NewWeekReport*)secondRightWeekReport
{
    if (!_secondRightWeekReport) {
        _secondRightWeekReport = [[NewWeekReport alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216)];
        NSString *currentDate = [[NSString stringWithFormat:@"%@",[NSDate date]]substringToIndex:7];
        NSString *month = [currentDate substringWithRange:NSMakeRange(5, 2)];
        NSString *quater = [self changeMonthToQuater:month];
        if ([quater intValue]==1) {
            self.secondRightWeekReport.xValues = @[@"一月",@"二月",@"三月"];
        }else if ([quater intValue]==2){
            self.secondRightWeekReport.xValues = @[@"四月",@"五月",@"六月"];
        }else if ([quater intValue]==3){
            self.secondRightWeekReport.xValues = @[@"七月",@"八月",@"九月"];
        }else if ([quater intValue]==4){
            self.secondRightWeekReport.xValues = @[@"十月",@"十一月",@"十二月"];
        }
        _secondRightWeekReport.sleepQulityDataValues = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0"]];
        _secondRightWeekReport.sleepTimeDataValues = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0"]];
    }
    return _secondRightWeekReport;
}

- (SleepTimeTagView *)shortSleepView
{
    if (_shortSleepView == nil) {
        _shortSleepView = [[SleepTimeTagView alloc]init ];
        self.shortSleepView.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
        _shortSleepView.sleepNightCategoryColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    }
    return _shortSleepView;
}

- (SleepTimeTagView *)longSleepView
{
    if (_longSleepView == nil) {
        _longSleepView = [[SleepTimeTagView alloc]init ];
        _longSleepView.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
        _longSleepView.sleepNightCategoryColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    }
    return _longSleepView;
}

- (SleepTimeTagView *)shortRightSleepView
{
    if (_shortRightSleepView == nil) {
        _shortRightSleepView = [[SleepTimeTagView alloc]init ];
        self.shortRightSleepView.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
        _shortRightSleepView.sleepNightCategoryColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    }
    return _shortRightSleepView;
}

- (SleepTimeTagView *)longRightSleepView
{
    if (_longRightSleepView == nil) {
        _longRightSleepView = [[SleepTimeTagView alloc]init ];
        _longRightSleepView.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
        _longRightSleepView.sleepNightCategoryColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    }
    return _longRightSleepView;
}


- (UITableView *)reportTableView
{
    if (_reportTableView == nil) {
        _reportTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStylePlain];
        _reportTableView.backgroundColor = [UIColor clearColor];
        _reportTableView.delegate = self;
        _reportTableView.dataSource = self;
        _reportTableView.showsVerticalScrollIndicator = NO;
        _reportTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _reportTableView;
}

- (UIView *)calenderBackView
{
    if (!_calenderBackView) {
        _calenderBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 69)];
        _calenderBackView.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.012f green:0.082f blue:0.184f alpha:1.00f]:[UIColor colorWithRed:0.349f green:0.608f blue:0.780f alpha:1.00f];
        //
        [_calenderBackView addSubview:self.monthTitleLabel];
        [self.monthTitleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_calenderBackView.centerX).offset(-10);
            make.height.equalTo(34.5);
            make.top.equalTo(_calenderBackView.top);
            
        }];
        //
        [_calenderBackView addSubview:self.calenderImage];
        [self.calenderImage makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.monthTitleLabel.right).offset(10);
            make.width.height.equalTo(20);
            make.centerY.equalTo(self.monthTitleLabel.centerY);
        }];
        //
        [_calenderBackView addSubview:self.leftCalButton];
        [self.leftCalButton makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.monthTitleLabel.left).offset(-15);
            make.centerY.equalTo(self.monthTitleLabel.centerY);
            make.height.equalTo(20);
            make.width.equalTo(15);
        }];
        //
        [_calenderBackView addSubview:self.rightCalButton];
        [self.rightCalButton makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.calenderImage.right).offset(15);
            make.centerY.equalTo(self.monthTitleLabel.centerY);
            make.height.equalTo(20);
            make.width.equalTo(15);
        }];
        //
        [_calenderBackView addSubview:self.monthLabel];
        [self.monthLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_calenderBackView);
            make.top.equalTo(self.monthTitleLabel.bottom);
            make.height.equalTo(34.5);
        }];
    }
    return _calenderBackView;
}

- (NSDateComponents*)dateComponents
{
    if (!_dateComponents) {
        _dateComponents = [[NSDateComponents alloc] init];
        _dateComponents.timeZone = self.tmZone;
    }
    return _dateComponents;
}

- (NSTimeZone *)tmZone
{
    if (!_tmZone) {
        _tmZone = [NSTimeZone timeZoneWithName:@"GMT"];
        [NSTimeZone setDefaultTimeZone:_tmZone];
    }
    return _tmZone;
}

- (NSCalendar *)calender
{
    if (!_calender) {
        _calender = [NSCalendar currentCalendar];
        _calender.timeZone = self.tmZone;
    }
    return _calender;
}

- (UIButton *)leftCalButton
{
    if (!_leftCalButton) {
        _leftCalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftCalButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_left_75_%d",selectedThemeIndex]] forState:UIControlStateNormal];
        [_leftCalButton addTarget:self action:@selector(lastQuater:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftCalButton;
}

- (UIButton *)rightCalButton
{
    if (!_rightCalButton) {
        _rightCalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightCalButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_right_75_%d",selectedThemeIndex]] forState:UIControlStateNormal];
        [_rightCalButton addTarget:self action:@selector(nextQuater:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightCalButton;
}

- (UILabel *)monthLabel
{
    if (!_monthLabel) {
        _monthLabel = [[UILabel alloc]init];
        _monthLabel.font = [UIFont systemFontOfSize:16];
        _monthLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _monthLabel.textAlignment = NSTextAlignmentCenter;
        NSString *currentDate = [[NSString stringWithFormat:@"%@",[NSDate date]]substringToIndex:7];
        NSString *month = [currentDate substringWithRange:NSMakeRange(5, 2)];
        NSString *quater = [self changeMonthToQuater:month];
        NSString *monthLength = [self changeQuaterToMonth:[quater intValue]];
        _monthLabel.text = monthLength;
    }
    return _monthLabel;
}

#pragma mark user action

- (void)showMonthCalender:(UITapGestureRecognizer *)gesture
{
    HaviLog(@"展示日历");
    NSString *dateString = self.monthTitleLabel.text;
    QuaterCalenderView *monthView = [[QuaterCalenderView alloc]init];
    monthView.frame = [UIScreen mainScreen].bounds;
    NSRange range = [dateString rangeOfString:@"年第"];
    NSString *sub1 = [dateString substringToIndex:range.location];
    NSString *sub2 = [dateString substringWithRange:NSMakeRange(range.location +range.length, 1)];
    monthView.quaterTitle = sub1;
    monthView.currentQuaterNum = [sub2 intValue];
    monthView.delegate = self;
    [[UIApplication sharedApplication].keyWindow addSubview:monthView];
    
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    theAnimation.delegate = self;
    theAnimation.duration = 0.5;
    theAnimation.repeatCount = 0;
    theAnimation.removedOnCompletion = FALSE;
    theAnimation.fillMode = kCAFillModeForwards;
    theAnimation.autoreverses = NO;
    theAnimation.fromValue = [NSNumber numberWithFloat:-[UIScreen mainScreen].bounds.size.height];
    theAnimation.toValue = [NSNumber numberWithFloat:0];
    [monthView.layer addAnimation:theAnimation forKey:@"animateLayer"];
}

- (NSString *)changeQuaterToMonth:(int)quater
{
    NSString *month ;
    switch (quater) {
        case 1:{
            month = @"01月到03月";
            return month;
            break;
        }
        case 2:{
            month = @"04月到06月";
            return month;
            break;
        }
        case 3:{
            month = @"07月到09月";
            return month;
            break;
        }
        case 4:{
            month = @"10月到12月";
            return month;
            break;
        }
            
        default:
            month = @"01月到03月";
            return month;
            break;
    }
}

- (NSString *)changeMonthToQuater:(NSString *)month
{
    int monthNum = [month intValue];
    if (monthNum>0 && monthNum<4) {
        return @"1";
    }else if (monthNum>3 && monthNum<7){
        return @"2";
    }else if (monthNum>6 && monthNum<10){
        return @"3";
    }else{
        return @"4";
    }
}

- (void)lastQuater:(UIButton *)sender
{
    NSRange range = [self.monthTitleLabel.text rangeOfString:@"年第"];
    NSString *year = [self.monthTitleLabel.text substringToIndex:range.location];
    NSString *quater = [self.monthTitleLabel.text substringWithRange:NSMakeRange(range.length +range.location, 1)];
    int nowQuater = [quater intValue] - 1;
    int nowYear = [year intValue];
    if (nowQuater==0) {
        nowQuater = 4;
        nowYear = nowYear - 1;
    }
    self.monthTitleLabel.text = [NSString stringWithFormat:@"%d年第%d季度",nowYear,nowQuater];
    //改变小标题
    NSString *subMonth = [self changeQuaterToMonth:nowQuater];
    self.monthLabel.text = subMonth;
    if (nowQuater==1) {
        self.secondWeekReport.xValues = @[@"一月",@"二月",@"三月"];
    }else if (nowQuater==2){
        self.secondWeekReport.xValues = @[@"四月",@"五月",@"六月"];
    }else if (nowQuater==3){
        self.secondWeekReport.xValues = @[@"七月",@"八月",@"九月"];
    }else if (nowQuater==4){
        self.secondWeekReport.xValues = @[@"十月",@"十一月",@"十二月"];
    }
    
    //改变
    if (isDoubleDevice) {
        [self getLeftUserData];
        [self getRightUserData];
        
    }else{
        [self getLeftUserData];
        
    }
    
}

- (void)nextQuater:(UIButton *)sender
{
    NSRange range = [self.monthTitleLabel.text rangeOfString:@"年第"];
    NSString *year = [self.monthTitleLabel.text substringToIndex:range.location];
    NSString *quater = [self.monthTitleLabel.text substringWithRange:NSMakeRange(range.length +range.location, 1)];
    int nowQuater = [quater intValue] + 1;
    int nowYear = [year intValue];
    if (nowQuater==5) {
        nowQuater = 1;
        nowYear = nowYear + 1;
    }
    self.monthTitleLabel.text = [NSString stringWithFormat:@"%d年第%d季度",nowYear,nowQuater];
    //改变小标题
    if (nowQuater==1) {
        self.secondWeekReport.xValues = @[@"一月",@"二月",@"三月"];
    }else if (nowQuater==2){
        self.secondWeekReport.xValues = @[@"四月",@"五月",@"六月"];
    }else if (nowQuater==3){
        self.secondWeekReport.xValues = @[@"七月",@"八月",@"九月"];
    }else if (nowQuater==4){
        self.secondWeekReport.xValues = @[@"十月",@"十一月",@"十二月"];
    }
    NSString *subMonth = [self changeQuaterToMonth:nowQuater];
    self.monthLabel.text = subMonth;
    //
    if (isDoubleDevice) {
        [self getLeftUserData];
        [self getRightUserData];
        
    }else{
        [self getLeftUserData];
        
    }
    
}

- (NSDate*)dayInTheLastMonth:(NSDate *)date
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = -1;
    dateComponents.day = 1;
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
}

- (NSDate *)dayInTheFollowingMonth:(NSDate *)date
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = 1;
    dateComponents.day = 1;
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
}


- (NSDateFormatter *)dateFormmatter
{
    if (!_dateFormmatter) {
        _dateFormmatter = [[NSDateFormatter alloc]init];
        [_dateFormmatter setDateFormat:@"yyyy年MM月"];
    }
    return _dateFormmatter;
}

- (NSDateFormatter *)dateFormmatter1
{
    if (!_dateFormmatter1) {
        _dateFormmatter1 = [[NSDateFormatter alloc]init];
        [_dateFormmatter1 setDateFormat:@"yyyy年MM月dd日"];
    }
    return _dateFormmatter1;
}


- (UILabel *)monthTitleLabel
{
    if (!_monthTitleLabel) {
        _monthTitleLabel = [[UILabel alloc]init];
        _monthTitleLabel.font = [UIFont systemFontOfSize:19];
        _monthTitleLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _monthTitleLabel.textAlignment = NSTextAlignmentCenter;
        NSString *currentDate = [[NSString stringWithFormat:@"%@",[NSDate date]]substringToIndex:7];
        NSString *year = [currentDate substringToIndex:4];
        NSString *month = [currentDate substringWithRange:NSMakeRange(5, 2)];
        NSString *quater = [self changeMonthToQuater:month];
        _monthTitleLabel.text = [NSString stringWithFormat:@"%@年第%@季度",year,quater];
    }
    return _monthTitleLabel;
}

- (UIImageView *)calenderImage
{
    if (!_calenderImage) {
        _calenderImage = [[UIImageView alloc]init];
        _calenderImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"menology_%d",selectedThemeIndex]];
        _calenderImage.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showMonthCalender:)];
        [_calenderImage addGestureRecognizer:tapImage];
    }
    return _calenderImage;
}

#pragma mark tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }else if (section==1) {
        return 4;
    }else{
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.reportTableView]) {
        if (indexPath.section==0) {
            if (indexPath.row==0) {
                static NSString *cellIndentifier = @"cell4";
                UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
                    
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell addSubview:self.secondWeekReport];
                return cell;
            }
            
        }else if (indexPath.section==1) {
            if (indexPath.row == 0) {
                static NSString *cellIndentifier = @"cell1";
                ReportTableViewCell *cell = (ReportTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
                if (!cell) {
                    cell = [[ReportTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
                    
                }
                cell.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.059f green:0.141f blue:0.231f alpha:1.00f]:[UIColor colorWithRed:0.475f green:0.686f blue:0.820f alpha:1.00f];
                cell.cellFont = [UIFont systemFontOfSize:18];
                cell.leftDataString = @"心率分析";
                cell.rightDataString = @"呼吸分析";
                cell.cellDataColor = selectedThemeIndex == 0? DefaultColor:[UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.cellColor = selectedThemeIndex == 0? DefaultColor:[UIColor whiteColor];
                
                return cell;
            }else{
                NSString *cellIndentifier = [NSString stringWithFormat:@"cell2%ld",(long)indexPath.row];
                ReportDataTableViewCell *cell = (ReportDataTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
                if (!cell) {
                    cell = [[ReportDataTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
                    
                }
                if (indexPath.row==3) {
                    cell.bottomColor = [UIColor clearColor];
                }
                cell.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.059f green:0.141f blue:0.231f alpha:1.00f]:[UIColor colorWithRed:0.475f green:0.686f blue:0.820f alpha:1.00f];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.cellFont = [UIFont systemFontOfSize:14];
                cell.cellColor = selectedThemeIndex == 0? DefaultColor:[UIColor whiteColor];
                cell.cellDataColor = selectedThemeIndex == 0? [UIColor colorWithRed:0.000f green:0.855f blue:0.576f alpha:1.00f]:[UIColor whiteColor];
                //
                cell.leftTitleString = [[self.dataTitleArr objectAtIndex:indexPath.row-1] objectAtIndex:0];
                cell.rightTitleString = [[self.dataTitleArr objectAtIndex:indexPath.row-1] objectAtIndex:1];
                cell.leftDataString = [[self.dataCellArr objectAtIndex:indexPath.row-1] objectAtIndex:0];;
                cell.rightDataString = [[self.dataCellArr objectAtIndex:indexPath.row-1] objectAtIndex:1];
                return cell;
                
            }
        }else if(indexPath.section==2){
            if (indexPath.row == 0) {
                static NSString *cellIndentifier = @"cell3";
                ReportTableViewCell *cell = (ReportTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
                if (!cell) {
                    cell = [[ReportTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
                    
                }
                cell.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.059f green:0.141f blue:0.231f alpha:1.00f]:[UIColor colorWithRed:0.475f green:0.686f blue:0.820f alpha:1.00f];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.cellFont = [UIFont systemFontOfSize:18];
                cell.cellDataColor = selectedThemeIndex == 0? [UIColor colorWithRed:0.000f green:0.855f blue:0.576f alpha:1.00f]:[UIColor whiteColor];
                cell.leftDataString = @"季平均睡眠时间";
                NSString *sleepDuration = [self.reportData objectForKey:@"AverageSleepDuration"];
                int hour = [sleepDuration intValue];
                double second2 = 0.0;
                double subsecond2 = modf([sleepDuration floatValue], &second2);
                NSString *sleepTimeDuration = [NSString stringWithFormat:@"%d小时%d分",hour>0?hour:-hour,(int)ceil(subsecond2*60)];
                cell.rightDataString = sleepTimeDuration;
                cell.cellColor = selectedThemeIndex == 0? DefaultColor:[UIColor whiteColor];
                return cell;
            }else{
                static NSString *cellIndentifier = @"cell4";
                UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
                    
                }
                [self.sleepNightBottomLine removeFromSuperview];
                [cell addSubview:self.sleepNightBottomLine];
                if (indexPath.row==1) {
                    [cell addSubview:self.longSleepView];
                    self.longSleepView.sleepNightCategoryString = @"最长的月份";
                    
                }else{
                    [cell addSubview:self.shortSleepView];
                    self.shortSleepView.sleepNightCategoryString = @"最短的月份";
                    
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.059f green:0.141f blue:0.231f alpha:1.00f]:[UIColor colorWithRed:0.475f green:0.686f blue:0.820f alpha:1.00f];
                return cell;
            }
            
        }
  
    }else{
        if (indexPath.section==0) {
            if (indexPath.row==0) {
                static NSString *cellIndentifier = @"cell4";
                UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
                    
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell addSubview:self.secondRightWeekReport];
                return cell;
            }
            
        }else if (indexPath.section==1) {
            if (indexPath.row == 0) {
                static NSString *cellIndentifier = @"cell1";
                ReportTableViewCell *cell = (ReportTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
                if (!cell) {
                    cell = [[ReportTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
                    
                }
                cell.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.059f green:0.141f blue:0.231f alpha:1.00f]:[UIColor colorWithRed:0.475f green:0.686f blue:0.820f alpha:1.00f];
                cell.cellFont = [UIFont systemFontOfSize:18];
                cell.leftDataString = @"心率分析";
                cell.rightDataString = @"呼吸分析";
                cell.cellDataColor = selectedThemeIndex == 0? DefaultColor:[UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.cellColor = selectedThemeIndex == 0? DefaultColor:[UIColor whiteColor];
                
                return cell;
            }else{
                NSString *cellIndentifier = [NSString stringWithFormat:@"cell2%ld",(long)indexPath.row];
                ReportDataTableViewCell *cell = (ReportDataTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
                if (!cell) {
                    cell = [[ReportDataTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
                    
                }
                if (indexPath.row==3) {
                    cell.bottomColor = [UIColor clearColor];
                }
                cell.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.059f green:0.141f blue:0.231f alpha:1.00f]:[UIColor colorWithRed:0.475f green:0.686f blue:0.820f alpha:1.00f];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.cellFont = [UIFont systemFontOfSize:14];
                cell.cellColor = selectedThemeIndex == 0? DefaultColor:[UIColor whiteColor];
                cell.cellDataColor = selectedThemeIndex == 0? [UIColor colorWithRed:0.000f green:0.855f blue:0.576f alpha:1.00f]:[UIColor whiteColor];
                //
                cell.leftTitleString = [[self.dataTitleArr objectAtIndex:indexPath.row-1] objectAtIndex:0];
                cell.rightTitleString = [[self.dataTitleArr objectAtIndex:indexPath.row-1] objectAtIndex:1];
                cell.leftDataString = [[self.dataRightCellArr objectAtIndex:indexPath.row-1] objectAtIndex:0];;
                cell.rightDataString = [[self.dataRightCellArr objectAtIndex:indexPath.row-1] objectAtIndex:1];
                return cell;
                
            }
        }else if(indexPath.section==2){
            if (indexPath.row == 0) {
                static NSString *cellIndentifier = @"cell3";
                ReportTableViewCell *cell = (ReportTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
                if (!cell) {
                    cell = [[ReportTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
                    
                }
                cell.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.059f green:0.141f blue:0.231f alpha:1.00f]:[UIColor colorWithRed:0.475f green:0.686f blue:0.820f alpha:1.00f];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.cellFont = [UIFont systemFontOfSize:18];
                cell.cellDataColor = selectedThemeIndex == 0? [UIColor colorWithRed:0.000f green:0.855f blue:0.576f alpha:1.00f]:[UIColor whiteColor];
                cell.leftDataString = @"季平均睡眠时间";
                NSString *sleepDuration = [self.reportData objectForKey:@"AverageSleepDuration"];
                int hour = [sleepDuration intValue];
                double second2 = 0.0;
                double subsecond2 = modf([sleepDuration floatValue], &second2);
                NSString *sleepTimeDuration = [NSString stringWithFormat:@"%d小时%d分",hour>0?hour:-hour,(int)ceil(subsecond2*60)];
                cell.rightDataString = sleepTimeDuration;
                cell.cellColor = selectedThemeIndex == 0? DefaultColor:[UIColor whiteColor];
                return cell;
            }else if (indexPath.row==3){
                static NSString *cellIndentifier = @"rightCell45";
                UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
                    
                }
                cell.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.059f green:0.141f blue:0.231f alpha:1.00f]:[UIColor colorWithRed:0.475f green:0.686f blue:0.820f alpha:1.00f];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.font = [UIFont systemFontOfSize:18];
                cell.textLabel.text = @"注意休息,早睡早起身体好!";
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
                return cell;
            }else{
                static NSString *cellIndentifier = @"cell4";
                UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
                    
                }
                [self.sleepNightBottomLine removeFromSuperview];
                [cell addSubview:self.sleepNightBottomLine];
                if (indexPath.row==1) {
                    [cell addSubview:self.longRightSleepView];
                    self.longRightSleepView.sleepNightCategoryString = @"最长的夜晚";
                    
                }else{
                    [cell addSubview:self.shortRightSleepView];
                    self.shortRightSleepView.sleepNightCategoryString = @"最短的夜晚";
                    
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.059f green:0.141f blue:0.231f alpha:1.00f]:[UIColor colorWithRed:0.475f green:0.686f blue:0.820f alpha:1.00f];
                return cell;
            }
            
        }

    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 216;
    }else {
        return 60;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 69;
    }else{
        return 30;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section==2) {
        return 0.01;
    }else{
        
        return 0.01;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    return view;
}
//防止scrollview向下拉
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        scrollView.contentOffset = CGPointMake(0, 0);
        return;
    }
    
    if (scrollView.contentSize.height>scrollView.frame.size.height&&scrollView.contentOffset.y>0) {
        if (scrollView.contentSize.height-scrollView.contentOffset.y < scrollView.frame.size.height) {
            scrollView.contentOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.frame.size.height);
            return;
        }
    }
    if (scrollView.contentSize.height<scrollView.frame.size.height) {
        scrollView.contentOffset = CGPointMake(0, 0);
        return;
    }
    
}

- (void)shareApp:(UIButton *)sender
{
    //    [self.shareMenuView show];
    [self.shareNewMenuView showInView:self.view];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
