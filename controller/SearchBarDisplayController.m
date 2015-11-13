//
//  SearchBarDisplayController.m
//  SleepRecoding
//
//  Created by Havi on 15/11/12.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "SearchBarDisplayController.h"
#import "XHRealTimeBlur.h"
#import "SearchUserTableViewCell.h"
#import "UITableView+Common.h"
#import "UIView+Frame.h"
#import "CSSearchModel.h"
#import "TMCacheExtend.h"

@class DeviceListViewController;

@interface SearchBarDisplayController ()<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) XHRealTimeBlur *backgroundView;
//
@property (nonatomic, strong) NSMutableArray *resultArr;
@property (nonatomic, strong) UIScrollView  *searchHistoryView;

@end

@implementation SearchBarDisplayController


- (void)setActive:(BOOL)visible animated:(BOOL)animated {
    
    if(!visible) {
        
        [_searchTableView removeFromSuperview];
        [_backgroundView removeFromSuperview];
        [_contentView removeFromSuperview];
        
        _searchTableView = nil;
        _contentView = nil;
        _backgroundView = nil;
        
        [super setActive:visible animated:animated];
    }else {
        
        [super setActive:visible animated:animated];
        NSArray *subViews = self.searchContentsController.view.subviews;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
            
            for (UIView *view in subViews) {
                
                if ([view isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")]) {
                    
                    NSArray *sub = view.subviews;
                    ((UIView*)sub[2]).hidden = YES;
                }
            }
        } else {
            
            [[subViews lastObject] removeFromSuperview];
        }
        
        if(!_contentView) {
            
            _contentView = ({
                
                UIView *view = [[UIView alloc] init];
                view.frame = CGRectMake(0.0f, 64.0f, kScreen_Width, kScreen_Height - 64.0f);
                view.backgroundColor = [UIColor lightGrayColor];
                view.userInteractionEnabled = YES;
                
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedContentView:)];
                [view addGestureRecognizer:tapGestureRecognizer];
                
                view;
            });
            
            _backgroundView = ({
                
                XHRealTimeBlur *blur = [[XHRealTimeBlur alloc] initWithFrame:_contentView.frame];
                blur.blurStyle = XHBlurStyleBlackGradient;
                blur;
                
            });
            _backgroundView.userInteractionEnabled = NO;
            
            [self initSubViewsInContentView];
        }
        
        [self.parentVC.view addSubview:_backgroundView];
        [self.parentVC.view addSubview:_contentView];
        [self.parentVC.view bringSubviewToFront:_contentView];
        self.searchBar.delegate = self;
    }
}

