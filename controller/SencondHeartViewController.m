//
//  SecondHeartViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/9/2.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "SencondHeartViewController.h"
#import "HeartGraphView.h"
#import "DataShowChartTableViewCell.h"
#import "GetHeartDataAPI.h"
#import "GetHeartSleepDataAPI.h"
#import "GetDefatultSleepAPI.h"
#import "GetUserDefaultDataAPI.h"
#import "GetExceptionAPI.h"
#import "DiagnoseReportViewController.h"
#import "ModalAnimation.h"
#import "ReportTableViewCell.h"

@interface SencondHeartViewController ()<UIViewControllerTransitioningDelegate>
{
    BOOL isUp;//控制两个tableview切换
    ModalAnimation *_modalAnimationController;
}
@property (nonatomic,assign) CGFloat viewHeight;
@property (nonatomic,strong) UITableView *upTableView;
@property (nonatomic,strong) UITableView *reportTableView;

//表哥
@property (nonatomic,strong) HeartGraphView *heartGraphView;//havi

//数据
@property (nonatomic,strong) NSDictionary *reportData;
@property (nonatomic,strong) NSArray *heartDic;
//记录当前的时间进行请求异常报告
@property (nonatomic,strong) NSString *currentDate;
@property (nonatomic,strong) NSDictionary *currentSleepQulitity;
@property (nonatomic,strong) UIImageView *backImage;
@property (nonatomic,strong) NSArray *titleArr;

@end

@implementation SencondHeartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createNavigationView];
    [self createSubView];
    [self getData];
}

- (void)getData
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日HH时mm分ss秒"];
    NSString *dateString = [formatter stringFromDate:selectedDateToUse];
    NSString *queryDate = [NSString stringWithFormat:@"%@%@%@",[dateString substringWithRange:NSMakeRange(0, 4)],[dateString substringWithRange:NSMakeRange(5, 2)],[dateString substringWithRange:NSMakeRange(8, 2)]];
    self.currentDate = queryDate;
    self.titleArr = @[@"心率平均数",@"心率异常数",@"心率异常数高于"];
    //请求数据
    [self getUserAllDaySensorData:queryDate toDate:queryDate];
}

#pragma mark 创建view
- (void)createNavigationView
{
    isUp = YES;
    self.viewHeight = self.view.frame.size.height;
    _modalAnimationController = [[ModalAnimation alloc] init];
    [self createClearBgNavWithTitle:nil createMenuItem:^UIView *(int nIndex) {
        if (nIndex == 1)
        {
            [self.leftButton addTarget:self action:@selector(backToHomeView:) forControlEvents:UIControlEventTouchUpInside];
            return self.leftButton;
        }
        else if (nIndex == 0){
            if ([self isThirdAppAllInstalled]) {
                self.rightButton.frame = CGRectMake(self.view.frame.size.width-40, 0, 30, 44);
                [self.rightButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_share_%d",selectedThemeIndex]] forState:UIControlStateNormal];
                [self.rightButton addTarget:self action:@selector(shareApp:) forControlEvents:UIControlEventTouchUpInside];
                return self.rightButton;
            }
            return nil;
        }
        return nil;
    }];
}

- (void)createSubView
{
    [self.view addSubview:self.upTableView];
    [self.view addSubview:self.reportTableView];
    UILabel *titleLabel = [[UILabel alloc]init];
    [self.view addSubview:titleLabel];
    titleLabel.text = @"心率分析";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textColor = selectedThemeIndex == 0? DefaultColor:[UIColor whiteColor];
    titleLabel.frame = CGRectMake(20, self.view.frame.size.height-204, self.view.frame.size.width-40, 44);
}

#pragma mark setter

- (UITableView *)reportTableView
{
    if (_reportTableView == nil) {
        _reportTableView = [[UITableView alloc]initWithFrame:CGRectMake(20, self.view.frame.size.height-164, self.view.frame.size.width-40, 144) style:UITableViewStylePlain];
        _reportTableView.backgroundColor = [UIColor clearColor];
        _reportTableView.delegate = self;
        _reportTableView.dataSource = self;
        [_reportTableView setBackgroundView:self.backImage];
        _reportTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _reportTableView.scrollEnabled = NO;
    }
    return _reportTableView;
}

- (UIImageView *)backImage
{
    if (!_backImage) {
        _backImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"txtbox_report_%d",selectedThemeIndex]]];
        _backImage.frame = CGRectMake(20, 0, self.view.frame.size.width-40, 200);
    }
    return _backImage;
}


