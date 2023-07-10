import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../models/pinterest_models.dart';

class Network {
  static const String URL = 'https://api.pexels.com/';
  static const String API_LIST =
      "/v1/curated"; // Ruta para obtener la lista de fotos
  static const String API_SEARCH_LIST = "/v1/search"; // Ruta para buscar fotos

  static const String API_KEY =
      ' pWss31hvmWHTNd6ltoDRVcwZXgaWjW2aJY82K1ENZIgiasf1C8MwAtBU'; // Reemplaza por tu clave de API de Pexels

  static Map<String, String> getHeaders() {
    Map<String, String> headers = {
      'Authorization': API_KEY,
    };
    return headers;
  }

  static List<Pinterest> parsePost(String responseBody) {
    final parsedJson = jsonDecode(responseBody);
    if (parsedJson['results'] is List<dynamic>) {
      return parsedJson['results']
          .map((model) => Pinterest.fromJson(model))
          .toList();
    } else {
      throw Exception('Invalid JSON structure');
    }
  }

  static Future<List<Pinterest>> GET(
      String api, Map<String, dynamic> params) async {
    var uri = Uri.parse(URL + api);
    uri = uri.replace(queryParameters: params);
    if (kDebugMode) {
      print('LOOK HERE: $uri');
    }
    final response = await http.get(uri, headers: getHeaders());

    if (response.statusCode == 200) {
      return compute(parsePost, response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Not Found');
    } else {
      throw Exception('Can\'t get post');
    }
  }

  static Map<String, dynamic> paramsGET(
      {int page = 1, String sortBy = 'popular'}) {
    Map<String, dynamic> params = {
      "page": page.toString(),
      'per_page': '20',
      'order_by': sortBy
    };
    return params;
  }

  static Map<String, dynamic> paramsSearch(
      {int page = 1, int per_page = 20, required String topic}) {
    Map<String, dynamic> params = {
      "page": page.toString(),
      'per_page': per_page.toString(),
      'query': topic
    };
    return params;
  }
}