- (void)initSearchHistoryView {
    
    if(!_searchHistoryView) {
        
        _searchHistoryView = [[UIScrollView alloc] init];
        _searchHistoryView.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:_searchHistoryView];
        _searchHistoryView.frame = CGRectMake(0, 64, kScreen_Width, 350);
//        [_searchHistoryView mas_makeConstraints:^(MASConstraintMaker *make) {
//            
//            make.top.mas_equalTo(self);
//            make.left.mas_equalTo(@0);
//            make.width.mas_equalTo(kScreen_Width);
//            make.height.mas_equalTo(@350);
//        }];
        _searchHistoryView.contentSize = CGSizeMake(kScreen_Width, 0);
    }
    
    [[_searchHistoryView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 0.5)];
        view.backgroundColor = [UIColor colorWithHexString:@"0xdddddd"];
        [_searchHistoryView addSubview:view];
    }
    NSArray *array = [CSSearchModel getSearchHistory];
    CGFloat imageLeft = 12.0f;
    CGFloat textLeft = 34.0f;
    CGFloat height = 40.0f;
    
    for (int i = 0; i < array.count; i++) {
        
        UILabel *lblHistory = [[UILabel alloc] initWithFrame:CGRectMake(textLeft, i * height, kScreen_Width - textLeft, height)];
        lblHistory.userInteractionEnabled = YES;
        lblHistory.font = [UIFont systemFontOfSize:14];
        lblHistory.textColor = [UIColor colorWithHexString:@"0x222222"];
        lblHistory.text = array[i];
        
        UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        leftView.frame = CGRectMake(12, leftView.frame.origin.y, leftView.frame.size.width, leftView.frame.size.height);
        CGPoint center = leftView.center;
        center.y = lblHistory.center.y;
        leftView.center = center;
        leftView.image = [UIImage imageNamed:@"icon_search_clock"];
        
        UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
        rightImageView.frame = CGRectMake(kScreen_Width - 12 - rightImageView.frame.size.width, rightImageView.frame.origin.y, rightImageView.frame.size.width, rightImageView.frame.size.height);
        CGPoint center1 = leftView.center;
        center1.y = lblHistory.center.y;
        rightImageView.center = center;
        rightImageView.image = [UIImage imageNamed:@"icon_arrow_searchHistory"];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(imageLeft, (i + 1) * height, kScreen_Width - imageLeft, 0.5)];
        view.backgroundColor = [UIColor colorWithHexString:@"0xdddddd"];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedHistory:)];
        [lblHistory addGestureRecognizer:tapGestureRecognizer];
        
        [_searchHistoryView addSubview:lblHistory];
        [_searchHistoryView addSubview:leftView];
        [_searchHistoryView addSubview:rightImageView];
        [_searchHistoryView addSubview:view];
    }
    
    if(array.count) {
        
        UIButton *btnClean = [UIButton buttonWithType:UIButtonTypeCustom];
        btnClean.titleLabel.font = [UIFont systemFontOfSize:14];
        [btnClean setTitle:@"清除搜索历史" forState:UIControlStateNormal];
        [btnClean setTitleColor:[UIColor colorWithHexString:@"0x1bbf75"] forState:UIControlStateNormal];
        [btnClean setFrame:CGRectMake(0, array.count * height, kScreen_Width, height)];
        [_searchHistoryView addSubview:btnClean];
        [btnClean addTarget:self action:@selector(didCLickedCleanSearchHistory:) forControlEvents:UIControlEventTouchUpInside];
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(imageLeft, (array.count + 1) * height, kScreen_Width - imageLeft, 0.5)];
            view.backgroundColor = [UIColor colorWithHexString:@"0xdddddd"];
            [_searchHistoryView addSubview:view];
        }
    }
    
}

- (void)didClickedContentView:(UIGestureRecognizer *)sender {
    
    [self.searchBar resignFirstResponder];
    [self.searchBar removeFromSuperview];
    [self.searchTableView removeFromSuperview];
    
    [_backgroundView removeFromSuperview];
    [_contentView removeFromSuperview];
    _searchTableView = nil;
    _contentView = nil;
    _backgroundView = nil;
}

#pragma mark Private Method