- (HeartGraphView*)heartGraphView
{
    if (!_heartGraphView) {
        _heartGraphView = [[HeartGraphView alloc]initWithFrame:CGRectMake(5, 0, self.view.frame.size.width-15, self.upTableView.frame.size.height-60)];
        //设置警告值
        _heartGraphView.yValues = @[@"20", @"40", @"60", @"80", @"100",@"120",@"140"];
        _heartGraphView.heartView.graphTitle = @"xinlv";
        _heartGraphView.heartView.maxValue = 80;
        _heartGraphView.heartView.minValue = 30;
        _heartGraphView.horizonLine = 60;
        _heartGraphView.backMinValue = 50;
        _heartGraphView.backMaxValue = 70;
        _heartGraphView.heartView.horizonValue = 140;
        //设置坐标轴
//        if (isUserDefaultTime) {
//            NSString *startTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultStartTime];
//            NSString *endTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultEndTime];
//            int startInt = [[startTime substringToIndex:2]intValue];
//            int endInt = [[endTime substringToIndex:2]intValue];
//            if ((startInt<endInt)&&(endInt-startInt>1)&&((endInt - startInt)<12||(endInt - startInt)==12)) {
//                NSMutableArray *arr = [[NSMutableArray alloc]init];
//                for (int i = startInt; i<endInt +1; i++) {
//                    [arr addObject:[NSString stringWithFormat:@"%d",i]];
//                }
//                _heartGraphView.xValues = arr;
//            }else if ((startInt<endInt)&&(endInt - startInt)>12){
//                NSMutableArray *arr = [[NSMutableArray alloc]init];
//                for (int i = 0; i<(int)(endInt -startInt)/2+1; i++) {
//                    [arr addObject:[NSString stringWithFormat:@"%d",startInt +2*i]];
//                    
//                }
//                [arr replaceObjectAtIndex:arr.count-1 withObject:[NSString stringWithFormat:@"%d",endInt]];
//                _heartGraphView.xValues = arr;
//            }else if (startInt>endInt){
//                NSMutableArray *arr = [[NSMutableArray alloc]init];
//                for (int i = 0; i<(int)(endInt+ 24-startInt)/2+1; i++) {
//                    int date = startInt +2*i;
//                    if (date>24) {
//                        date = date - 24;
//                    }
//                    [arr addObject:[NSString stringWithFormat:@"%d",date]];
//                    
//                }
//                [arr replaceObjectAtIndex:arr.count-1 withObject:[NSString stringWithFormat:@"%d",endInt]];
//                _heartGraphView.xValues = arr;
//            }else if ((endInt - startInt)==1){
//                _heartGraphView.xValues = @[[NSString stringWithFormat:@"%d:00",startInt],[NSString stringWithFormat:@"%d:10",startInt], [NSString stringWithFormat:@"%d:20",startInt],[NSString stringWithFormat:@"%d:30",startInt],[NSString stringWithFormat:@"%d:40",startInt],[NSString stringWithFormat:@"%d:50",startInt],[NSString stringWithFormat:@"%d:00",endInt]];
//            }else if ((endInt - startInt)==0){
//                NSMutableArray *arr = [[NSMutableArray alloc]init];
//                for (int i = 0; i<12+1; i++) {
//                    int date = startInt +2*i;
//                    if (date>24) {
//                        date = date - 24;
//                    }
//                    [arr addObject:[NSString stringWithFormat:@"%d",date]];
//                    
//                }
//                _heartGraphView.xValues = arr;
//            }
//            
//        }else{
//        }
        _heartGraphView.xValues = @[@"18",@"20", @"22", @"24", @"2", @"4", @"6", @"8", @"10", @"12",@"14",@"16",@"18"];
        
        
        _heartGraphView.chartColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    }
    return _heartGraphView;
}


