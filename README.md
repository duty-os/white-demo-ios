# white-ios-demo

# quick start

```shell
# 之前未升级pod，可能会出现 Unable to find a specification for White-SDK-iOS
# 此时请先执行 pod repo update
pod install
```

## iOS12 适配

在配置 WhiteSDK 前，请先确保 WhiteBoardView 已经添加在视图栈中，否则 WhiteSDK API 将无法正确调用！