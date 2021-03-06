//
//  LeftSideViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/2/26.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "LeftSideViewController.h"
#import "btRippleButtton.h"
#import "IconTableViewCell.h"
#import "DefaultTableViewCell.h"
#import "DataShowTableViewCell.h"
#import "UserInfoViewController.h"
#import "DeviceManagerViewController.h"
#import "SleepSettingViewController.h"
#import "APPSettingViewController.h"
#import "DataStaticViewController.h"
#import "CenterViewController.h"
#import "SleepAnalysisViewController.h"
#import "AppDelegate.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "PersonManagerViewController.h"

@interface LeftSideViewController ()
@property (nonatomic,strong) UIView *tableHeaderView;
@property (nonatomic,strong) NSArray *imageArr;
//
@property (nonatomic,strong) UIImageView *iconImageButton;
@property (nonatomic,strong) UILabel *userName;
@property (nonatomic,strong) NSString *changeNowDate;
@end

@implementation LeftSideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDate *nowDate = [self getNowDateFromatAnDate:[NSDate date]];
    NSString *nowDateString = [NSString stringWithFormat:@"%@",nowDate];
    NSString *sub = [nowDateString substringWithRange:NSMakeRange(11, 2)];
    self.changeNowDate = sub;
    if ([sub intValue]>7 && [sub intValue]<18) {
        self.bgImageView.image = [UIImage imageNamed:@"pic_bg_day"];
    }else {
        self.bgImageView.image = [UIImage imageNamed:@"pic_bg_night_0"];
    }
    [self creatSubView];
}

- (void)creatSubView
{
    //头像北景
    UIView *iconBackView = [[UIView alloc]init];
    [self.view addSubview:iconBackView];
    [iconBackView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view.top);
        make.height.equalTo(124);
    }];
    iconBackView.backgroundColor = [UIColor clearColor];
    UIImageView *imageLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"line"]];
    [iconBackView addSubview:imageLine];
    [imageLine makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconBackView).offset(5);
        int widthCenter = (self.view.frame.size.width - 220)*0.70710676908493042;
        make.right.equalTo(iconBackView).offset(-widthCenter);
        make.bottom.equalTo(iconBackView.bottom).offset(-0.5);
        make.height.equalTo(0.5);
    }];
    //
    [self.view addSubview:self.iconImageButton];
    [self.view addSubview:self.userName];
    _userName.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    [_userName makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_iconImageButton.centerY);
        make.left.equalTo(_iconImageButton.right).offset(10);
    }];
    _userName.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapName = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showUserInfo)];
    [_userName addGestureRecognizer:tapName];
    //tableview
    self.sideTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.sideTableView];
    [self.sideTableView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(0);
        make.top.equalTo(iconBackView.bottom).offset(0);
        make.bottom.equalTo(self.view.bottom).offset(0);
        int widthCenter = (self.view.frame.size.width)*0.3;
        make.right.equalTo(self.view.right).offset(-widthCenter);
    }];
    self.sideTableView.showsVerticalScrollIndicator = NO;
    //
    self.sideArray = @[@[@"今日数据",@"数据分析",@"设备管理",@"睡眠设置",@"设       定"]];

    self.imageArr = @[@[[NSString stringWithFormat:@"icon_todays_data_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_data_analysis_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_equipment_management_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_alarm_clock_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_setting_%d",selectedThemeIndex]]];
    //添加退出
    /*
    UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutButton setTitle:@"退出帐号" forState:UIControlStateNormal];
    [logoutButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(logoutCurrentUser:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logoutButton];
    [logoutButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(0);
//        make.bottom.equalTo(self.view).offset(-10);
        make.top.equalTo(self.sideTableView.bottom).offset(0);
        int widthCenter = (self.view.frame.size.width - 220)*0.70710676908493042;
        make.right.equalTo(self.view.right).offset(-widthCenter);
        make.height.equalTo(40);
    }];
     */
    
}

#pragma mark setter method

- (UIImageView *)iconImageButton
{
    if (_iconImageButton == nil) {
        _iconImageButton = [[UIImageView alloc]initWithFrame:CGRectMake(20, 59, 60, 60)];
        _iconImageButton.layer.borderWidth = 1;
        _iconImageButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _iconImageButton.layer.cornerRadius = 30;
        _iconImageButton.layer.masksToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showUserInfo)];
        [_iconImageButton addGestureRecognizer:tap];
        _iconImageButton.userInteractionEnabled = YES;
        _iconImageButton.image = [UIImage imageNamed:[NSString stringWithFormat:@"head_portrait_%d",selectedThemeIndex]];
        
    }
    return _iconImageButton;
}

- (UILabel *)userName
{
    if (!_userName) {
        _userName = [[UILabel alloc]init];
        
    }
    return _userName;
}

