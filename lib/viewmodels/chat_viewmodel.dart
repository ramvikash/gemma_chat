import 'dart:async';
import 'package:flutter/foundation.dart';

import '../data/gemma_service.dart';
import '../data/model_store.dart';
import '../models/chat_message.dart';
import '../models/llm_model.dart';

enum AppStatus { setup, loading, ready }

class ChatViewModel extends ChangeNotifier {
  ChatViewModel(this._service, this._store);
  final GemmaService _service;
  final ModelStore _store;

  final List<ChatMessage> messages = [];
  List<LlmModel> models = [...catalog];
  final Set<String> installed = {};
  LlmModel? active;
  AppStatus status = AppStatus.setup;
  String token = '';
  String? downloadingId;
  int progress = 0;
  String? error;
  bool generating = false;
  StreamSubscription<String>? _sub;

  Future<void> start() async {
    models = [...catalog, ...await _store.loadCustom()];
    for (final m in models) {
      if (await _service.isInstalled(m)) installed.add(m.id);
    }
    final lastId = await _store.lastActive();
    final last = models.where((m) => m.id == lastId && installed.contains(m.id)).firstOrNull;
    if (last != null) {
      await select(last);
    } else {
      notifyListeners();
    }
  }

  Future<void> download(LlmModel m) async {
    if (downloadingId != null) return;
    downloadingId = m.id;
    progress = 0;
    error = null;
    notifyListeners();
    try {
      await _service.install(m, token.trim(), (p) {
        progress = p;
        notifyListeners();
      });
      installed.add(m.id);
      downloadingId = null;
      await select(m);
    } catch (e) {
      downloadingId = null;
      error = 'Download failed: $e';
      notifyListeners();
    }
  }

  /// Switch to an installed model. Starts a fresh chat.
  Future<void> select(LlmModel m) async {
    await stop();
    messages.clear();
    active = m;
    status = AppStatus.loading;
    error = null;
    notifyListeners();
    try {
      await _service.install(m, token.trim(), (_) {}); // already on disk: activates only
      await _service.load();
      await _store.saveActive(m.id);
      status = AppStatus.ready;
    } catch (e) {
      active = null;
      status = AppStatus.setup;
      error = 'Could not load ${m.name}: $e';
    }
    notifyListeners();
  }

  Future<void> addCustom(String name, String url, Family family) async {
    final m = LlmModel(
      id: 'custom-${url.hashCode}',
      name: name.isEmpty ? url.split('/').last : name,
      url: url.trim(),
      size: 'custom',
      family: family,
      custom: true,
    );
    models = [...models, m];
    await _store.saveCustom(models.where((x) => x.custom).toList());
    notifyListeners();
  }

  void send(String text) {
    final prompt = text.trim();
    if (prompt.isEmpty || generating || status != AppStatus.ready) return;
    final reply = ChatMessage(Role.assistant, '');
    messages..add(ChatMessage(Role.user, prompt))..add(reply);
    generating = true;
    notifyListeners();
    _sub = _service.reply(prompt).listen(
      (t) {
        reply.text += t;
        notifyListeners();
      },
      onError: (Object e) {
        reply.text = 'Generation failed: $e';
        generating = false;
        notifyListeners();
      },
      onDone: () {
        generating = false;
        notifyListeners();
      },
    );
  }

  Future<void> stop() async {
    if (!generating) return;
    await _service.stop();
    await _sub?.cancel();
    generating = false;
    notifyListeners();
  }

  Future<void> newChat() async {
    await stop();
    messages.clear();
    await _service.resetChat();
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _service.close();
    super.dispose();
  }
}
