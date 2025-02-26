import 'package:dio/dio.dart';

import 'dart:io';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message ${statusCode ?? ''}';
}

// class ApiResponse<T> {
//   final List<ProductModel>? data;
//   final String? error;
//   final bool isSuccess;

//   ApiResponse({
//     this.data,
//     this.error,
//     this.isSuccess = false,
//   });

//   // Helper method to check if the response has data
//   bool get hasData => data != null && data!.isNotEmpty;
// }

class ApiService {
  static const String _priceCheckerUrl =
      'https://apis.datcarts.com/price-checker';

  final Dio _dio;

  ApiService() : _dio = Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 5);
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  // Future<ApiResponse<List<ProductModel>>> getProductByBarcode(
  //     String barcode, String url) async {
  //   try {
  //     final response = await _dio.get('$url$barcode');
  //     print('RESPONSECODE:${response.statusCode}');

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = response.data;
  //       print(data);
  //       if (data.isEmpty) {
  //         return ApiResponse(
  //           error: 'No products found with this barcode',
  //           isSuccess: false,
  //           data: [],
  //         );
  //       }

  //       final products =
  //           data.map((json) => ProductModel.fromJson(json)).toList();
  //       return ApiResponse(
  //         data: products,
  //         isSuccess: true,
  //       );
  //     } else {
  //       print('RESPONSECODE:${response.statusCode}');
  //       return ApiResponse(
  //         error: 'Failed to fetch products. Status: ${response.statusCode}',
  //         isSuccess: false,
  //         data: [],
  //       );
  //     }
  //   } catch (e) {
  //     String errorMessage;
  //     if (e is DioException) {
  //       print('Dio Error: ${e.message}');
  //       switch (e.type) {
  //         case DioExceptionType.connectionTimeout:
  //           errorMessage = 'Connection timeout';
  //           break;
  //         case DioExceptionType.receiveTimeout:
  //           errorMessage = 'Server not responding';
  //           break;
  //         case DioExceptionType.connectionError:
  //           errorMessage = 'No internet connection.';
  //           break;
  //         default:
  //           errorMessage = 'Invalid QRcode or barcode';
  //       }
  //     } else {
  //       print('Unexpected error: $e');
  //       errorMessage = 'An unexpected error occurred.';
  //     }
  //     return ApiResponse(
  //       error: errorMessage,
  //       isSuccess: false,
  //       data: [],
  //     );
  //   }
  // }

  Future<bool> sendPriceExtractionData({
    required File imageFile,
    required String price,
    required bool isCorrect,
    required String algorithm,
  }) async {
    try {
      print('before storing');
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path),
        'price': price,
        'isCorrect': isCorrect.toString(),
        'algorithm': algorithm,
      });
      print(formData.fields);

      final response = await _dio.post(
        _priceCheckerUrl,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(response.statusMessage);
        return true;
      } else {
        print(response.statusMessage);
      }

      throw ApiException('Upload failed', response.statusCode);
    } on DioException catch (e) {
      throw ApiException('Network error: ${e.message}', e.response?.statusCode);
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }
}