- (UITableView *)upTableView
{
    if (!_upTableView) {
        _upTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.viewHeight-64-234)];
        _upTableView.backgroundColor = [UIColor clearColor];
        _upTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _upTableView.delegate = self;
        _upTableView.dataSource = self;
        _upTableView.scrollEnabled = NO;
    }
    return _upTableView;
}

#pragma mark 获取24小时用户数据

- (void)getUserAllDaySensorData:(NSString *)fromDate toDate:(NSString *)toDate
{
    //    [MMProgressHUD showWithStatus:@"请求中..."];
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    if (fromDate) {
        
        NSDate *newDate = [self.dateFormmatterBase dateFromString:fromDate];
        NSString *urlString = @"";
        self.dateComponentsBase.day = -1;
        NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
        NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
        NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
        urlString = [NSString stringWithFormat:@"v1/app/SensorDataHistory?UUID=%@&DataProperty=3&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,newString,toDate];
//        if (isTodayHourEqualSixteen<18) {
//        }else{
//            self.dateComponentsBase.day = 1;
//            NSDate *nextDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
//            NSString *nextDayString = [NSString stringWithFormat:@"%@",nextDay];
//            NSString *newNextDayString = [NSString stringWithFormat:@"%@%@%@",[nextDayString substringWithRange:NSMakeRange(0, 4)],[nextDayString substringWithRange:NSMakeRange(5, 2)],[nextDayString substringWithRange:NSMakeRange(8, 2)]];
//            urlString = [NSString stringWithFormat:@"v1/app/SensorDataHistory?UUID=%@&DataProperty=3&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,fromDate,newNextDayString];
//        }
        NSDictionary *header = @{
                                 @"AccessToken":@"123456789"
                                 };
        GetHeartDataAPI *client = [GetHeartDataAPI shareInstance];
        if ([client isExecuting]) {
            [client stop];
        }
        [client getHeartData:header withDetailUrl:urlString];
//        if ([client getCacheJsonWithDate:fromDate]) {
//            NSDictionary *resposeDic = (NSDictionary *)[client cacheJson];
//            //            [MMProgressHUD dismiss];
//            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
//            HaviLog(@"请求的心率数据%@和url%@",resposeDic,urlString);
//            [self reloadUserViewWithData:resposeDic];
//            [self getUserSleepReportData:fromDate toDate:toDate];
//        }else{
//        }
        [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
            //                [MMProgressHUD dismiss];
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
            HaviLog(@"请求的心率数据%@和url%@",resposeDic,urlString);
            [self reloadUserViewWithData:resposeDic];
            [self getUserSleepReportData:fromDate toDate:toDate];
        } failure:^(YTKBaseRequest *request) {
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
            NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
            [self.view makeToast:[NSString stringWithFormat:@"%@",[resposeDic objectForKey:@"ErrorMessage"]] duration:2 position:@"center"];
        }];
    }
}

