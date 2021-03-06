//
//  NewMonthReportViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/9/16.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "NewMonthReportViewController.h"
#import "HaviGetNewClient.h"
#import "ReportTableViewCell.h"
#import "NSDate+NSDateLogic.h"
#import "NewWeekReport.h"
#import "ReportDataTableViewCell.h"
#import "SleepTimeTagView.h"
#import "MonthCalenderView.h"

@interface NewMonthReportViewController ()<SelectedMonth,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
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
//
//保存数据
@property (nonatomic,strong) NSDictionary *reportData;
@property (nonatomic,strong) NSMutableArray *mutableArr;
@property (nonatomic,strong) NSMutableArray *mutableTimeArr;
@property (nonatomic,strong) NSArray *dataTitleArr;
@property (nonatomic,strong) NSArray *dataCellArr;
@property (nonatomic,assign) NSInteger dayNums;

//
@property (nonatomic,strong) UIView *sleepNightBottomLine;
@property (nonatomic,strong) UIView *noDataImageView;
@property (nonatomic,strong) UIScrollView *dataScrollView;
@end

@implementation NewMonthReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataTitleArr = @[@[@"心率平均值",@"呼吸平均值"],@[@"心率异常数",@"呼吸异常数"],@[@"心率异常数高于",@"呼吸异常数高于"]];
    [self.view addSubview:self.reportTableView];
    // Do any additional setup after loading the view.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getUserData];
    });
}

#pragma mark 获取用户数据

- (void)getUserData
{
    NSString *year = [self.monthTitleLabel.text substringWithRange:NSMakeRange(0, 4)];
    NSString *fromMonth = [self.monthTitleLabel.text substringWithRange:NSMakeRange(5, 2)];
    NSString *fromDate = [NSString stringWithFormat:@"%@%@%@",year,fromMonth,@"01"];
    NSString *toDate = @"";
    toDate = [NSString stringWithFormat:@"%@%@%ld",year,fromMonth,[self getCurrentMonthDayNum:year month:fromMonth]];
    [self getTodayUserData:fromDate endDate:toDate withCompareDate:nil];
}

- (NSInteger)getCurrentMonthDayNum:(NSString *)year month:(NSString *)month
{
    NSString *dateString = [NSString stringWithFormat:@"%@年%@月06",year,month];
    NSDate *date = [self.dateFormmatter1 dateFromString:dateString];
    NSInteger dayNum = [date getdayNumsInOneMonth];
    self.dayNums  = dayNum;
    return dayNum;
}

- (void)getTodayUserData:(NSString *)fromDate endDate:(NSString *)endTime withCompareDate:(NSDate *)compDate
{
    if (![self isNetworkExist]) {
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
        return;
    }
    
    if ([HardWareUUID isEqualToString:@""]) {
        [self.view makeToast:@"您还没有绑定设备,无法查看数据" duration:2 position:@"center"];
        return;
    }
    if (!fromDate) {
        return;
    }
    /*
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithStatus:@"加载中..."];
     */
    NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
                        [UIImage imageNamed:@"havi1_1"],
                        [UIImage imageNamed:@"havi1_2"],
                        [UIImage imageNamed:@"havi1_3"],
                        [UIImage imageNamed:@"havi1_4"],
                        [UIImage imageNamed:@"havi1_5"]];
    [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
    [MMProgressHUD showWithTitle:nil status:nil images:images];
    NSString *urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&UserId=%@&FromDate=%@&EndDate=%@&FromTime=&EndTime=",HardWareUUID,thirdPartyLoginUserId,fromDate,endTime];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    HaviGetNewClient *client = [HaviGetNewClient shareInstance];
    if ([client isExecuting]) {
        [client stop];
    }
    [client querySensorDataOld:header withDetailUrl:urlString];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                HaviLog(@"周报数据是%@和url:%@",resposeDic,urlString);
                [self reloadUserUI:(NSDictionary *)resposeDic];
            }];
            [MMProgressHUD dismissAfterDelay:0.3];
        }else{
            [MMProgressHUD dismissWithError:[resposeDic objectForKey:@"ErrorMessage"] afterDelay:2];
        }
    } failure:^(YTKBaseRequest *request) {
        [MMProgressHUD dismiss];
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
}

#pragma mark 更新界面

