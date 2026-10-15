import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/llm_model.dart';

/// Remembers user-added models and the last model in use.
class ModelStore {
  Future<List<LlmModel>> loadCustom() async {
    final raw = (await SharedPreferences.getInstance()).getString('custom_models');
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => LlmModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCustom(List<LlmModel> list) async =>
      (await SharedPreferences.getInstance())
          .setString('custom_models', jsonEncode(list.map((m) => m.toJson()).toList()));

  Future<String?> lastActive() async =>
      (await SharedPreferences.getInstance()).getString('active_model');

  Future<void> saveActive(String id) async =>
      (await SharedPreferences.getInstance()).setString('active_model', id);
}
