import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';

class MarkdownViewScreen extends StatefulWidget {
  final String title;
  final String filePath;

  const MarkdownViewScreen({
    super.key,
    required this.title,
    required this.filePath,
  });

  @override
  State<MarkdownViewScreen> createState() => _MarkdownViewScreenState();
}

class _MarkdownViewScreenState extends State<MarkdownViewScreen> {
  String? _markdownData;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadMarkdownFile();
  }

  Future<void> _loadMarkdownFile() async {
    try {
      final String data = await rootBundle.loadString(widget.filePath);
      if (!mounted) return;
      setState(() {
        _markdownData = data;
        _hasError = false;
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading markdown file: $e');
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: HomeScreenTheme.backgroundColor(isDark),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: HomeScreenTheme.cardBackground(isDark),
        foregroundColor: HomeScreenTheme.primaryText(isDark),
        elevation: 0,
      ),
      body: _hasError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: HomeScreenTheme.primaryText(isDark)),
                  const SizedBox(height: 12),
                  Text('error_loading_content'.tr(),
                      style:
                          TextStyle(color: HomeScreenTheme.primaryText(isDark))),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _hasError = false);
                      _loadMarkdownFile();
                    },
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            )
          : _markdownData == null
          ? Center(
              child: CircularProgressIndicator(
                color: HomeScreenTheme.accentBlue(isDark),
              ),
            )
          : Markdown(
              data: _markdownData!,
              styleSheet: MarkdownStyleSheet(
                h1: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: HomeScreenTheme.primaryText(isDark),
                ),
                h2: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: HomeScreenTheme.primaryText(isDark),
                ),
                h3: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: HomeScreenTheme.primaryText(isDark),
                ),
                p: TextStyle(
                  fontSize: 16,
                  color: HomeScreenTheme.primaryText(isDark),
                ),
                listBullet: TextStyle(
                  color: HomeScreenTheme.primaryText(isDark),
                ),
              ),
              padding: const EdgeInsets.all(16),
            ),
    );
  }
}
