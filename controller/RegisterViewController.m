//
//  RegisterViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/3/17.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "RegisterViewController.h"
#import "btRippleButtton.h"
#import <AudioToolbox/AudioToolbox.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "MTStatusBarOverlay.h"
#import "UserProtocolViewController.h"
#import "HaviAnimationView.h"
#import "ImageUtil.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface RegisterViewController ()<UITextFieldDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate>
@property (nonatomic,strong) UITextField *nameText;
@property (nonatomic,strong) UITextField *passWordText;
@property (nonatomic,strong) BTRippleButtton *iconButton;
@property (nonatomic,strong) NSData *iconData;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.bgImageView.image = [UIImage imageNamed:@"pic_login_bg"];

    [self createClearBgNavWithTitle:nil createMenuItem:^UIView *(int nIndex) {
        if (nIndex == 1)
        {
            [self.leftButton addTarget:self action:@selector(backToHomeView:) forControlEvents:UIControlEventTouchUpInside];
            return self.leftButton;
        }
        
        return nil;
    }];
    [self creatSubView];
    
}

- (void)creatSubView
{
    //
    self.nameText = [[UITextField alloc]init];
    [self.view addSubview:self.nameText];
    self.nameText.delegate = self;
    [self.nameText setTextColor:selectedThemeIndex==0?DefaultColor:[UIColor lightGrayColor]];
    self.nameText.borderStyle = UITextBorderStyleNone;
    self.nameText.font = DefaultWordFont;
    NSDictionary *boldFont = @{NSForegroundColorAttributeName:selectedThemeIndex==0?DefaultColor:[UIColor grayColor],NSFontAttributeName:DefaultWordFont};
    NSAttributedString *attrValue = [[NSAttributedString alloc] initWithString:@"请输入密码" attributes:boldFont];
    self.nameText.attributedPlaceholder = attrValue;
    self.nameText.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameText.keyboardType = UIKeyboardTypeAlphabet;
    [self.nameText setReturnKeyType:UIReturnKeyDone];
    self.nameText.secureTextEntry = YES;
    
    self.passWordText = [[UITextField alloc]init];
    [self.view addSubview:self.passWordText];
    self.passWordText.delegate = self;
    [self.passWordText setReturnKeyType:UIReturnKeyDone];
    self.passWordText.textColor = selectedThemeIndex==0?DefaultColor:[UIColor lightGrayColor];
    self.passWordText.borderStyle = UITextBorderStyleNone;
    self.passWordText.font = DefaultWordFont;
    NSAttributedString *attrValue1 = [[NSAttributedString alloc] initWithString:@"请确认密码" attributes:boldFont];
    self.passWordText.attributedPlaceholder = attrValue1;
    self.passWordText.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passWordText.keyboardType = UIKeyboardTypeAlphabet;
    self.passWordText.secureTextEntry = YES;
    //
    self.nameText.background = [UIImage imageNamed:[NSString stringWithFormat:@"textbox_password_%d",selectedThemeIndex]];
    self.passWordText.background = [UIImage imageNamed:[NSString stringWithFormat:@"textbox_password_%d",selectedThemeIndex]];
    //
    self.iconButton = [[BTRippleButtton alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"pic_head_take_portrait_%d",selectedThemeIndex]]
                                                    andFrame:CGRectMake((self.view.bounds.size.width-100)/2, 84, 100, 100)
                                                onCompletion:^(BOOL success) {
                                                    [self tapIconImage:nil];
                                                    HaviLog(@"I am from Block, execution.");
                                                }];
    
    [self.iconButton setRippeEffectEnabled:YES];
    [self.iconButton setRippleEffectWithColor:[UIColor colorWithRed:0.953f green:0.576f blue:0.420f alpha:1.00f]];
    [self.view addSubview:self.iconButton];
    self.iconButton.userInteractionEnabled = YES;
    //
     [self.nameText makeConstraints:^(MASConstraintMaker *make) {
     make.centerX.equalTo(self.view.centerX);
     make.width.equalTo(ButtonViewWidth);
     make.height.equalTo(ButtonHeight);
     make.top.equalTo(self.iconButton.bottom).offset(20);
     
     }];
    //
    [self.passWordText makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.width.equalTo(ButtonViewWidth);
        make.height.equalTo(ButtonHeight);
        make.top.equalTo(self.nameText.bottom).offset(10);
    }];
    //    添加小图标
     UIImageView *phoneImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_password_%d",selectedThemeIndex]]];
     phoneImage.frame = CGRectMake(0, 0,30, 20);
     phoneImage.contentMode = UIViewContentModeScaleAspectFit;
     self.nameText.leftViewMode = UITextFieldViewModeAlways;
     self.nameText.leftView = phoneImage;
     //
    UIImageView *passImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_password_%d",selectedThemeIndex]]];
    passImage.frame = CGRectMake(0, 0,30, 20);
    passImage.contentMode = UIViewContentModeScaleAspectFit;
    self.passWordText.leftViewMode = UITextFieldViewModeAlways;
    self.passWordText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.passWordText.leftView = passImage;
    //    添加button
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [registerButton setTitle:@"完成注册" forState:UIControlStateNormal];
    [registerButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_caeate_account_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    [registerButton setTitleColor:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor] forState:UIControlStateNormal];
    registerButton.titleLabel.font = DefaultWordFont;
    [registerButton addTarget:self action:@selector(registerUser:) forControlEvents:UIControlEventTouchUpInside];
    registerButton.layer.cornerRadius = 0;
    registerButton.layer.masksToBounds = YES;
    [self.view addSubview:registerButton];
    
    //
    /*取消
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_wireframe"] forState:UIControlStateNormal];
    [backButton setTitle:@"返回登录" forState:UIControlStateNormal];
    backButton.titleLabel.font = DefaultWordFont;
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backToHomeView:) forControlEvents:UIControlEventTouchUpInside];
    backButton.layer.cornerRadius = 5;
    backButton.layer.masksToBounds = YES;
    [self.view addSubview:backButton];
    */
    //
    [registerButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.width.equalTo(ButtonViewWidth);
        make.height.equalTo(ButtonHeight);
        make.top.equalTo(self.passWordText.bottom).offset(20);
    }];
    
    /*
    [backButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.width.equalTo(ButtonViewWidth);
        make.height.equalTo(ButtonHeight);
        make.top.equalTo(registerButton.bottom).offset(10);
    }];
    //*/
    //协议说明
    UILabel *protocolLabel = [[UILabel alloc]init];
    [self.view addSubview:protocolLabel];
    [protocolLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.width.equalTo(ButtonViewWidth);
        make.height.equalTo(20);
        make.top.equalTo(registerButton.bottom).offset(10);
    }];
    protocolLabel.font = [UIFont systemFontOfSize:15];
    //
    NSString *sting = [NSString stringWithFormat:@"点击-完成注册,即表示您同意《迈动用户协议》"];
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc]initWithString:sting];
    [attribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, [sting length])];
    [attribute addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.984f green:0.549f blue:0.463f alpha:1.00f] range:[sting rangeOfString:@"《迈动用户协议》"]];
    [attribute addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:[sting rangeOfString:@"点击-完成注册,即表示您同意"]];
    
    protocolLabel.textAlignment = NSTextAlignmentLeft;
    protocolLabel.numberOfLines = 0;
    protocolLabel.attributedText = attribute;
    protocolLabel.userInteractionEnabled = YES;
    //
    UITapGestureRecognizer *tapProtocol = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showProtocol:)];
    [protocolLabel addGestureRecognizer:tapProtocol];

}

