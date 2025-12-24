import '../../core/network/api_client.dart';
import 'category_model.dart';

class CategoriesRepository {
  CategoriesRepository(this.api);
  final ApiClient api;

  Future<List<Category>> list({required String type}) async {
    final res = await api.dio.get('/api/categories', queryParameters: {'type': type});
    final data = (res.data as List).cast<Map<String, dynamic>>();
    return data.map(Category.fromJson).toList();
  }
}
