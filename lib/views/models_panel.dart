import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/llm_model.dart';
import '../viewmodels/chat_viewmodel.dart';

/// Model manager: download, switch, and add models. Shown as the home
/// screen before a model is loaded, and as a bottom sheet afterwards.
class ModelsPanel extends StatelessWidget {
  const ModelsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();
    final cs = Theme.of(context).colorScheme;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        Text('Models',
            style: TextStyle(fontFamily: 'serif', fontSize: 28, color: cs.onSurface)),
        const SizedBox(height: 6),
        Text(
          'Models download once and run on this device. Gemma models need a '
          'Hugging Face read token from an account that accepted the license.',
          style: TextStyle(color: cs.onSurface.withOpacity(.7)),
        ),
        const SizedBox(height: 12),
        TextField(
          obscureText: true,
          onChanged: (v) => vm.token = v,
          decoration: InputDecoration(
            hintText: 'Hugging Face token',
            filled: true,
            fillColor: cs.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
          ),
        ),
        if (vm.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(vm.error!, style: TextStyle(color: cs.error), maxLines: 5),
          ),
        const SizedBox(height: 8),
        for (final m in vm.models) _ModelRow(m: m),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add model by URL'),
            onPressed: () => _addDialog(context, vm),
          ),
        ),
      ],
    );
  }

  Future<void> _addDialog(BuildContext context, ChatViewModel vm) {
    final name = TextEditingController(), url = TextEditingController();
    var family = Family.gemma;
    return showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: const Text('Add model'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(
              controller: url,
              decoration: const InputDecoration(labelText: 'Direct link to .task or .litertlm'),
            ),
            const SizedBox(height: 12),
            DropdownButton<Family>(
              value: family,
              isExpanded: true,
              items: [for (final f in Family.values) DropdownMenuItem(value: f, child: Text(f.name))],
              onChanged: (f) => set(() => family = f!),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (url.text.trim().isNotEmpty) vm.addCustom(name.text.trim(), url.text, family);
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelRow extends StatelessWidget {
  const _ModelRow({required this.m});
  final LlmModel m;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();
    final cs = Theme.of(context).colorScheme;
    final isActive = vm.active?.id == m.id;
    final downloading = vm.downloadingId == m.id;
    final installed = vm.installed.contains(m.id);

    Widget? trailing;
    if (isActive) {
      trailing = Icon(Icons.check_circle, color: cs.primary);
    } else if (installed) {
      trailing = TextButton(
        child: const Text('Use'),
        onPressed: () {
          vm.select(m);
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
      );
    } else if (!downloading) {
      trailing = TextButton(
        child: const Text('Download'),
        onPressed: vm.downloadingId == null ? () => vm.download(m) : null,
      );
    }
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(m.name),
      subtitle: downloading
          ? Padding(
              padding: const EdgeInsets.only(top: 6),
              child: LinearProgressIndicator(value: vm.progress / 100),
            )
          : Text('${m.size}, ${m.family.name}'),
      trailing: trailing,
    );
  }
}