- (void)registerUser:(UIButton *)sender
{
    if (![self isNetworkExist]) {
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
        return;
    }
    if (![self.nameText.text isEqualToString:self.passWordText.text]) {
        [self.view makeToast:@"密码不一致" duration:2 position:@"center"];
        return;
    }
    if (self.passWordText.text.length == 0) {
        [self.view makeToast:@"请输入密码" duration:2 position:@"center"];
        return;
    }
    
    NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
                        [UIImage imageNamed:@"havi1_1"],
                        [UIImage imageNamed:@"havi1_2"],
                        [UIImage imageNamed:@"havi1_3"],
                        [UIImage imageNamed:@"havi1_4"],
                        [UIImage imageNamed:@"havi1_5"]];
    [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
    [MMProgressHUD showWithTitle:nil status:nil images:images];
    NSDictionary *dic = @{
                          @"CellPhone": self.cellPhoneNum, //手机号码
                          @"Email": @"", //邮箱地址，可留空，扩展注册用
                          @"Password": self.passWordText.text ,//传递明文，服务器端做加密存储
                          @"UserValidationServer" : MeddoPlatform,
                          @"UserIdOriginal":@""
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    [WTRequestCenter postWithURL:[NSString stringWithFormat:@"%@v1/user/UserRegister",BaseUrl] header:header parameters:dic finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *responseDic = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[responseDic objectForKey:@"ReturnCode"]intValue]==10005) {
            [MMProgressHUD dismissWithError:@"该手机号已注册" afterDelay:2];
        }else if([[responseDic objectForKey:@"ReturnCode"]intValue]==200){
            [MMProgressHUD dismiss];
            [[MMProgressHUD sharedHUD] setDismissAnimationCompletion:^{
                [self.view makeToast:@"注册成功" duration:2 position:@"center"];
            }];
            self.registerSuccessed(1);
            thirdPartyLoginPlatform = MeddoPlatform;
            thirdPartyLoginUserId = [responseDic objectForKey:@"UserID"];
            if (self.iconData) {
                [self uploadWithImageData:self.iconData withUserId:thirdPartyLoginUserId];
            }

            NSRange range = [thirdPartyLoginUserId rangeOfString:@"$"];
            thirdPartyLoginNickName = [[responseDic objectForKey:@"UserID"] substringFromIndex:range.location+range.length];
            thirdPartyLoginIcon = @"";
            thirdPartyLoginToken = @"";
            [UserManager setGlobalOauth];
        }else{
            [MMProgressHUD dismiss];
        }
    } failed:^(NSURLResponse *response, NSError *error) {
        [MMProgressHUD dismiss];
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
    
}

