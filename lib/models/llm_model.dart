enum Family { gemma, qwen, llama }

class LlmModel {
  const LlmModel({
    required this.id,
    required this.name,
    required this.url,
    required this.size,
    this.family = Family.gemma,
    this.custom = false,
  });

  final String id, name, url, size;
  final Family family;
  final bool custom;

  String get fileName => url.split('?').first.split('/').last;

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'url': url, 'size': size, 'family': family.name};

  factory LlmModel.fromJson(Map<String, dynamic> j) => LlmModel(
        id: j['id'],
        name: j['name'],
        url: j['url'],
        size: j['size'],
        family: Family.values.byName(j['family']),
        custom: true,
      );
}

/// Built-in list. Verify each URL on Hugging Face: repos get renamed and moved.
const catalog = <LlmModel>[
  LlmModel(
    id: 'gemma3n-e2b',
    name: 'Gemma 3n E2B',
    size: '3.1 GB',
    url: 'https://huggingface.co/google/gemma-3n-E2B-it-litert-preview/resolve/main/gemma-3n-E2B-it-int4.task',
  ),
  LlmModel(
    id: 'gemma3n-e4b',
    name: 'Gemma 3n E4B',
    size: '4.4 GB',
    url: 'https://huggingface.co/google/gemma-3n-E4B-it-litert-preview/resolve/main/gemma-3n-E4B-it-int4.task',
  ),
  LlmModel(
    id: 'gemma3-1b',
    name: 'Gemma 3 1B',
    size: '0.6 GB',
    url: 'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/gemma3-1b-it-int4.task',
  ),
  LlmModel(
    id: 'qwen25-05b',
    name: 'Qwen 2.5 0.5B',
    size: '0.5 GB',
    family: Family.qwen,
    url: 'https://huggingface.co/litert-community/Qwen2.5-0.5B-Instruct/resolve/main/Qwen2.5-0.5B-Instruct_multi-prefill-seq_q8_ekv1280.task',
  ),
];
