# flutter_build_android_release.sh来源于：https://github.com/jiangyubao/hotcode/tree/master/bash
# 参数1：app名字，中文或英文
# 参数2：二进制存放目录
cd ../flutter_umpush && dart bin/create.dart com.itou.yun.cordova.koudai && cd ../flutter_smzg
cd ../flutter_wechat_plugin && dart bin/create.dart com.itou.yun.cordova.koudai && cd ../flutter_smzg
~/bin/flutter_build_android_release.sh 口袋好店安卓版 /Users/jiangyb/Documents/app_deploy