#pragma mark tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [[self.sideArray objectAtIndex:0] count];
    }else{
        return [[self.sideArray objectAtIndex:1] count];
    }
    return self.sideArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        static NSString *defaultCellIndentifier = @"cellIndentifier";
        static NSString *dataCellIndentifier = @"dataIndentifier";
        if (indexPath.row == 1){
            DataShowTableViewCell *dataCell = [[DataShowTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:dataCellIndentifier];
            dataCell.backgroundColor = [UIColor clearColor];
            dataCell.cellName = [[self.sideArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            dataCell.cellImageName = [[self.imageArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            dataCell.selectionStyle = UITableViewCellSelectionStyleNone;
            dataCell.buttonTaped = @selector(buttonTaped:);
            dataCell.target = self;
            return dataCell;
        }else{
            
            DefaultTableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:defaultCellIndentifier];
            if (!defaultCell) {
                defaultCell = [[DefaultTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultCellIndentifier];
            }
            defaultCell.backgroundColor = [UIColor clearColor];
            defaultCell.cellLabelText = [[self.sideArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            defaultCell.cellImageName = [[self.imageArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            defaultCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            defaultCell.selectionStyle = UITableViewCellSelectionStyleBlue;
            return defaultCell;
        }
    }else{
        static NSString *cell1 = @"li";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell1];
        }
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.text = @"退出登录";
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.backgroundColor = [UIColor clearColor];

        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 1:{
            return 110;
            break;
        }
        default:
            break;
    }
    return TableViewCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:{
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:app.centerViewController] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        }
        case 2:{
            /*
            DeviceManagerViewController *user = [[DeviceManagerViewController alloc]init];
            UINavigationController *navi = (UINavigationController*)self.drawerController.centerViewController;
            [navi pushViewController:user animated:NO];
            [self.drawerController closeDrawerAnimated:NO completion:^(BOOL finished) {
            }];
            */
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[DeviceManagerViewController alloc] init]]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        }
        case 3:{
            /*
            SleepSettingViewController *user = [[SleepSettingViewController alloc]init];
            UINavigationController *navi = (UINavigationController*)self.drawerController.centerViewController;
            [navi pushViewController:user animated:NO];
            [self.drawerController closeDrawerAnimated:NO completion:^(BOOL finished) {
            }];
             */
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[SleepSettingViewController alloc] init]]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        }
        case 4:{
            /*
            APPSettingViewController *user = [[APPSettingViewController alloc]init];
            UINavigationController *navi = (UINavigationController*)self.drawerController.centerViewController;
            [navi pushViewController:user animated:NO];
            [self.drawerController closeDrawerAnimated:NO completion:^(BOOL finished) {
            }];
             */
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[APPSettingViewController alloc] init]]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        }
            
        default:
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

#pragma mark userAction

- (void)showUserInfo
{
//    PersonManagerViewController *person = [[PersonManagerViewController alloc]init];
//    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:person];
//    [self.sideMenuViewController setContentViewController:nav animated:YES];
//    [self.sideMenuViewController hideMenuViewController];

    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[UserInfoViewController alloc] init]] animated:YES];
    [self.sideMenuViewController hideMenuViewController];
}

- (void)buttonTaped:(UIButton*)sender
{
    DataStaticViewController *user = nil;
    if (sender.tag == 101) {
        user = [[DataStaticViewController alloc]init];
        user.title = @"周报";
        [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:user] animated:YES];
        [self.sideMenuViewController hideMenuViewController];
    }else if(sender.tag == 102){
        user = [[DataStaticViewController alloc]init];
        user.title = @"月报";
        [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:user] animated:YES];
        [self.sideMenuViewController hideMenuViewController];
    }else if (sender.tag == 103){
        user = [[DataStaticViewController alloc]init];
        user.title = @"季报";
        [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:user] animated:YES];
        [self.sideMenuViewController hideMenuViewController];
    }else if (sender.tag == 104){
        SleepAnalysisViewController *analysis = [[SleepAnalysisViewController alloc]init];
        [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:analysis] animated:YES];
        [self.sideMenuViewController hideMenuViewController];
    }
    /*
    UINavigationController *navi = (UINavigationController*)self.drawerController.centerViewController;
    [navi pushViewController:user animated:NO];
    [self.drawerController closeDrawerAnimated:NO completion:^(BOOL finished) {
    }];
     */
    

}

- (void)reloadThemeImage
{
    [super reloadThemeImage];
    self.imageArr = nil;
    self.imageArr = @[@[[NSString stringWithFormat:@"icon_todays_data_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_data_analysis_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_equipment_management_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_alarm_clock_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_setting_%d",selectedThemeIndex]],@[@"icon_setting"]];
    [self.sideTableView reloadData];
    _userName.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    if ([self.changeNowDate intValue]>7 && [self.changeNowDate intValue]<18) {
        self.bgImageView.image = [UIImage imageNamed:@"pic_bg_day"];
    }else {
        self.bgImageView.image = [UIImage imageNamed:@"pic_bg_night_0"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //因为userid无法在启动就获得
    NSMutableString *userId = [[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"%@",thirdPartyLoginNickName]];
    if (userId.length == 0) {
        _userName.text = @"匿名用户";
    }else if ([userId intValue]>0){
        [userId replaceCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        _userName.text = userId;
    }else{
        _userName.text = userId;
    }
    
    
    if (thirdPartyLoginIcon.length>0) {
        [self.iconImageButton setImageWithURL:[NSURL URLWithString:thirdPartyLoginIcon] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"head_portrait_%d",selectedThemeIndex]]];
    }else{
        [[NSUserDefaults standardUserDefaults]registerDefaults:@{[NSString stringWithFormat:@"%@%@",thirdPartyLoginUserId,thirdPartyLoginPlatform]:@""}];
        [[NSUserDefaults standardUserDefaults]synchronize];
        self.iconImageButton.image = [UIImage imageNamed:[NSString stringWithFormat:@"head_portrait_%d",selectedThemeIndex]];
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",thirdPartyLoginUserId,thirdPartyLoginPlatform]]isEqual:@""]) {
            self.iconImageButton.image = [UIImage imageWithData:[self downloadWithImage:self.iconImageButton]];
            
        }else{
            if ([UIImage imageWithData:[[NSUserDefaults standardUserDefaults]dataForKey:[NSString stringWithFormat:@"%@%@",thirdPartyLoginUserId,thirdPartyLoginPlatform]]]) {
                
                self.iconImageButton.image = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults]dataForKey:[NSString stringWithFormat:@"%@%@",thirdPartyLoginUserId,thirdPartyLoginPlatform]]];
            }
        }
    }
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
