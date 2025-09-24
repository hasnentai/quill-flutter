# Quill Better Table with FlutterFlow - Complete Implementation Guide

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Step 1: Custom Widget Setup](#step-1-custom-widget-setup)
4. [Step 2: Web Files Setup](#step-2-web-files-setup)
5. [Step 3: Implementation in FlutterFlow](#step-3-implementation-in-flutterflow)
6. [Communication Between Flutter and iframe](#communication-between-flutter-and-iframe)
7. [Code Examples](#code-examples)
8. [Troubleshooting](#troubleshooting)
9. [Advanced Features](#advanced-features)

## Overview

This guide shows you how to integrate **quill-better-table** with FlutterFlow using a custom widget that embeds a web-based Quill editor with advanced table functionality. The implementation uses iframe communication to enable real-time data exchange between Flutter and the web editor.

## Prerequisites

- FlutterFlow project
- Basic understanding of Flutter custom widgets
- Web development knowledge (HTML, CSS, JavaScript)

## Step 1: Custom Widget Setup

### Create the QuillEditor Custom Widget

In your FlutterFlow project, create a custom widget in the `custom_code/widgets/` folder:

**File: `lib/custom_code/widgets/quill_editor.dart`**

```dart
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
```

## Step 2: Web Files Setup

### File 1: Editor HTML (`web/test_quill.html`)

Create this file in your `web/` folder:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quill Editor Test - Table Support</title>
    
    <!-- Quill.js CSS -->
    <link href="https://cdn.jsdelivr.net/npm/quill@2/dist/quill.snow.css" rel="stylesheet">
    
    <!-- Quill Better Table CSS -->
    <link href="https://cdn.jsdelivr.net/npm/quill-table-better@1/dist/quill-table-better.css" rel="stylesheet">
    
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0px;
            background-color: transparent;
        }
       
        .ql-container.ql-snow{
          height: 400px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            text-align: center;
        }
        
        .header h1 {
            margin: 0;
            font-size: 2em;
        }
        
        .header p {
            margin: 10px 0 0 0;
            opacity: 0.9;
        }
        
        .toolbar-custom {
            background: #f8f9fa;
            border-bottom: 1px solid #e9ecef;
            padding: 10px 20px;
            display: flex;
            gap: 10px;
            align-items: center;
        }
        
        .btn {
            background: #007bff;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.2s;
        }
        
        .btn:hover {
            background: #0056b3;
        }
        
        .btn.secondary {
            background: #6c757d;
        }
        
        .btn.secondary:hover {
            background: #545b62;
        }
        
        .btn.success {
            background: #28a745;
        }
        
        .btn.success:hover {
            background: #1e7e34;
        }
        
        .editor-container {
            padding: 20px;
            min-height: 400px;
        }
        
        .content-preview {
            margin-top: 20px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 4px;
            border-left: 4px solid #007bff;
        }
        
        .content-preview h3 {
            margin-top: 0;
            color: #495057;
        }
        
        .content-preview pre {
            background: white;
            padding: 15px;
            border-radius: 4px;
            border: 1px solid #dee2e6;
            overflow-x: auto;
            white-space: pre-wrap;
            word-wrap: break-word;
        }
        
        .stats {
            display: flex;
            gap: 20px;
            margin-top: 10px;
            font-size: 14px;
            color: #6c757d;
        }
        
        .feature-list {
            background: #e3f2fd;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        
        .feature-list h4 {
            margin-top: 0;
            color: #1976d2;
        }
        
        .feature-list ul {
            margin: 10px 0;
            padding-left: 20px;
        }
        
        .feature-list li {
            margin: 5px 0;
        }
        
        .table-demo {
            background: #fff3cd;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
            border-left: 4px solid #ffc107;
        }
        
        .table-demo h4 {
            margin-top: 0;
            color: #856404;
        }
    </style>
</head>
<body>
    <div id="root"></div>
    <br/>
 
    <script src="https://cdn.jsdelivr.net/npm/quill@2/dist/quill.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/quill-table-better@1/dist/quill-table-better.js"></script>

    <script>
        Quill.register({
  'modules/table-better': QuillTableBetter
}, true);

const toolbarOptions = [
  ['bold', 'italic', 'underline', 'strike'],        // toggled buttons
  ['blockquote', 'code-block'],
  ['link', 'image', 'video', 'formula'],

  [{ 'header': 1 }, { 'header': 2 }],               // custom button values
  [{ 'list': 'ordered'}, { 'list': 'bullet' }, { 'list': 'check' }],
  [{ 'script': 'sub'}, { 'script': 'super' }],      // superscript/subscript
  [{ 'indent': '-1'}, { 'indent': '+1' }],          // outdent/indent
  [{ 'direction': 'rtl' }],                         // text direction

  [{ 'size': ['small', false, 'large', 'huge'] }],  // custom dropdown
  [{ 'header': [1, 2, 3, 4, 5, 6, false] }],

  [{ 'color': [] }, { 'background': [] }],          // dropdown with defaults from theme
  [{ 'font': [] }],
  [{ 'align': [] }],

  ['clean'],                                        // remove formatting button
  ['table-better']
];

const options = {
  theme: 'snow',
  modules: {
    toolbar: toolbarOptions,
    table: false,
    'table-better': {
      toolbarTable: true,
      menus: ['column', 'row', 'merge', 'table', 'cell', 'wrap', 'copy', 'delete'],
    },
    keyboard: {
      bindings: QuillTableBetter.keyboardBindings
    }
  }
};

const editor = new Quill('#root', options);

let delta = null;
let html = '';
let messageId = 0;
let lastMessageTime = 0;
const MESSAGE_THROTTLE = 100; // milliseconds

// Function to send message to Flutter
function sendMessageToFlutter(message) {
  
  if (window.parent) {
    window.parent.postMessage(message, '*');
  }
}

// Function to send JSON data to Flutter
function sendJsonToFlutter(data) {
  // Throttle messages to prevent spam

  const now = Date.now();
  if (now - lastMessageTime < MESSAGE_THROTTLE) {
    return;
  }
  lastMessageTime = now;
  
  // Add unique ID to prevent loops
  data.messageId = ++messageId;
  data.source = 'iframe';
  sendMessageToFlutter(JSON.stringify(data));
}

// Listen for messages from Flutter
window.addEventListener('message', function(event) {
  // Only process messages from the parent window (Flutter)
  if (event.source !== window.parent) {
    return;
  }
  
  try {
    const data = JSON.parse(event.data);
    // Only handle command messages, not response messages
    if (data.type === 'command') {
      handleFlutterCommand(data);
    }
  } catch (e) {
    // Handle plain string messages
    
    sendMessageToFlutter('Echo: ' + event.data);
  }
});

// Handle commands from Flutter
function handleFlutterCommand(data) {
 
  
  // Prevent processing the same command multiple times
  if (data._processed) {
    return;
  }
  data._processed = true;
  
  switch (data.action) {
    case 'insertTable':
      const rows = data.rows || 3;
      const cols = data.cols || 3;
      tableModule.insertTable(rows, cols);
      sendJsonToFlutter({
        type: 'response',
        action: 'insertTable',
        success: true,
        message: `Table inserted: ${rows}x${cols}`,
        timestamp: Date.now()
      });
      break;
      
    case 'getContents':
      const content = editor.getContents();
      const htmlContent = editor.getSemanticHTML();
      sendJsonToFlutter({
        type: 'response',
        action: 'getContents',
        success: true,
        data: {
          delta: content,
          html: htmlContent,
          text: editor.getText()
        },
        timestamp: Date.now()
      });
      break;
      
    case 'setContents':
      if (data.delta) {
        editor.setContents(data.delta, Quill.sources.USER);
        sendJsonToFlutter({
          type: 'response',
          action: 'setContents',
          success: true,
          message: 'Contents set successfully',
          timestamp: Date.now()
        });
      }
      break;
      
    default:
      sendJsonToFlutter({
        type: 'response',
        action: data.action || 'unknown',
        success: false,
        message: 'Unknown command',
        timestamp: Date.now()
      });
  }
}

// Send initial message to Flutter when iframe loads
window.addEventListener('load', function() {

});

// Send content change notifications (throttled)
let contentChangeTimeout;
editor.on('text-change', function(delta, oldDelta, source) {
  if (source === 'user') {
    // Send immediate update with complete content
    const completeContent = editor.getContents();
    const htmlContent = editor.getSemanticHTML();
    const textContent = editor.getText();
    
    sendJsonToFlutter({
      type: 'contentChange',
      delta: completeContent, // Send complete content, not just the change
      html: htmlContent,
      text: textContent,
      timestamp: Date.now()
    });
    
    // Also send a throttled summary for heavy operations
    clearTimeout(contentChangeTimeout);
    contentChangeTimeout = setTimeout(() => {
    
    }, 1000); // Wait 1 second after last change
  }
});

    </script>

   
</body>
</html>
```

### File 2: Delta Renderer HTML (`web/delta_renderer.html`)

Create this file in your `web/` folder:

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>

       <!-- Quill.js CSS -->
       <link href="https://cdn.jsdelivr.net/npm/quill@2/dist/quill.snow.css" rel="stylesheet">

    
       <!-- Quill Better Table CSS -->
       <link href="https://cdn.jsdelivr.net/npm/quill-table-better@1/dist/quill-table-better.css" rel="stylesheet">
    <style>
        table,
        td,
        th {
            border: 1px solid black;
            border-collapse: collapse;

        }
       
.ql-editor ol li {
    list-style-type: decimal;
    padding-left: 0;
}

.ql-editor ul li {
    list-style-type: disc;
    padding-left: 0;
    margin: 0;
}

.ql-editor ul {
    margin: 0;
}

        table tbody tr td p {
            margin: 0;
            padding: 0;
        }

        p {
            margin: 0;
            padding: 0;
        }
    </style>
</head>

<body>

    <div id="viewer" class="ql-editor"></div>

    <script src="https://cdn.jsdelivr.net/npm/quill@2/dist/quill.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/quill-table-better@1/dist/quill-table-better.js"></script>
    <script>
        // Register the module just like in the editor
        Quill.register({
            'modules/better-table': QuillTableBetter
        }, true);

        window.addEventListener('message', function (event) {
            // Only process messages from the parent window (Flutter)
            if (event.source !== window.parent) {
                return;
            }
            console.log('event.data: ', event.data);

            try {
                document.getElementById('viewer').innerHTML = event.data;
            } catch (e) {
                // Handle plain string messages
               
            }
        });
        // Create a Quill instance in read-only mode
        
        // Load your saved Delta

    </script>

</body>

</html>
```

## Step 3: Implementation in FlutterFlow

### Home Page Widget Example

Here's how to use the QuillEditor widget in your FlutterFlow page:

```dart
import 'package:quill_with_table/custom_code/widgets/quill_editor.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  static String routeName = 'HomePage';
  static String routePath = '/homePage';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String myHTMLString = "";

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          title: Text(
            'Page Title',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                   padding: const EdgeInsets.only(left:  18.0, right: 18.0,top: 18.0),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 1.0,
                    height: 500.0,
                    child: custom_widgets.QuillEditor(
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      height: 500.0,
                      onMessageReceived: (message) async {
                       print('message: $message');
                       setState(() {
                        myHTMLString = message ?? "";
                       });
                      },
                    ),
                  ),
                ),
                Text(
                  'Preview',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight:
                              FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
                 Padding(
                   padding: const EdgeInsets.only(left:  18.0, right: 18.0,top: 18.0),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 1.0,
                    height: 500.0,
                    child: custom_widgets.QuillEditor(
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      height: 500.0,
                      onMessageReceived: (message) async {
                      
                       
                      },
                      realOnly: true,
                      htmlString: myHTMLString,
                      
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## Communication Between Flutter and iframe

### How the Communication Works

The communication between Flutter and the iframe is bidirectional and uses the `postMessage` API:

#### 1. **Flutter to iframe Communication**

```dart
// Send a simple string message
void sendMessageToIframe(String message) {
  _iframe?.contentWindow?.postMessage(message, '*');
}

// Send structured JSON data
void sendJsonToIframe(Map<String, dynamic> data) {
  data['source'] = 'flutter';
  data['type'] = 'command';
  final jsonString = jsonEncode(data);
  _iframe?.contentWindow?.postMessage(jsonString, '*');
}
```

#### 2. **iframe to Flutter Communication**

```javascript
// Send simple message
function sendMessageToFlutter(message) {
  if (window.parent) {
    window.parent.postMessage(message, '*');
  }
}

// Send structured JSON data
function sendJsonToFlutter(data) {
  data.messageId = ++messageId;
  data.source = 'iframe';
  sendMessageToFlutter(JSON.stringify(data));
}
```

#### 3. **Message Listening in Flutter**

```dart
html.window.addEventListener('message', (event) {
  final messageEvent = event as html.MessageEvent;
  
  if (messageEvent.data != null) {
    try {
      final data = jsonDecode(messageEvent.data);
      widget.onMessageReceived?.call(data["html"]);
    } catch (e) {
      // Handle plain string messages
      widget.onMessageReceived?.call(messageEvent.data);
    }
  }
});
```

#### 4. **Message Listening in iframe**

```javascript
window.addEventListener('message', function(event) {
  // Only process messages from the parent window (Flutter)
  if (event.source !== window.parent) {
    return;
  }
  
  try {
    const data = JSON.parse(event.data);
    if (data.type === 'command') {
      handleFlutterCommand(data);
    }
  } catch (e) {
    // Handle plain string messages
    sendMessageToFlutter('Echo: ' + event.data);
  }
});
```

## Code Examples

### Example 1: Basic Usage

```dart
QuillEditor(
  width: 400.0,
  height: 300.0,
  onMessageReceived: (message) async {
    print('Received HTML: $message');
    // Handle the received HTML content
  },
)
```

### Example 2: Read-Only Mode

```dart
QuillEditor(
  width: 400.0,
  height: 300.0,
  realOnly: true,
  htmlString: "<p>This is read-only content</p>",
  onMessageReceived: (message) async {
    // This won't be called in read-only mode
  },
)
```

### Example 3: Sending Commands to the Editor

```dart
// Get the editor instance and send commands
final editor = QuillEditor(
  width: 400.0,
  height: 300.0,
  onMessageReceived: (message) async {
    // Handle responses
  },
);

// Send a command to insert a table
editor.sendJsonToIframe({
  'action': 'insertTable',
  'rows': 3,
  'cols': 4,
});

// Get current contents
editor.sendJsonToIframe({
  'action': 'getContents',
});
```

### Example 4: Real-time Content Updates

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  String currentContent = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuillEditor(
          width: 400.0,
          height: 300.0,
          onMessageReceived: (message) async {
            setState(() {
              currentContent = message ?? '';
            });
          },
        ),
        // Display the current content
        Text('Current content: $currentContent'),
      ],
    );
  }
}
```

## Troubleshooting

### Common Issues

1. **iframe not loading**
   - Ensure the HTML files are in the `web/` folder
   - Check that the file paths are correct (`/test_quill.html`, `/delta_renderer.html`)

2. **Messages not being received**
   - Verify that the message event listeners are properly set up
   - Check the browser console for JavaScript errors

3. **Styling issues**
   - Ensure all CSS files are properly loaded
   - Check that the iframe dimensions are set correctly

4. **Table functionality not working**
   - Verify that quill-table-better is properly registered
   - Check that the toolbar includes the table-better option

### Debug Tips

1. **Enable console logging**
   ```javascript
   console.log('Message received:', event.data);
   ```

2. **Check message format**
   ```dart
   print('Received message: $message');
   ```

3. **Verify iframe source**
   ```dart
   print('iframe src: ${_iframe?.src}');
   ```

## Advanced Features

### Custom Table Operations

You can extend the iframe JavaScript to support more table operations:

```javascript
// Add to handleFlutterCommand function
case 'insertRow':
  tableModule.insertRow();
  break;
  
case 'insertColumn':
  tableModule.insertColumn();
  break;
  
case 'deleteRow':
  tableModule.deleteRow();
  break;
  
case 'deleteColumn':
  tableModule.deleteColumn();
  break;
```

### Custom Styling

You can customize the editor appearance by modifying the CSS in the HTML files:

```css
.ql-editor {
  font-family: 'Your Custom Font', sans-serif;
  font-size: 16px;
  line-height: 1.6;
}

.ql-toolbar {
  background-color: #f8f9fa;
  border-bottom: 2px solid #e9ecef;
}
```

### Performance Optimization

1. **Throttle messages** to prevent excessive communication
2. **Use read-only mode** for displaying content
3. **Implement proper cleanup** in the dispose method

This guide provides a complete implementation of quill-better-table with FlutterFlow. The bidirectional communication system allows for real-time updates and advanced table operations while maintaining a clean separation between Flutter and web technologies.
