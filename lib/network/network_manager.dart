import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

class NetworkManager {
  static final NetworkManager _instance = NetworkManager._internal();

  factory NetworkManager() => _instance;
  late Dio dio;
  var box = Hive.box('Box');

  NetworkManager._internal() {
    // BaseOptions、Options、RequestOptions 都可以配置参数，优先级别依次递增，且可以根据优先级别覆盖参数
    BaseOptions options = BaseOptions(
      //连接服务器超时时间，单位是毫秒.
      connectTimeout: const Duration(milliseconds: 5000),

      // 响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: const Duration(milliseconds: 5000),

      // Http请求头.
      headers: {},

      /// 请求的Content-Type，默认值是"application/json; charset=utf-8".
      /// 如果您想以"application/x-www-form-urlencoded"格式编码请求数据,
      /// 可以设置此选项为 `Headers.formUrlEncodedContentType`,  这样[Dio]
      /// 就会自动编码请求体.
      contentType: 'application/json; charset=utf-8',

      /// [responseType] 表示期望以那种格式(方式)接受响应数据。
      /// 目前 [ResponseType] 接受三种类型 `JSON`, `STREAM`, `PLAIN`.
      ///
      /// 默认值是 `JSON`, 当响应头中content-type为"application/json"时，dio 会自动将响应内容转化为json对象。
      /// 如果想以二进制方式接受响应数据，如下载一个二进制文件，那么可以使用 `STREAM`.
      ///
      /// 如果想以文本(字符串)格式接收响应数据，请使用 `PLAIN`.
      responseType: ResponseType.json,
    );

    dio = Dio(options);

    // 添加拦截器
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 在请求被发送之前做一些事情
        return handler.next(options); //continue
      },
      onResponse: (Response response, handler) {
        // 在返回响应数据之前做一些预处理
        return handler.next(response); // continue
      },
      onError: (DioError e, handler) {
        // 当请求失败时做一些预处理
        return handler.next(e);
      },
    ));
  }

  Future get({
    required String url,
    bool? isCityLocation = false,
    Map<String, dynamic>? params,
  }) async {
    try {
      String key = await box.get('key') != null ? box.get('key') : '';
      if (key.isEmpty) return;
      params?.addAll({'key': key});
      if (isCityLocation!) {
        String selLng = await box.get('select-city') != null
            ? box.get('select-city')['lng']
            : '0.0';
        String selLat = await box.get('select-city') != null
            ? box.get('select-city')['lat']
            : '0.0';
        String locationLng = await box.get('location') != null
            ? box.get('location')['lng']
            : '0.0';
        String locationLat = await box.get('location') != null
            ? box.get('location')['lat']
            : '0.0';
        double lng = double.parse(
            (selLng == '0.0' || selLng.isEmpty) ? locationLng : selLng);
        double lat = double.parse(
            (selLat == '0.0' || selLat.isEmpty) ? locationLat : selLat);

        params?.addAll({
          'location': '$lng,$lat',
        });
      }
      Response response = await dio.get(
        url,
        queryParameters: params,
      );
      return response.data;
    } catch (error) {
      throw Exception('Error making GET request: $error');
    }
  }
}
