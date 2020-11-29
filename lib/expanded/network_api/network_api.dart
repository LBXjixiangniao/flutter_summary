import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_summary/dart_class/mixin/dispose_notifier.dart';
import '../../dart_class/abstract/listenable_dispose.dart';
import 'package:flutter_summary/util/util.dart';

const String IsUseToken = 'isUseToken';
bool defaultCheckCode(dynamic code) {
  return code is int && code >= 0;
}

const List<String> DefaultResponseDataPath = ['data'];

class NetworkResponse<R> {
  R data;
  Response response;
  NetworkResponse({this.data, this.response});
}

class CustomCanceltoken extends CancelToken {
  final DisposeNotifier disposeNotifier;
  VoidCallback _disposeListener;
  CustomCanceltoken({this.disposeNotifier}) {
    if (disposeNotifier != null) {
      _disposeListener = () {
        super.cancel();
      };
      disposeNotifier.addDisposeListener(_disposeListener);
    }
  }

  bool _isCompleted = false;
  bool get isCompleted => _isCompleted || isCancelled;

  void _close() {
    _isCompleted = true;
    disposeNotifier?.removeDisposeListener(_disposeListener);
  }

  @override
  void cancel([reason]) {
    if(_disposeListener != null && disposeNotifier != null) {
      disposeNotifier.removeDisposeListener(_disposeListener);
    }
    super.cancel(reason);
  }
}

class CustomInterceptor extends Interceptor {
  @override
  Future onError(DioError err) {
    return super.onError(err);
  }

  @override
  Future onRequest(RequestOptions options) {
    Map<String, dynamic> extraMap = options.extra;

    ///判断是否要是使用token
    // if (extraMap[IsUseToken] == true) {
    //   options.headers.addAll({'token': UserInfo.token ?? ''});
    // }

    return super.onRequest(options);
  }

  @override
  Future onResponse(Response response) {
    return super.onResponse(response);
  }
}

class NetworkDio {
  static int receiveTimeout = 5000;
  static int connectTimeout = 10000;
  static int sendTimeout = 5000;

  Dio _dio = Dio(BaseOptions())
    ..options.receiveTimeout = receiveTimeout
    ..options.connectTimeout = connectTimeout
    ..options.sendTimeout = sendTimeout
    // ..options.baseUrl = BASE_URL
    ..interceptors.addAll([
      // PrettyDioLogger(),
      CustomInterceptor(),
    ]);

  static NetworkDio shareInstance = NetworkDio._();

  NetworkDio._();

  static Dio get shareDio {
    return shareInstance._dio;
  }

  ///测试设置抓包用的
  static setProxyToDio(String proxy) {
    DefaultHttpClientAdapter clientAdapter = DefaultHttpClientAdapter()
      ..onHttpClientCreate = (client) {
        client.findProxy = (uri) {
          //proxy all request to localhost:8888
          return "PROXY $proxy";
        };
      };

    shareInstance._dio.httpClientAdapter = clientAdapter;
  }

  static Future<NetworkResponse<R>> post<R, M>({
    @required String url,
    M modelFromJson(Map<String, dynamic> json),
    dynamic body,
    List<String> pathForData = DefaultResponseDataPath,
    bool isUseToken = true, //默认使用token
    bool Function(dynamic) checkRespondCode = defaultCheckCode, //默认 检查返回数据中的code字段，
    CustomCanceltoken cancelToken,
  }) {
    return _request<R, M>(
      method: 'POST',
      modelFromJson: modelFromJson,
      url: url,
      body: body,
      requiredDataPath: pathForData,
      isUseToken: isUseToken,
      checkRespondCode: checkRespondCode,
      cancelToken: cancelToken,
    );
  }

  static Future<NetworkResponse<R>> get<R, M>({
    @required String url,
    M modelFromJson(Map<String, dynamic> json),
    dynamic body,
    List<String> pathForData = DefaultResponseDataPath,
    bool isUseToken = true, //默认使用token
    bool Function(dynamic) checkRespondCode = defaultCheckCode, //默认 检查返回数据中的code字段是否是10000，
    CustomCanceltoken cancelToken,
  }) {
    return _request<R, M>(
      method: 'GET',
      modelFromJson: modelFromJson,
      url: url,
      body: body,
      requiredDataPath: pathForData,
      isUseToken: isUseToken,
      checkRespondCode: checkRespondCode,
      cancelToken: cancelToken,
    );
  }

  static Future<NetworkResponse<R>> _request<R, M>({
    M modelFromJson(Map<String, dynamic> json),
    @required String url,
    @required String method,
    dynamic body,
    List<String> requiredDataPath,
    bool isUseToken = true, //默认使用token
    bool Function(dynamic) checkRespondCode = defaultCheckCode, //默认 检查返回数据中的code字段是否是10000，
    CustomCanceltoken cancelToken, //控制删除网络请求的
  }) {
    assert(method != null);
    assert(url != null);
    assert(R == M || List<M>() is R);
    Map<String, dynamic> extraMap = {};
    if (isUseToken != null) {
      extraMap[IsUseToken] = isUseToken;
    }
    RequestOptions requestOptions = RequestOptions(method: method, extra: extraMap);
// DioMixin
    return shareDio
        .request(
      url,
      data: method == 'POST' ? body : null,
      options: requestOptions,
      cancelToken: cancelToken,
      queryParameters: method == 'GET' ? body : null,
    )
        .whenComplete(() {
      cancelToken?._close();
    }).then((response) async {
      DioError responseError() {
        return DioError(
          request: response.request,
          response: response,
          type: DioErrorType.RESPONSE,
          error: Util.mapValueForPath(
            response.data,
            ['msg'],
          ),
        );
      }

      ///判断code是否正确
      if (checkRespondCode != null && !checkRespondCode(Util.mapValueForPath(response.data, ['code']))) {
        throw responseError();
      }

      ///判断是否有指定数据返回
      if (requiredDataPath is List<String> && Util.mapValueForPath(response.data, requiredDataPath) == null) {
        throw responseError();
      }

      ///处理数据
      dynamic requiredData = requiredDataPath is List<String> ? Util.mapValueForPath(response.data, requiredDataPath) : response.data;

      ///加M == R是为了防止R是dynamic的时候List<M>() is R恒为true
      bool requiredDataIsList = M == R ? false : List<M>() is R;
      if (requiredData == null || (requiredDataIsList != requiredData is List)) {
        throw responseError();
      }

      dynamic resultData;
      if (modelFromJson != null && M != dynamic) {
        if (requiredDataIsList) {
          resultData = List<M>.from((requiredData as List).map((f) => modelFromJson(f)));
        } else {
          resultData = modelFromJson(requiredData);
        }
      } else {
        resultData = requiredData;
      }
      return NetworkResponse<R>(data: resultData, response: response);
    });
  }
}