#pragma mark 拍照

- (void)showProtocol:(UITapGestureRecognizer *)gesture
{
    UserProtocolViewController *protocol = [[UserProtocolViewController alloc]init];
    protocol.isPush = NO;
    [self presentViewController:protocol animated:YES completion:nil];
}

- (void)tapIconImage:(UIGestureRecognizer *)gesture
{
    UIActionSheet *sheet;
    
    // 判断是否支持相机
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
        
    }
    
    else {
        
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择", nil];
        
    }
    
    sheet.tag = 255;
    
    [sheet showInView:self.view];
}

#pragma mark actionSheet代理

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        
        NSUInteger sourceType = 0;
        
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            switch (buttonIndex) {
                case 2:
                    // 取消
                    return;
                case 0:{
                    // 相机
                    NSString *mediaType = AVMediaTypeVideo;
                    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
                    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
                        [self.view makeToast:@"请在设置中打开照相机权限" duration:3 position:@"center"];
                        NSLog(@"相机权限受限");
                    }else{
                        sourceType = UIImagePickerControllerSourceTypeCamera;
                        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                        imagePickerController.mediaTypes = @[(NSString*) kUTTypeImage];
                        imagePickerController.delegate = self;
                        
                        imagePickerController.allowsEditing = YES;
                        
                        imagePickerController.sourceType = sourceType;
                        
                        [self presentViewController:imagePickerController animated:YES completion:^{}];
                    }
                    
                    break;
                }
                    
                case 1:{
                    // 相册
                    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
                    if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied){
                        //无权限
                        [self.view makeToast:@"请在设置中打开照片库权限" duration:3 position:@"center"];
                    }else{
                        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                        imagePickerController.mediaTypes = @[(NSString*) kUTTypeImage];
                        imagePickerController.delegate = self;
                        
                        imagePickerController.allowsEditing = YES;
                        
                        imagePickerController.sourceType = sourceType;
                        
                        [self presentViewController:imagePickerController animated:YES completion:^{
                            self.navigationController.navigationBarHidden = YES;
                        }];
                    }
                    break;
                }
            }
        }
        else {
            if (buttonIndex == 1) {
                
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.mediaTypes = @[(NSString*) kUTTypeImage];
                imagePickerController.delegate = self;
                
                imagePickerController.allowsEditing = YES;
                
                imagePickerController.sourceType = sourceType;
                
                [self presentViewController:imagePickerController animated:YES completion:^{}];
                
            }
        }
        // 跳转到相机或相册页面
        
    }
}