- (void)reloadUserViewWithData:(NSDictionary *)dataDic
{
    NSArray *arr = [dataDic objectForKey:@"SensorData"];
    self.heartDic = nil;
    for (NSDictionary *dic in arr) {
        self.heartDic = [self changeSeverDataToChartData:[dic objectForKey:@"Data"]];
        
    }
    if (arr.count==0) {
        NSMutableArray *arr1 = [[NSMutableArray alloc]init];
        for (int i=0; i<288; i++) {
            [arr1 addObject:[NSNumber numberWithFloat:60]];
        }
        self.heartGraphView.heartView.values = arr1;
        [self.heartGraphView.heartView animate];
    }
    //    [self.upTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSMutableArray *)changeSeverDataToChartData:(NSArray *)severDataArr
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        for (int i=0; i<288; i++) {
            [arr addObject:[NSNumber numberWithFloat:60]];
        }
        for (int i = 0; i<severDataArr.count; i++) {
            NSDictionary *dic = [severDataArr objectAtIndex:i];
            NSString *date = [dic objectForKey:@"At"];
            NSString *hourDate1 = [date substringWithRange:NSMakeRange(11, 2)];
            NSString *minuteDate2 = [date substringWithRange:NSMakeRange(14, 2)];
            int indexIn = 0;
            if ([hourDate1 intValue]<18) {
                indexIn = (int)((24 -18)*60 + [hourDate1 intValue]*60 + [minuteDate2 intValue])/5;
            }else {
                indexIn = (int)(([hourDate1 intValue]-18)*60 + [minuteDate2 intValue])/5;
            }
            [arr replaceObjectAtIndex:indexIn withObject:[NSNumber numberWithFloat:[[dic objectForKey:@"Value"] floatValue]]];
        }
        self.heartDic = arr;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.heartGraphView.heartView.values = self.heartDic;
            [self.heartGraphView.heartView animate];
        });
    });
    return nil;
    //    return arr;
}


- (void)getUserSleepReportData:(NSString *)fromDate toDate:(NSString *)toDate
{
    if (fromDate) {
        
        NSDate *newDate = [self.dateFormmatterBase dateFromString:fromDate];
        NSString *urlString = @"";
        self.dateComponentsBase.day = -1;
        NSDate *yestoday = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
        NSString *yestodayString = [NSString stringWithFormat:@"%@",yestoday];
        NSString *newString = [NSString stringWithFormat:@"%@%@%@",[yestodayString substringWithRange:NSMakeRange(0, 4)],[yestodayString substringWithRange:NSMakeRange(5, 2)],[yestodayString substringWithRange:NSMakeRange(8, 2)]];
        urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&UserId=%@&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,thirdPartyLoginUserId,newString,fromDate];
//        if (isTodayHourEqualSixteen<18) {
//        }else {
//            self.dateComponentsBase.day = 1;
//            NSDate *nextDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
//            NSString *nextDayString = [NSString stringWithFormat:@"%@",nextDay];
//            NSString *newNextDayString = [NSString stringWithFormat:@"%@%@%@",[nextDayString substringWithRange:NSMakeRange(0, 4)],[nextDayString substringWithRange:NSMakeRange(5, 2)],[nextDayString substringWithRange:NSMakeRange(8, 2)]];
//            urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&UserId=%@&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,thirdPartyLoginUserId,fromDate,newNextDayString];
//            
//        }
        NSDictionary *header = @{
                                 @"AccessToken":@"123456789"
                                 };
        GetHeartSleepDataAPI *client = [GetHeartSleepDataAPI shareInstance];
        if ([client isExecuting]) {
            [client stop];
        }
        [client getHeartSleepData:header withDetailUrl:urlString];
        if ([client getCacheJsonWithDate:fromDate]) {
            NSDictionary *resposeDic = (NSDictionary *)[client cacheJson];
            HaviLog(@"心率是%@和url%@",resposeDic,urlString);
            //为了异常报告,和更新
            self.reportData = resposeDic;
            [self.reportTableView reloadData];
            self.currentSleepQulitity = resposeDic;

            [self.upTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//            [self reloadSleepView:resposeDic];
        }else{
            [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                HaviLog(@"心率是%@和url%@",resposeDic,urlString);
                //为了异常报告,和更新
                self.reportData = resposeDic;
                [self.reportTableView reloadData];
                self.currentSleepQulitity = resposeDic;

                [self.upTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//                [self reloadSleepView:resposeDic];
            } failure:^(YTKBaseRequest *request) {
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                [self.view makeToast:[NSString stringWithFormat:@"%@",[resposeDic objectForKey:@"ErrorMessage"]] duration:2 position:@"center"];
            }];
        }
    }
}


