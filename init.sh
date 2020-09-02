# 初始化工作区，首次检出代码或修改启动图、Logo、protobuf文件时，需要运行该脚本
#!/bin/bash
flutter pub get
# 从assets/images/splash.png中生成安卓和iOS的原生的启动图
flutter pub run flutter_native_splash:create
# 从assets/images/logo.png中生成安卓和iOS的Logo
flutter pub run flutter_launcher_icons:main
