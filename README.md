# Gemma Chat (Flutter, MVVM, multi-model)

Build the APK
- Locally (Flutter stable + Android SDK installed): `bash tool/setup_android.sh && flutter build apk --release --split-per-abi`
  APKs land in build/app/outputs/flutter-apk/. Install app-arm64-v8a-release.apk on most phones.
- In the cloud: push this folder to a GitHub repo (branch main). Actions > Build APK > download the "gemma-chat-apk" artifact.

Use
- Tap the model name in the top bar to download, switch, or add models (direct .task / .litertlm links).
- Gemma models need a Hugging Face read token after accepting the license on each model page.

Structure
- models/      ChatMessage, LlmModel + catalog
- data/        GemmaService (only file touching flutter_gemma), ModelStore (saved choices)
- viewmodels/  ChatViewModel (state + logic)
- views/       ChatScreen, ModelsPanel (UI only)
- core/        theme
