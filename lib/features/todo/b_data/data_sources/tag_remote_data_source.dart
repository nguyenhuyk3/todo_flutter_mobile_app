import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/tag_model.dart';

class TagRemoteDataSource {
  final SupabaseClient _supabaseClient;

  TagRemoteDataSource({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  Future<List<TagModel>> getTagsByUserId(String userId) async {
    final response = await _supabaseClient
        .from('tags')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: true);

    return (response as List)
        .map((e) => TagModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TagModel> updateTag({
    required String id,
    required String name,
    String? color,
  }) async {
    // Map chứa các field thực sự cần update lên database
    final Map<String, dynamic> updates = {};
    // Quy tắc nghiệp vụ:
    // - name không được rỗng
    // - nếu rỗng → thay bằng giá trị mặc định
    if (name.isNotEmpty) {
      updates['name'] = name;
    } else {
      updates['name'] = "Chưa đặt tên";
    }
    // Chỉ update color khi có giá trị truyền vào
    // Tránh ghi đè null lên DB ngoài ý muốn
    if (color != null) {
      updates['color'] = color;
    }

    updates['updated_at'] = DateTime.now();

    // Thực hiện UPDATE
    // .select().single() để:
    // - Supabase trả về row sau update
    // - Tránh phải query lần 2
    final response =
        await _supabaseClient
            .from('tags')
            .update(updates)
            .eq('id', id)
            .select()
            .single();
    // Map dữ liệu DB → domain model
    return TagModel.fromJson(response);
  }
}
