//
//  ViewController.m
//  white-demo-ios
//
//  Created by leavesster on 2018/8/19.
//  Copyright © 2018年 yleaf. All rights reserved.
//

#import "ViewController.h"
#import <White-SDK-iOS/WhiteSDK.h>

@interface ViewController ()
@property (nonatomic, copy) NSString *sdkToken;
@property (nonatomic, strong) WhiteRoom *room;
@property (nonatomic, strong) WhiteSDK *sdk;
@property (nonatomic, strong) WhiteBoardView *boardView;
@end

@implementation ViewController

static NSString * const kCustomEvent = @"custom";

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sdkToken = @"WHITEcGFydG5lcl9pZD1DYzlFNTJhTVFhUU5TYmlHNWJjbkpmVThTNGlNVXlJVUNwdFAmc2lnPTE3Y2ZiYzg0ZGM5N2FkNDAxZmY1MTM0ODMxYTdhZTE2ZGQ3MTdmZjI6YWRtaW5JZD00JnJvbGU9bWluaSZleHBpcmVfdGltZT0xNTY2MDQwNjk4JmFrPUNjOUU1MmFNUWFRTlNiaUc1YmNuSmZVOFM0aU1VeUlVQ3B0UCZjcmVhdGVfdGltZT0xNTM0NDgzNzQ2Jm5vbmNlPTE1MzQ0ODM3NDYzMzYwMA";
    self.view.backgroundColor = [UIColor orangeColor];
    if ([self.roomUuid length] > 0) {
        [self joinRoom];
    } else {
        [self createRoom];
    }
}

- (void)setupShareBarItem
{
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"分享", nil) style:UIBarButtonItemStylePlain target:self action:@selector(shareRoomUUID)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"自定义", nil) style:UIBarButtonItemStylePlain target:self action:@selector(customRoomEvent)];
    self.navigationItem.rightBarButtonItems = @[item1, item2];
}

- (void)shareRoomUUID
{
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.roomUuid ? :@""] applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeAirDrop];
    activityVC.popoverPresentationController.sourceView = [self.navigationItem.rightBarButtonItem valueForKey:@"view"];
    activityVC.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
    };
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)customRoomEvent
{
    NSDictionary *dict = @{@"test": @"1234"};
    [self.room dispatchMagixEvent:kCustomEvent payload:dict];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self setTestingAPI];
}

#pragma mark - Room Action
- (void)createRoom
{
    self.title = NSLocalizedString(@"创建房间中...", nil);
    [self creatNewRoomRequestWithResult:^(BOOL success, id response) {
        if (success) {
            NSString *roomToken = response[@"msg"][@"roomToken"];
            NSString *uuid = response[@"msg"][@"room"][@"uuid"];
            self.roomUuid = uuid;
            if (uuid && roomToken) {
                [self joinRoomWithUuid:uuid roomToken:roomToken];
            } else {
                self.title = NSLocalizedString(@"创建失败", nil);
            }
        } else {
            self.title = NSLocalizedString(@"创建失败", nil);
        }
    }];
}

- (void)joinRoom
{
    self.title = NSLocalizedString(@"加入房间中...", nil);
    [self getRoomTokenWithRoomUuid:self.roomUuid Result:^(BOOL success, id response) {
        if (success) {
            NSString *roomToken = response[@"msg"][@"roomToken"];
            [self joinRoomWithUuid:self.roomUuid roomToken:roomToken];
        } else {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"加入房间失败", nil) message:[NSString stringWithFormat:@"错误信息:%@", [response description]] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alertVC addAction:action];
            [self presentViewController:alertVC animated:YES completion:nil];
        }
    }];
}

- (void)joinRoomWithUuid:(NSString *)uuid roomToken:(NSString *)roomToken
{
    self.boardView = [[WhiteBoardView alloc] init];
    //请提前将 boardView 添加至视图栈中（生成 whiteSDK 前）。否则 iOS 12 真机无法执行正常执行sdk代码。
    self.boardView.frame = self.view.bounds;
    self.boardView.autoresizingMask = UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.boardView];

    self.sdk = [[WhiteSDK alloc] initWithWhiteBoardView:self.boardView config:[WhiteSdkConfiguration defaultConfig]];
    [self.sdk joinRoomWithRoomUuid:uuid roomToken:roomToken callbacks:(id<WhiteRoomCallbackDelegate>)self completionHandler:^(BOOL success, WhiteRoom *room, NSError *error) {
        if (success) {
            self.title = NSLocalizedString(@"我的白板", nil);
            [self setupShareBarItem];
            self.room = room;
            [self.room addMagixEventListener:kCustomEvent];
        } else {
            self.title = NSLocalizedString(@"加入失败", nil);
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"加入房间失败", nil) message:[NSString stringWithFormat:@"错误信息:%@", [error localizedDescription]] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [alertVC addAction:action];
            [self presentViewController:alertVC animated:YES completion:nil];
        }
    }];
}

