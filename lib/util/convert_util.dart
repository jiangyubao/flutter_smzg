import 'dart:convert';

class ConvertUtil {
  // object 转为 string json
  static String objecttToString<T>(T t) {
    return cnParamsEncode(jsonEncode(t));
  }

  // string json 转为 map
  static Map<String, dynamic> stringToMap(String str) {
    return json.decode(cnParamsDecode(str));
  }

  // fluro 传递中文参数前，先转换，fluro 不支持中文传递
  static String cnParamsEncode(String originalCn) {
    return jsonEncode(Utf8Encoder().convert(originalCn));
  }

  // fluro 传递后取出参数，解析
  static String cnParamsDecode(String encodeCn) {
    final List<int> list = List<int>();
    jsonDecode(encodeCn).forEach(list.add);
    final String value = Utf8Decoder().convert(list);
    return value;
  }
}
