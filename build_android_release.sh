# flutter_build_android_release.sh来源于：https://github.com/jiangyubao/hotcode/tree/master/bash
# 参数1：app名字，中文或英文
# 参数2：二进制存放目录
echo "尝试生成flutter_umpush插件内容"
# 友盟插件的包名是动态的，需要额外调用一个程序来生成
cd ../flutter_umpush && dart bin/create.dart com.itou.yun.cordova.xiaodian && cd ../flutter_smzg
cd ../flutter_wechat_plugin && dart bin/create.dart com.itou.yun.cordova.xiaodian && cd ../flutter_smzg
~/bin/flutter_build_android_release.sh 小店总管安卓版 /Users/jiangyb/Documents/app_deploy