#pragma mark tableview 代理函数

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.upTableView]) {
        return 2;
    }else{
        return 3;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.upTableView]) {
        
        if (indexPath.row == 0) {
            static NSString *cellIndentifier = @"cell0";
            DataShowChartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
            if (!cell) {
                cell = [[DataShowChartTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
            }
            //timeSwitchButton
            cell.iconTitleName = [NSString stringWithFormat:@"icon_heart_rate_%d",selectedThemeIndex];
            cell.cellTitleName = @"心率";
            
            cell.cellData = [NSString stringWithFormat:@"%d次/分钟",[[self.currentSleepQulitity objectForKey:@"AverageHeartRate"] intValue]];
            //            cell.cellData = [NSString stringWithFormat:@"%d次/分钟",50];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            return cell;
            
        }else{//无用
            static NSString *indentifier = @"cell1";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
            }
            [cell addSubview:self.heartGraphView];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
    }else{
        static NSString *cellIndentifier = @"cell2";
        ReportTableViewCell *cell = (ReportTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
        if (!cell) {
            cell = [[ReportTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
            
        }
        cell.cellFont = [UIFont systemFontOfSize:17];
        cell.cellColor = selectedThemeIndex == 0? DefaultColor:[UIColor whiteColor];
        cell.leftDataString = [self.titleArr objectAtIndex:indexPath.row];
        if (indexPath.row==0) {
            cell.rightDataString = [NSString stringWithFormat:@"%d次",[[self.reportData objectForKey:@"AverageHeartRate"] intValue]];
        }else if (indexPath.row==1){
            cell.rightDataString = [NSString stringWithFormat:@"%d次",[[self.reportData objectForKey:@"FastHeartRateTimes"] intValue]+[[self.reportData objectForKey:@"SlowHeartRateTimes"] intValue]];
            
        }else if (indexPath.row==2){
            cell.rightDataString = [NSString stringWithFormat:@"%d%@",[[self.reportData objectForKey:@"AbnormalHeartRatePercent"] intValue],@"%用户"];
        }
//        if (indexPath.row == 0) {
//            cell.cellFont = [UIFont systemFontOfSize:18];
//            cell.leftDataString = @"心率分析";
//            cell.rightDataString = @"呼吸分析";
//            cell.cellColor = selectedThemeIndex == 0? DefaultColor:[UIColor whiteColor];
//        }else if(indexPath.row == 1){
//            cell.cellFont = [UIFont systemFontOfSize:13];
//            cell.leftDataString = @"心率平均值";
//            cell.rightDataString = @"呼吸平均值";
//            cell.cellColor = selectedThemeIndex == 0? DefaultColor:[UIColor whiteColor];
//        }else if (indexPath.row == 2){
//            cell.cellFont = [UIFont systemFontOfSize:13];
//            cell.leftDataString = [NSString stringWithFormat:@"%d次/分钟",[[self.reportData objectForKey:@"AverageHeartRate"] intValue]];
//            cell.rightDataString = [NSString stringWithFormat:@"%d次/分钟",[[self.reportData objectForKey:@"AverageRespiratoryRate"] intValue]];
//            cell.cellColor = selectedThemeIndex == 0? [UIColor colorWithRed:0.000f green:0.847f blue:0.573f alpha:1.00f]:[UIColor whiteColor];
//        }else if (indexPath.row == 3){
//            cell.cellFont = [UIFont systemFontOfSize:13];
//            cell.leftDataString = @"心率异常数";
//            cell.rightDataString = @"呼吸异常数";
//            cell.cellColor = selectedThemeIndex == 0? DefaultColor:[UIColor whiteColor];
//        }else if (indexPath.row == 4){
//            cell.cellFont = [UIFont systemFontOfSize:13];
//            cell.leftDataString = [NSString stringWithFormat:@"%d次/分钟",[[self.reportData objectForKey:@"FastHeartRateTimes"] intValue]+[[self.reportData objectForKey:@"SlowHeartRateTimes"] intValue]];
//            cell.rightDataString = [NSString stringWithFormat:@"%d次/分钟",[[self.reportData objectForKey:@"SlowRespiratoryRateTimes"] intValue]+[[self.reportData objectForKey:@"SlowHeartRateTimes"] intValue]];
//            cell.cellColor = selectedThemeIndex == 0? [UIColor colorWithRed:0.000f green:0.847f blue:0.573f alpha:1.00f]:[UIColor whiteColor];
//        }else if (indexPath.row == 5){
//            cell.cellFont = [UIFont systemFontOfSize:13];
//            cell.leftDataString = @"心率异常数高于";
//            cell.rightDataString = @"呼吸异常数高于";
//            cell.cellColor = selectedThemeIndex == 0? DefaultColor:[UIColor whiteColor];
//        }else if (indexPath.row == 6){
//            cell.cellFont = [UIFont systemFontOfSize:19];
//            cell.leftDataString = [NSString stringWithFormat:@"%d%@",[[self.reportData objectForKey:@"AbnormalHeartRatePercent"] intValue],@"%用户"];
//            cell.rightDataString = [NSString stringWithFormat:@"%d%@",[[self.reportData objectForKey:@"AbnormalRespiratoryRatePercent"] intValue],@"%用户"];
//            cell.cellColor = selectedThemeIndex == 0? [UIColor colorWithRed:0.000f green:0.847f blue:0.573f alpha:1.00f]:[UIColor whiteColor];
//        }
        
        cell.backgroundColor = [UIColor clearColor];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;

    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.upTableView]) {
        
        if (indexPath.row == 0) {
            return 60;
        }else{
            return self.upTableView.frame.size.height-60;
        }
    }else{
        return (self.reportTableView.frame.size.height)/3;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}


#pragma mark 异常报告

- (void)showHeartEmercenyView:(NSNotification *)noti
{
    [self showDiagnoseReportHeart];
}

- (void)showDiagnoseReportHeart
{
    NSString *urlString = @"";
    NSDate *newDate = [self.dateFormmatterBase dateFromString:self.currentDate];
    self.dateComponentsBase.day = -1;
    NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
    NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
    NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
    urlString = [NSString stringWithFormat:@"v1/app/SensorDataIrregular?UUID=%@&DataProperty=3&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,newString,self.currentDate];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithStatus:@"异常数据请求中..."];
    GetExceptionAPI *client = [GetExceptionAPI shareInstance];
    [client getException:header withDetailUrl:urlString];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [MMProgressHUD dismiss];
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [self showExceptionView:resposeDic withTitle:@"心率"];
        }else{
            [self.view makeToast:[resposeDic objectForKey:@"ErrorMessage"] duration:2 position:@"center"];
        }
    } failure:^(YTKBaseRequest *request) {
        [MMProgressHUD dismiss];
        [self.view makeToast:@"网络问题" duration:2 position:@"center"];
    }];

}

- (void)showExceptionView:(NSDictionary *)dic withTitle:(NSString *)exceptionTitle
{
    DiagnoseReportViewController *modal = [[DiagnoseReportViewController alloc] init];
    modal.transitioningDelegate = self;
    modal.dateTime = self.currentDate;
    modal.reportTitleString = exceptionTitle;
    modal.modalPresentationStyle = UIModalPresentationCustom;
    modal.exceptionDic = dic;
    modal.sleepDic = self.currentSleepQulitity;
    [self presentViewController:modal animated:YES completion:nil];
}

#pragma mark - Transitioning Delegate (Modal)
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    _modalAnimationController.type = AnimationTypePresent;
    return _modalAnimationController;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _modalAnimationController.type = AnimationTypeDismiss;
    return _modalAnimationController;
}



#pragma mark button 实现方法

- (void)backToHomeView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showHeartEmercenyView:) name:PostHeartEmergencyNoti object:nil];
    [self getData];
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