- (void)initSubViewsInContentView {
    
//    UILabel *lblHotKey = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 4.0f, kScreen_Width, 39.0f)];
//    [lblHotKey setUserInteractionEnabled:YES];
//    [lblHotKey setText:@"热门话题"];
//    [lblHotKey setFont:[UIFont systemFontOfSize:12.0f]];
//    [lblHotKey setTextColor:[UIColor colorWithHexString:@"0x999999"]];
//    [_contentView addSubview:lblHotKey];
//    
//    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedMoreHotkey:)];
//    [lblHotKey addGestureRecognizer:tapGestureRecognizer];
//    
//    UIImageView *moreIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10.0f, 20.0f, 20.0f)];
//    moreIconView.image = [UIImage imageNamed:@"me_info_arrow_left"];
//    moreIconView.right = kScreen_Width - 12;
//    moreIconView.centerY = lblHotKey.centerY;
//    [_contentView addSubview:moreIconView];
//    
//    __weak typeof(self) weakSelf = self;
//    
//    _topicHotkeyView = [[TopicHotkeyView alloc] initWithFrame:CGRectMake(0, 44, kScreen_Width, 0)];
//    _topicHotkeyView.block = ^(NSDictionary *dict){
//        [weakSelf.searchBar resignFirstResponder];
//        
//        CSTopicDetailVC *vc = [[CSTopicDetailVC alloc] init];
//        vc.topicID = [dict[@"id"] intValue];
//        [weakSelf.parentVC.navigationController pushViewController:vc animated:YES];
//        
//    };
//    [_contentView addSubview:_topicHotkeyView];
//    [_topicHotkeyView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(@0);
//        make.top.mas_equalTo(@44);
//        make.width.mas_equalTo(kScreen_Width);
//        make.height.mas_equalTo(@0);
//    }];
//    
//    [self initSearchHistoryView];
//    
//    [[Coding_NetAPIManager sharedManager] request_TopicHotkeyWithBlock:^(id data, NSError *error) {
//        if(data && _contentView) {
//            NSArray *array = data;
//            NSMutableArray *hotkeyArray = [[NSMutableArray alloc] initWithCapacity:6];
//            for (int i = 0; i < array.count; i++) {
//                if (i == 6) {
//                    break;
//                }
//                [hotkeyArray addObject:array[i]];
//            }
//            
//            [weakSelf.topicHotkeyView setHotkeys:hotkeyArray];
//            [weakSelf.topicHotkeyView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.left.mas_equalTo(@0);
//                make.top.mas_equalTo(@44);
//                make.width.mas_equalTo(kScreen_Width);
//                make.height.mas_equalTo(weakSelf.topicHotkeyView.frame.size.height);
//            }];
//        }
//    }];
}

#pragma mark -
#pragma mark UISearchBarDelegate Support

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
//    [CSSearchModel addSearchHistory:searchBar.text];
//    [self initSearchHistoryView];
    [self.searchBar resignFirstResponder];
//
    [self initSearchResultsTableView];
    [_searchTableView layoutSubviews];
    HaviLog(@"搜索");
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    HaviLog(@"取消");
    [self.searchTableView removeFromSuperview];

    [self.searchBar removeFromSuperview];
    
    [_backgroundView removeFromSuperview];
    [_contentView removeFromSuperview];
    _searchTableView = nil;
    _contentView = nil;
    _backgroundView = nil;
}

- (void)initSearchResultsTableView {
    
    _resultArr = [[NSMutableArray alloc] init];
    for (int i=0; i<5; i++) {
        [_resultArr addObject:@"Li"];
    }
    
    if(!_searchTableView) {
        _searchTableView = ({
            
            UITableView *tableView = [[UITableView alloc] initWithFrame:_contentView.frame style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor whiteColor];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//            [tableView registerClass:[CSSearchCell class] forCellReuseIdentifier:kCellIdentifier_Search];
            tableView.dataSource = self;
            tableView.delegate = self;
//            {
//                __weak typeof(self) weakSelf = self;
//                [tableView addInfiniteScrollingWithActionHandler:^{
//                    [weakSelf loadMore];
//                }];
//            }
            
            [self.parentVC.parentViewController.view addSubview:tableView];
            
//            self.headerLabel = ({
//                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, kScreen_Width, 44)];
//                label.backgroundColor = [UIColor clearColor];
//                label.textColor = [UIColor colorWithHexString:@"0x999999"];
//                label.textAlignment = NSTextAlignmentCenter;
//                label.font = [UIFont systemFontOfSize:12];
//                
//                label;
//            });
//            
//            UIView *headview = ({
//                UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44)];
//                v.backgroundColor = [UIColor whiteColor];
//                [v addSubview:self.headerLabel];
//                v;
//            });
//            tableView.tableHeaderView = headview;
            
            tableView;
        });
    }
    [_searchTableView.superview bringSubviewToFront:_searchTableView];
    //    [self.searchBar.superview bringSubviewToFront:_searchTableView];
    
    //    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.searchTableView];
    //    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    [_searchTableView reloadData];
//    [self refresh];
}

#pragma mark UITableViewDelegate & UITableViewDataSource Support

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_resultArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIndentifier = @"cellIndentifier";
    SearchUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[SearchUserTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


@end