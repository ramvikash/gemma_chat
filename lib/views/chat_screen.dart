import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import '../models/chat_message.dart';
import '../viewmodels/chat_viewmodel.dart';
import 'models_panel.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  void _openModels(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .85),
            child: const ModelsPanel(),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openModels(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Flexible(
                child: Text(vm.active?.name ?? 'Choose a model', overflow: TextOverflow.ellipsis),
              ),
              const Icon(Icons.expand_more),
            ]),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'New chat',
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: vm.status == AppStatus.ready ? vm.newChat : null,
          ),
        ],
      ),
      body: SafeArea(
        child: switch (vm.status) {
          AppStatus.ready => const _ChatBody(),
          AppStatus.loading => const Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading model…'),
              ]),
            ),
          AppStatus.setup => const ModelsPanel(),
        },
      ),
    );
  }
}

class _ChatBody extends StatefulWidget {
  const _ChatBody();
  @override
  State<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<_ChatBody> {
  final _scroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();
    final cs = Theme.of(context).colorScheme;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
    return Column(children: [
      Expanded(
        child: vm.messages.isEmpty
            ? Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.auto_awesome, size: 36, color: cs.primary),
                  const SizedBox(height: 12),
                  Text('How can I help you today?',
                      style: TextStyle(
                          fontFamily: 'serif', fontSize: 30, color: cs.onSurface)),
                ]),
              )
            : ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                itemCount: vm.messages.length,
                itemBuilder: (_, i) => _Bubble(
                  m: vm.messages[i],
                  waiting: vm.generating && i == vm.messages.length - 1,
                ),
              ),
      ),
      _Composer(vm: vm),
    ]);
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.m, required this.waiting});
  final ChatMessage m;
  final bool waiting;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (m.role == Role.user) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .82),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(m.text, style: const TextStyle(fontSize: 16, height: 1.4)),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.auto_awesome, size: 18, color: cs.primary),
        const SizedBox(height: 6),
        if (m.text.isEmpty && waiting)
          Text('Thinking…', style: TextStyle(color: cs.onSurface.withOpacity(.5)))
        else
          MarkdownBody(
            data: m.text,
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(fontSize: 16, height: 1.55, color: cs.onSurface),
              code: TextStyle(backgroundColor: cs.surfaceContainerHighest),
              codeblockDecoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ]),
    );
  }
}

class _Composer extends StatefulWidget {
  const _Composer({required this.vm});
  final ChatViewModel vm;
  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  final _c = TextEditingController();

  void _submit() {
    widget.vm.send(_c.text);
    _c.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final busy = widget.vm.generating;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
          child: TextField(
            controller: _c,
            minLines: 1,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Message',
              border: InputBorder.none,
            ),
          ),
        ),
        IconButton.filled(
          style: IconButton.styleFrom(backgroundColor: cs.primary),
          tooltip: busy ? 'Stop' : 'Send',
          icon: Icon(busy ? Icons.stop_rounded : Icons.arrow_upward_rounded),
          onPressed: busy ? widget.vm.stop : _submit,
        ),
      ]),
    );
  }
}
