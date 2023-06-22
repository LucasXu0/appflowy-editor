import 'package:super_clipboard/super_clipboard.dart';

const formatInAppData = CustomValueFormat<String>(
  applicationId: 'com.appflowy.editor.inAppData',
);

class AppFlowyClipboardData {
  const AppFlowyClipboardData({
    required this.text,
    required this.html,
    this.inAppData,
  });

  final String? text;
  final String? html;
  final String? inAppData;
}

class AppFlowyClipboard {
  static Future<void> setData({
    String? text,
    String? html,
  }) async {
    final item = DataWriterItem();
    if (text != null) {
      item.add(Formats.plainText(text));
    }
    if (html != null) {
      item.add(Formats.htmlText(html));
    }
    await ClipboardWriter.instance.write([item]);
  }

  static Future<AppFlowyClipboardData> getData() async {
    final reader = await ClipboardReader.readClipboard();
    final text = reader.canProvide(Formats.plainText)
        ? await reader.readValue(Formats.plainText)
        : null;
    final html = reader.canProvide(Formats.htmlText)
        ? await reader.readValue(Formats.htmlText)
        : null;
    final inAppData = reader.canProvide(formatInAppData)
        ? await reader.readValue(formatInAppData)
        : null;
    return AppFlowyClipboardData(
      text: text,
      html: html,
      inAppData: inAppData,
    );
  }
}