- (void)chageXvalueWithMonth
{
    if (self.dayNums==30) {
        _secondWeekReport.xValues = @[@"1日",@"2日",@"3日",@"4日",@"5日",@"6日",@"7日",@"8日",@"9日",@"10日",@"11日",@"12日",@"13日",@"14日",@"15日",@"16日",@"17日",@"18日",@"19日",@"20日",@"21日",@"22日",@"23日",@"24日",@"25日",@"26日",@"27日",@"28日",@"29日",@"30日"];
        _secondWeekReport.sleepQulityDataValues = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
        _secondWeekReport.sleepTimeDataValues = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
        
    }else if(self.dayNums>30){
        _secondWeekReport.xValues = @[@"1日",@"2日",@"3日",@"4日",@"5日",@"6日",@"7日",@"8日",@"9日",@"10日",@"11日",@"12日",@"13日",@"14日",@"15日",@"16日",@"17日",@"18日",@"19日",@"20日",@"21日",@"22日",@"23日",@"24日",@"25日",@"26日",@"27日",@"28日",@"29日",@"30日",@"31日"];
        _secondWeekReport.sleepQulityDataValues = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
        _secondWeekReport.sleepTimeDataValues = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
    }else if(self.dayNums==28){
        _secondWeekReport.xValues = @[@"1日",@"2日",@"3日",@"4日",@"5日",@"6日",@"7日",@"8日",@"9日",@"10日",@"11日",@"12日",@"13日",@"14日",@"15日",@"16日",@"17日",@"18日",@"19日",@"20日",@"21日",@"22日",@"23日",@"24日",@"25日",@"26日",@"27日",@"28日"];
        _secondWeekReport.sleepQulityDataValues = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
        _secondWeekReport.sleepTimeDataValues = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
    }else if (self.dayNums==29){
        _secondWeekReport.xValues = @[@"1日",@"2日",@"3日",@"4日",@"5日",@"6日",@"7日",@"8日",@"9日",@"10日",@"11日",@"12日",@"13日",@"14日",@"15日",@"16日",@"17日",@"18日",@"19日",@"20日",@"21日",@"22日",@"23日",@"24日",@"25日",@"26日",@"27日",@"28日",@"29日"];
        _secondWeekReport.sleepQulityDataValues = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
        _secondWeekReport.sleepTimeDataValues = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
    }
}

- (void)reloadUserUI:(NSDictionary *)dic
{
    
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
    double subsecond = modf(duration, &second);
    self.longSleepView.sleepTimeLongString = [NSString stringWithFormat:@"%d小时%d分",(int)duration,(int)(subsecond*60)];
    if ([[NSString stringWithFormat:@"%@",[shortDic objectForKey:@"Date"]]isEqualToString:@"(null)"]) {
        self.shortSleepView.sleepYearMonthDayString = @"";
    }else{
        self.shortSleepView.sleepYearMonthDayString = [NSString stringWithFormat:@"%@",[shortDic objectForKey:@"Date"]];
    }
    
    float duration1 = [[shortDic objectForKey:@"SleepDuration"]floatValue]<0?-[[shortDic objectForKey:@"SleepDuration"]floatValue]:[[shortDic objectForKey:@"SleepDuration"]floatValue];
    double subsecond1 = modf(duration1, &second);
    self.shortSleepView.sleepTimeLongString = [NSString stringWithFormat:@"%d小时%d分",(int)duration1,(int)(subsecond1*60)];
    
    [self reloadReportChart:[self.reportData objectForKey:@"Data"]];
    
}


- (void)reloadReportChart:(NSArray *)dataArr
{
    if (self.mutableArr.count>0) {
        [self.mutableArr removeAllObjects];
    }
    if (self.mutableTimeArr.count>0) {
        [self.mutableTimeArr removeAllObjects];
    }
    for (int i=0; i<self.dayNums; i++) {
        [self.mutableArr addObject:[NSString stringWithFormat:@"0"]];
        [self.mutableTimeArr addObject:[NSString stringWithFormat:@"0"]];
    }
    NSString *year = [self.monthTitleLabel.text substringWithRange:NSMakeRange(0, 4)];
    NSString *month = [self.monthTitleLabel.text substringWithRange:NSMakeRange(5, 2)];
    NSString *fromDateString = [NSString stringWithFormat:@"%@年%@月01日",year,month];
    NSDate *fromDate = [self.dateFormmatter1 dateFromString:fromDateString];
    for (int i=0; i<dataArr.count; i++) {
        NSDictionary *dic = [dataArr objectAtIndex:i];
        NSString *dateString = [dic objectForKey:@"Date"];
        NSString *toDateString = [NSString stringWithFormat:@"%@年%@月%@日",[dateString substringWithRange:NSMakeRange(0, 4)],[dateString substringWithRange:NSMakeRange(5, 2)],[dateString substringWithRange:NSMakeRange(8, 2)]];
        NSDate *toDate = [self.dateFormmatter1 dateFromString:toDateString];
        NSDateComponents *dayComponents = [self.calender components:NSDayCalendarUnit fromDate:fromDate toDate:toDate options:0];
        [self.mutableArr replaceObjectAtIndex:dayComponents.day withObject:[NSString stringWithFormat:@"%@",[dic objectForKey:@"SleepQuality"]]];
        [self.mutableTimeArr replaceObjectAtIndex:dayComponents.day withObject:[NSString stringWithFormat:@"%@",[dic objectForKey:@"SleepDuration"]]];
        
    }
    
    if (dataArr.count>0) {
        [self.noDataImageView removeFromSuperview];
    }else{
        [self.dataScrollView addSubview:self.noDataImageView];
        self.noDataImageView.center = self.dataScrollView.center;
    }
    
    self.secondWeekReport.sleepQulityDataValues = self.mutableArr;
    self.secondWeekReport.sleepTimeDataValues = self.mutableTimeArr;
    
    [self.secondWeekReport reloadChartView];
    
}