#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.iconButton changeImage:image];
    /* 此处info 有六个值
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     * UIImagePickerControllerMediaURL;       // an NSURL
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     */
    // 保存图片至本地，方法见下文
    NSData *imageData = [self calculateIconImage:image];
    self.iconData = imageData;
    user_Register_Data = imageData;
    [HaviAnimationView animationFlipFromLeft:self.iconButton];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [self setNeedsStatusBarAppearanceUpdate];
}

#define UploadImageSize          100000
- (NSData *)calculateIconImage:(UIImage *)image
{
    if(image){
        
        [image fixOrientation];
        CGFloat height = image.size.height;
        CGFloat width = image.size.width;
        NSData *data = UIImageJPEGRepresentation(image,1);
        
        float n;
        n = (float)UploadImageSize/data.length;
        data = UIImageJPEGRepresentation(image, n);
        while (data.length > UploadImageSize) {
            image = [UIImage imageWithData:data];
            height /= 2;
            width /= 2;
            image = [image scaleToSize:CGSizeMake(width, height)];
            data = UIImageJPEGRepresentation(image,1);
        }
        return data;
        
    }
    return nil;
}



#pragma mark 上传头像
- (void)uploadWithImageData:(NSData*)imageData withUserId:(NSString *)userId
{
    NSDictionary *dicHeader = @{
                                @"AccessToken": @"123456789",
                                };
    NSString *urlStr = [NSString stringWithFormat:@"%@/v1/file/UploadFile/%@",BaseUrl,userId];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:0 timeoutInterval:5.0f];
    [request setValue:[dicHeader objectForKey:@"AccessToken"] forHTTPHeaderField:@"AccessToken"];
    [self setRequest:request withImageData:imageData];
    HaviLog(@"开始上传...");
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[dic objectForKey:@"ReturnCode"] intValue]==200) {
            [[NSUserDefaults standardUserDefaults]setObject:imageData forKey:[NSString stringWithFormat:@"%@%@",thirdPartyLoginUserId,thirdPartyLoginPlatform]];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
        }
        HaviLog(@"头像上传结果Result--%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
    }];
}

- (void)setRequest:(NSMutableURLRequest *)request withImageData:(NSData*)imageData
{
    NSMutableData *body = [NSMutableData data];
    // 表单数据
    
    /// 图片数据部分
    NSMutableString *topStr = [NSMutableString string];
    [body appendData:[topStr dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:imageData];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // 设置请求类型为post请求
    request.HTTPMethod = @"post";
    // 设置request的请求体
    request.HTTPBody = body;
    // 设置头部数据，标明上传数据总大小，用于服务器接收校验
    [request setValue:[NSString stringWithFormat:@"%ld", body.length] forHTTPHeaderField:@"Content-Length"];
    // 设置头部数据，指定了http post请求的编码方式为multipart/form-data（上传文件必须用这个）。
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; image/png"] forHTTPHeaderField:@"Content-Type"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    HaviLog(@"cancel");
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

#pragma mark delegate 隐藏键盘

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    HaviLog(@"touched view");
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)backToHomeView:(UIButton*)button
{
    self.backToCodeButtonClicked(1);
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
