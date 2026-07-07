import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

export '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService('https://chess-tournament-backend-uwph.onrender.com/api');
});