#pragma mark setter

- (UIScrollView *)dataScrollView
{
    if (!_dataScrollView) {
        _dataScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216)];
        _dataScrollView.contentSize = CGSizeMake(4*self.view.frame.size.width+self.view.frame.size.width/7*3, 216);
        _dataScrollView.backgroundColor = [UIColor colorWithRed:0.059f green:0.141f blue:0.231f alpha:1.00f];
        _dataScrollView.delegate = self;
        [_dataScrollView addSubview:self.secondWeekReport];
        _dataScrollView.showsHorizontalScrollIndicator = NO;
    }
    
    return _dataScrollView;
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
        _secondWeekReport = [[NewWeekReport alloc]initWithFrame:CGRectMake(0, 0, 4*self.view.frame.size.width+self.view.frame.size.width/7*3, 216)];
        self.dayNums = [[NSDate date] getdayNumsInOneMonth];
        if (self.dayNums==30) {
            _secondWeekReport.xValues = @[@"1日",@"2日",@"3日",@"4日",@"5日",@"6日",@"7日",@"8日",@"9日",@"10日",@"11日",@"12日",@"13日",@"14日",@"15日",@"16日",@"17日",@"18日",@"19日",@"20日",@"21日",@"22日",@"23日",@"24日",@"25日",@"26日",@"27日",@"28日",@"29日",@"30日"];
            _secondWeekReport.sleepQulityDataValues = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
            _secondWeekReport.sleepTimeDataValues = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
            
        }else if(self.dayNums>30){
            _secondWeekReport.xValues = @[@"1日",@"2日",@"3日",@"4日",@"5日",@"6日",@"7日",@"8日",@"9日",@"10日",@"11日",@"12日",@"13日",@"14日",@"15日",@"16日",@"17日",@"18日",@"19日",@"20日",@"21日",@"22日",@"23日",@"24日",@"25日",@"26日",@"27日",@"28日",@"29日",@"30日",@"31日"];
            _secondWeekReport.sleepQulityDataValues = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
            _secondWeekReport.sleepTimeDataValues = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
        }else if(self.dayNums==28){
            _secondWeekReport.xValues = @[@"1日",@"2日",@"3日",@"4日",@"5日",@"6日",@"7日",@"8日",@"9日",@"10日",@"11日",@"12日",@"13日",@"14日",@"15日",@"16日",@"17日",@"18日",@"19日",@"20日",@"21日",@"22日",@"23日",@"24日",@"25日",@"26日",@"27日",@"28日"];
            _secondWeekReport.sleepQulityDataValues = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
            _secondWeekReport.sleepTimeDataValues = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
        }else if (self.dayNums==29){
            _secondWeekReport.xValues = @[@"1日",@"2日",@"3日",@"4日",@"5日",@"6日",@"7日",@"8日",@"9日",@"10日",@"11日",@"12日",@"13日",@"14日",@"15日",@"16日",@"17日",@"18日",@"19日",@"20日",@"21日",@"22日",@"23日",@"24日",@"25日",@"26日",@"27日",@"28日",@"29日"];
            _secondWeekReport.sleepQulityDataValues = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
            _secondWeekReport.sleepTimeDataValues = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
        }
        

    }
    return _secondWeekReport;
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
        _calenderBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 69)];
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
        [_leftCalButton addTarget:self action:@selector(lastMonth:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftCalButton;
}

- (UIButton *)rightCalButton
{
    if (!_rightCalButton) {
        _rightCalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightCalButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_right_75_%d",selectedThemeIndex]] forState:UIControlStateNormal];
        [_rightCalButton addTarget:self action:@selector(nextMonth:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightCalButton;
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
        _monthTitleLabel.text = [NSString stringWithFormat:@"%@年%@月",year,month];
    }
    return _monthTitleLabel;
}

#pragma mark user action

- (void)showMonthCalender:(UITapGestureRecognizer *)gesture
{
    HaviLog(@"展示日历");
    NSString *dateString = self.monthTitleLabel.text;
    MonthCalenderView *monthView = [[MonthCalenderView alloc]init];
    monthView.frame = [UIScreen mainScreen].bounds;
    NSRange range = [dateString rangeOfString:@"年"];
    NSString *sub2 = [dateString substringWithRange:NSMakeRange(range.location+range.length, 2)];
    NSString *sub1 = [dateString substringToIndex:range.location];
    monthView.monthTitle = sub1;
    monthView.currentMonthNum = [sub2 intValue];
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

- (void)lastMonth:(UIButton *)sender
{
    NSDate *showDate = [self.dateFormmatter dateFromString:self.monthTitleLabel.text];
    NSDate *nextMonth = [self dayInTheLastMonth:showDate];
    NSString *nextMonthString = [NSString stringWithFormat:@"%@",nextMonth];
    NSString *subString = [nextMonthString substringToIndex:10];
    NSString *year = [subString substringToIndex:4];
    NSString *month = [subString substringWithRange:NSMakeRange(5, 2)];
    self.monthTitleLabel.text = [NSString stringWithFormat:@"%@年%@月",year,month];
    self.dayNums = [nextMonth getdayNumsInOneMonth];
    //改变x轴
    [self chageXvalueWithMonth];
    //获取数据
    [self getUserData];
}

- (void)nextMonth:(UIButton *)sender
{
    NSDate *showDate = [self.dateFormmatter dateFromString:self.monthTitleLabel.text];
    NSDate *nextMonth = [self dayInTheFollowingMonth:showDate];
    NSString *nextMonthString = [NSString stringWithFormat:@"%@",nextMonth];
    NSString *subString = [nextMonthString substringToIndex:10];
    NSString *year = [subString substringToIndex:4];
    NSString *month = [subString substringWithRange:NSMakeRange(5, 2)];
    self.monthTitleLabel.text = [NSString stringWithFormat:@"%@年%@月",year,month];
    self.dayNums = [nextMonth getdayNumsInOneMonth];
    //获取书
    //改变x轴
    [self chageXvalueWithMonth];
    [self getUserData];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            static NSString *cellIndentifier = @"cell4";
            UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
                
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell addSubview:self.dataScrollView];
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
            static NSString *cellIndentifier = @"cell2";
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
            cell.leftDataString = @"月平均睡眠时间";
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
            if (indexPath.row==1) {
                [self.sleepNightBottomLine removeFromSuperview];
                [cell addSubview:self.sleepNightBottomLine];
            }
            if (indexPath.row==1) {
                [cell addSubview:self.longSleepView];
                self.longSleepView.sleepNightCategoryString = @"最长的夜晚";

            }else{
                [cell addSubview:self.shortSleepView];
                self.shortSleepView.sleepNightCategoryString = @"最短的夜晚";

            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.059f green:0.141f blue:0.231f alpha:1.00f]:[UIColor colorWithRed:0.475f green:0.686f blue:0.820f alpha:1.00f];
            return cell;
        }
        
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.reportTableView]) {
        if (indexPath.section == 0) {
            return 216;
        }else {
            return 60;
        }
    }else{
        return 10;
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
    if (section==0) {
        return self.calenderBackView;
    }else{
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        return view;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    return view;
}
//防止scrollview向下拉
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.reportTableView]) {
        
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
    }else if ([scrollView isEqual:self.dataScrollView]){
        if (scrollView.contentOffset.x < 0) {
            scrollView.contentOffset = CGPointMake(0, 0);
            return;
        }
        if (scrollView.contentSize.width>scrollView.frame.size.width&&scrollView.contentOffset.x>0) {
            if (scrollView.contentSize.width-scrollView.contentOffset.x < scrollView.frame.size.width) {
                scrollView.contentOffset = CGPointMake(scrollView.contentSize.width - scrollView.frame.size.width,0 );
                return;
            }
        }
        CGPoint centerPoint = CGPointMake(scrollView.contentOffset.x + self.view.frame.size.width/2, scrollView.center.y);
        self.noDataImageView.center = centerPoint;
    }

}

#pragma mark 日历delegate

- (void)selectedMonth:(NSString *)monthString
{
    self.monthTitleLabel.text = monthString;
    NSDate *showDate = [self.dateFormmatter dateFromString:self.monthTitleLabel.text];
    self.dayNums = [showDate getdayNumsInOneMonth];
    //改变x轴
    [self chageXvalueWithMonth];
    //获取书
    [self getUserData];
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
