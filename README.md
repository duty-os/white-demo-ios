# white-ios-demo

简介：本项目为 iOS [white-sdk-ios](https://github.com/duty-os/white-sdk-ios-release) 的示例 pod demo。由于跨越 repo 太多，更新不及时。
请直接查看 [white-sdk-ios](https://github.com/duty-os/white-sdk-ios-release) 中查看。

# quick start

```shell
# 之前未升级pod，可能会出现 Unable to find a specification for White-SDK-iOS
# 此时请先执行 pod repo update
pod install
```

## iOS12 适配

在配置 WhiteSDK 前，请先确保 WhiteBoardView 已经添加在视图栈中，否则 WhiteSDK API 将无法正确调用！

## 自定义事件支持

```Objective-C
// 自定义事件名称
NSString *kCustomEvent =  @"custom";
// 订阅自定义事件
[self.room addMagixEventListener:kCustomEvent];
// 取消订阅
[self.room removeMagixEventListener:kCustomEvent];
// 执行订阅内容
[self.room dispatchMagixEvent:eventName payload:payload]
//实现delegate
- (void)fireMagixEvent:(WhiteEvent *)event;
```