#pragma mark - Set API
- (void)setTestingAPI
{
    [self.room setViewMode:WhiteViewModeBroadcaster];
    
    WhiteMemberState *mState = [[WhiteMemberState alloc] init];
    mState.currentApplianceName = ApplianceRectangle;
    [self.room setMemberState:mState];
    
//    WhitePptPage *pptPage = [[WhitePptPage alloc] init];
    //图片网址
//    pptPage.src = @"";
//    pptPage.width = 600;
//    pptPage.height = 600;
//    [self.room pushPptPages:@[pptPage]];
}

#pragma mark - Get API
- (void)getTestingAPI
{
    [self.room getPptImagesWithResult:^(NSArray<NSString *> *pptPages) {
        NSLog(@"%@", pptPages);
        
    }];
    
    [self.room getGlobalStateWithResult:^(WhiteGlobalState *state) {
        NSLog(@"%@", [state jsonString]);
    }];
    
    [self.room getMemberStateWithResult:^(WhiteMemberState *state) {
        NSLog(@"%@", [state jsonString]);
    }];
    
    [self.room getBroadcastStateWithResult:^(WhiteBroadcastState *state) {
        NSLog(@"%@", [state jsonString]);
    }];
    
    [self.room getRoomMembersWithResult:^(NSArray<WhiteRoomMember *> *roomMembers) {
        for (WhiteRoomMember *m in roomMembers) {
            NSLog(@"%@", [m jsonString]);
        }
    }];
}


#pragma mark - WhiteRoomCallbackDelegate
- (void)firePhaseChanged:(WhiteRoomPhase)phase
{
    NSLog(@"%s, %ld", __FUNCTION__, (long)phase);
}

- (void)fireRoomStateChanged:(WhiteRoomState *)magixPhase;
{
    NSLog(@"%s, %@", __func__, [magixPhase jsonString]);
    if ([magixPhase.pptImages count] > 0) {
        //传入ppt时，立刻跳到对应页
        WhiteGlobalState *state = [[WhiteGlobalState alloc] init];
        state.currentSceneIndex = [magixPhase.pptImages count] - 1;
        [self.room setGlobalState:state];
    }
}

- (void)fireBeingAbleToCommitChange:(BOOL)isAbleToCommit
{
    NSLog(@"%s, %d", __func__, isAbleToCommit);
}

- (void)fireDisconnectWithError:(NSString *)error
{
    NSLog(@"%s, %@", __func__, error);
    
}

- (void)fireKickedWithReason:(NSString *)reason
{
    NSLog(@"%s, %@", __func__, reason);
}

- (void)fireCatchErrorWhenAppendFrame:(NSUInteger)userId error:(NSString *)error
{
    NSLog(@"%s, %luu %@", __func__,(unsigned long) (unsigned long)userId, error);
}

- (void)fireMagixEvent:(WhiteEvent *)event
{
    NSLog(@"fireMagixEvent: %@", [event jsonString]);
}


#pragma mark - Room server request
//向服务器请求，提供RoomUUID，获取RoomToken
- (void)creatNewRoomRequestWithResult:(void (^) (BOOL success, id response))result;
{
    //更换为自己的服务器请求
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://cloudcapiv3.herewhite.com/room?token=%@", self.sdkToken]]];
    NSMutableURLRequest *modifyRequest = [request mutableCopy];
    [modifyRequest setHTTPMethod:@"POST"];
    [modifyRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [modifyRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSDictionary *params = @{@"name": @"test", @"limit": @110, @"width": @1024, @"height": @768};
    NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    [modifyRequest setHTTPBody:postData];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:modifyRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error && result) {
                result(NO, nil);
            } else if (result) {
                NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                result(YES, responseObject);
            }
        });
    }];
    [task resume];
}

//向服务器端请求，获取RoomUUID，RoomToken
- (void)getRoomTokenWithRoomUuid:(NSString *)uuid Result:(void (^) (BOOL success, id response))result
{
    //更换为自己的服务器请求
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://cloudcapiv3.herewhite.com/room/join?uuid=%@&token=%@", uuid,self.sdkToken]]];
    NSMutableURLRequest *modifyRequest = [request mutableCopy];
    [modifyRequest setHTTPMethod:@"POST"];
    [modifyRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:modifyRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error && result) {
                result(NO, nil);
            } else if (result) {
                NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if ([responseObject[@"code"] integerValue]  == 200) {
                    result(YES, responseObject);
                } else {
                    result(NO, responseObject);
                }
            }
        });
    }];
    [task resume];
}

@end
