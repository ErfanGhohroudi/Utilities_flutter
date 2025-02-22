import 'dart:developer' as developer;

import 'package:u/utilities.dart';

Future<void> httpRequest({
  required final String url,
  required final EHttpMethod httpMethod,
  required final Function(Response<dynamic> response) action,
  required final Function(Response<dynamic> response) error,
  required final VoidCallback? retryCallback,
  final dynamic body,
  final bool encodeBody = true,
  final Map<String, String>? headers,
  final bool? withLoading,
  final Duration timeout = const Duration(seconds: 10),
  final Future<void> Function(Response<dynamic> response)? additionalActionAfterReceiveResponse,
  final DateTime? cacheExpireDate,
}) async {
  Response<dynamic> response = const Response<dynamic>();
  try {
    if (withLoading ?? true) {
      ULoading.showLoading();
    }

    final Map<String, String> header = <String, String>{
      "Authorization": ULocalStorage.getString(UConstants.token) ?? "",
    };

    if (headers != null) {
      // header.clear();
      header.addAll(headers);
    }

    dynamic params;
    if (body != null) {
      if (encodeBody) {
        params = body.toJson();
      } else {
        params = body;
      }
    }

    final GetConnect connect = GetConnect(timeout: timeout);

    if (httpMethod == EHttpMethod.get) {
      if (cacheExpireDate != null) {
        if (ULocalStorage.getString(url).isNullOrEmpty()) {
          response = await connect.get(url, headers: header);
          ULocalStorage.set(url, response.bodyString);
          ULocalStorage.set("${url}___ExpireDate", cacheExpireDate.toIso8601String());
        } else {
          if (DateTime.parse(ULocalStorage.getString("${url}___ExpireDate")!).isBefore(DateTime.now())) {
            ULocalStorage.set(url, null);
            ULocalStorage.set("${url}___ExpireDate", null);
            await httpRequest(
              url: url,
              httpMethod: EHttpMethod.get,
              action: action,
              error: error,
              retryCallback: retryCallback,
              headers: headers,
              timeout: timeout,
              cacheExpireDate: cacheExpireDate,
            );
          } else {
            action(Response<dynamic>(statusCode: 200, bodyString: ULocalStorage.getString(url)));
            return;
          }
        }
      } else {
        response = await connect.get(url, headers: header);
      }
    }
    if (httpMethod == EHttpMethod.post) response = await connect.post(url, params, headers: header);
    if (httpMethod == EHttpMethod.put) response = await connect.put(url, params, headers: header);
    if (httpMethod == EHttpMethod.patch) response = await connect.patch(url, params, headers: header);
    if (httpMethod == EHttpMethod.delete) response = await connect.delete(url, headers: header);

    if (kDebugMode) response.prettyLog(params: body == null ? "" : body.toJson());

    /// For when you want to call something for a response's message
    if (response.body != null && additionalActionAfterReceiveResponse != null) {
      additionalActionAfterReceiveResponse(response);
    }

    if (response.isOk) {
      action(response);
    } else {
      if (response.statusCode == 400 || response.statusCode == 200) {
        UNavigator.snackbarRed(title: "خطا", subtitle: response.body["message"].toString());
      }
      error(response);
    }
  } catch (e, stackTrace) {
    ULoading.dismissLoading();

    if (response.statusText?.toLowerCase().contains('timed out') ?? false) {
      if (retryCallback != null) {
        showRetryDialog(context: navigatorKey.currentContext!, retryCallback: retryCallback, isTimeOut: true, response: response);
      } else {
        error(response);
      }
    } else {
      if (retryCallback != null) {
        showRetryDialog(context: navigatorKey.currentContext!, retryCallback: retryCallback, response: response);
      } else {
        error(response);
      }

      // ثبت خطا در کنسول firebase
      if (response.statusCode == 500 || response.statusCode == 200) {
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'خطا در API',
        );
      }
    }
  }
  ULoading.dismissLoading();
}

enum EHttpMethod { get, post, put, patch, delete }

extension HTTP on Response<dynamic> {
  bool isSuccessful() => (statusCode ?? 0) >= 200 && (statusCode ?? 0) <= 299 ? true : false;

  bool isServerError() => (statusCode ?? 0) >= 500 && (statusCode ?? 0) <= 599 ? true : false;

  void prettyLog({final String params = ""}) {
    developer.log(
      "${request?.method} - ${request?.url} - $statusCode \nPARAMS: $params \nHEADERS: ${request?.headers} \nRESPONSE: $body",
    );
  }
}

void showRetryDialog({
  required BuildContext context,
  required VoidCallback retryCallback,
  bool? isTimeOut,
  bool? barrierDismissible,
  Response<dynamic>? response,
}) {
  String getTitleText({required Response<dynamic> response}) {
    String title = "";
    switch (response.statusCode) {
      case 400:
        title = "مشکل فنی پیش آمده";
        break;
      case 404:
        title = "اطلاعات یافت نشد";
        break;
      case 422:
        title = "مشکل در ارسال اطلاعات";
        break;
      case 500:
        title = "خطایی از سمت سرور رخ داده\nلطفا بعدا تلاش کنید";
        break;
      default:
        title = "لطفا وضعیت اینترنت خود را بررسی کنید";
        break;
    }
    return title;
  }

  if (!UCore.isDialogOpen) {
    UCore.isDialogOpen = true;

    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          title: Center(
            child: Column(
              children: [
                const UImage("lib/assets/files/error.lottie", size: 100),
                if (isTimeOut ?? false)
                  const Text(
                    "لطفا وضعیت اینترنت خود را بررسی کنید",
                    textAlign: TextAlign.center,
                  ).bodyLarge()
                else
                  Text(
                    getTitleText(response: response ?? const Response()),
                    textAlign: TextAlign.center,
                  ).bodyLarge()
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: UElevatedButton(
                width: 150,
                titleWidget: const Text("تلاش مجدد").bodyMedium(color: Colors.white),
                backgroundColor: Colors.red,
                onTap: () {
                  Navigator.of(context).pop(); // بسته شدن دیالوگ
                  UCore.isDialogOpen = false;
                  retryCallback(); // تلاش مجدد
                },
              ),
            ),
          ],
        ),
      ),
      useSafeArea: true,
      barrierDismissible: barrierDismissible ?? false,
    );
  }
}
