// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'dart:convert';

class QuillEditor extends StatefulWidget {
  const QuillEditor(
      {super.key,
      this.width,
      this.height,
      this.onMessageReceived,
      this.realOnly = false,
      this.htmlString});

  final double? width;
  final double? height;
  final Future Function(String? message)? onMessageReceived;
  final bool? realOnly;
  final String? htmlString;

  @override
  State<QuillEditor> createState() => _QuillEditorState();
}

class _QuillEditorState extends State<QuillEditor> {
  html.IFrameElement? _iframe;
  static int _viewIdCounter = 0;
  late int _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = ++_viewIdCounter;
    _registerViewFactory();
  }

  void _registerViewFactory() {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('inline-html-$_viewId',
        (int viewId) {
      _iframe = html.IFrameElement()
        ..src = '/test_quill.html'
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%';

      // Listen for messages from the iframe
      html.window.addEventListener('message', (event) {
        final messageEvent = event as html.MessageEvent;

        // Only process messages from the iframe
        if (messageEvent.data != null) {
          try {
            final data = jsonDecode(messageEvent.data);

            widget.onMessageReceived?.call(data["html"]);
          } catch (e) {
            // If not JSON, treat as plain string
            widget.onMessageReceived?.call(messageEvent.data);
          }
        }
      });

      return _iframe!;
    });
  }

  void sendMessageToIframe(String message) {
    _iframe?.contentWindow?.postMessage(message, '*');
  }

  void sendJsonToIframe(Map<String, dynamic> data) {
    data['source'] = 'flutter';
    data['type'] = 'command';
    final jsonString = jsonEncode(data);
    _iframe?.contentWindow?.postMessage(jsonString, '*');
  }

  void insertText(String text) {
    sendJsonToIframe({
      'action': 'insertText',
      'text': text,
    });
  }

  @override
  Widget build(BuildContext context) {
    print('widget.realOnly: ${widget.realOnly}');
    if (widget.realOnly == true) {
      return ViewOnlyQuillEditor(message: widget.htmlString ?? '');
    } else {
      return HtmlElementView(viewType: 'inline-html-$_viewId');
    }
  }
}

class ViewOnlyQuillEditor extends StatefulWidget {
  const ViewOnlyQuillEditor({super.key, required this.message});
  final String message;

  @override
  State<ViewOnlyQuillEditor> createState() => _ViewOnlyQuillEditorState();
}

class _ViewOnlyQuillEditorState extends State<ViewOnlyQuillEditor> {
  html.IFrameElement? _iframe;
  static int _viewIdCounter = 0;
  late int _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = ++_viewIdCounter;
    _registerViewFactory();
  }

  void _registerViewFactory() {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('viewOnly-html-$_viewId',
        (int viewId) {
      _iframe = html.IFrameElement()
        ..src = '/delta_renderer.html'
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%';

      // Listen for messages from the iframe
      // html.window.addEventListener('message', (event) {
      //   final messageEvent = event as html.MessageEvent;
      //   print('${messageEvent.source == _iframe?.contentWindow}');
      //   // Only process messages from the iframe
      //   if (messageEvent.data != null) {
      //     print('messageEvent.data: ${messageEvent.data}');
      //     try {
      //       final data = jsonDecode(messageEvent.data);
      //       widget.onMessageReceived?.call(data);
      //     } catch (e) {
      //       // If not JSON, treat as plain string
      //       widget.onMessageReceived?.call(messageEvent.data);
      //     }
      //   }
      // });

      return _iframe!;
    });
  }

  void sendMessageToIframe(String message) {
    _iframe?.contentWindow?.postMessage(message, '*');
  }

  void sendJsonToIframe(Map<String, dynamic> data) {
    data['source'] = 'flutter';
    data['type'] = 'command';
    final jsonString = jsonEncode(data);
    _iframe?.contentWindow?.postMessage(jsonString, '*');
  }

  @override
  Widget build(BuildContext context) {
    sendMessageToIframe(widget.message);
    return HtmlElementView(viewType: 'viewOnly-html-$_viewId');
  }
}
