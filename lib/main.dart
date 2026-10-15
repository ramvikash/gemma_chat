import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'data/gemma_service.dart';
import 'data/model_store.dart';
import 'viewmodels/chat_viewmodel.dart';
import 'views/chat_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterGemma.initialize();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ChatViewModel(GemmaService(), ModelStore())..start(),
      child: MaterialApp(
        title: 'Gemma Chat',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        home: const ChatScreen(),
      ),
    ),
  );
}
