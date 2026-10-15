import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';
import 'package:flutter_gemma_mediapipe/flutter_gemma_mediapipe.dart';

import '../models/llm_model.dart';

/// Registers the inference engines (flutter_gemma 1.0+ makes them opt-in).
/// .task files use MediaPipeEngine, .litertlm files use LiteRtLmEngine.
Future<void> initGemma({String? token}) => FlutterGemma.initialize(
      huggingFaceToken: token,
      inferenceEngines: const [LiteRtLmEngine(), MediaPipeEngine()],
    );

/// Wraps flutter_gemma. All plugin calls live here, so if the package API
/// changes between versions, this is the only file you edit.
class GemmaService {
  InferenceModel? _model;
  InferenceChat? _chat;

  ModelType _type(Family f) => switch (f) {
        Family.gemma => ModelType.gemmaIt,
        Family.qwen => ModelType.qwen,
        Family.llama => ModelType.llama,
      };

  Future<bool> isInstalled(LlmModel m) => FlutterGemma.isModelInstalled(m.fileName);

  /// Downloads the model if missing and makes it the active one.
  /// Calling it for an already-installed model skips the download.
  Future<void> install(LlmModel m, String token, void Function(int percent) onProgress) async {
    final t = token.trim();
    if (t.isNotEmpty) {
      try {
        await initGemma(token: t);
      } catch (_) {} // already initialized: the per-download token below still applies
    }
    await FlutterGemma.installModel(modelType: _type(m.family))
        .fromNetwork(m.url, token: t.isEmpty ? null : t)
        .withProgress(onProgress)
        .install();
  }

  Future<void> load() async {
    await _model?.close();
    _model = null;
    _chat = null;
    _model = await FlutterGemma.getActiveModel(
      maxTokens: 2048,
      preferredBackend: PreferredBackend.gpu,
    );
    _chat = await _model!.createChat();
  }

  Stream<String> reply(String prompt) async* {
    await _chat!.addQueryChunk(Message.text(text: prompt, isUser: true));
    await for (final r in _chat!.generateChatResponseAsync()) {
      if (r is TextResponse) yield r.token;
    }
  }

  Future<void> stop() async => _chat?.stopGeneration();

  Future<void> resetChat() async => _chat = await _model?.createChat();

  Future<void> close() async => _model?.close();
}
