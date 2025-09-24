## Overview

This guide shows you how to integrate **quill-better-table** with FlutterFlow using a custom widget that embeds a web-based Quill editor with advanced table functionality. The implementation uses iframe communication to enable real-time data exchange between Flutter and the web editor.

---

## Prerequisites

- FlutterFlow project
- Basic understanding of Flutter custom widgets
- Web development knowledge (HTML, CSS, JavaScript)

---

## FlutterFlow Project Link

https://enterprise-india.flutterflow.io/project/quill-with-table-icwsp8  

Step 1: Custom Widget Setup

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

        if (messageEvent.data != null) {
          try {
            final data = jsonDecode(messageEvent.data);
            widget.onMessageReceived?.call(data["html"]);
          } catch (e) {
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

Should be kept in web folder of Flutter Project

### File 1: Editor HTML (`web/test_quill.html`)

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

Should be kept in web folder of Flutter Project

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

---

## Step 3: Implementation in FlutterFlow

### Home Page Widget Example

```dart
import 'package:quill_with_table/custom_code/widgets/quill_editor.dart';
...

```

---

## Communication Between Flutter and iframe

### How the Communication Works

The communication between Flutter and the iframe is bidirectional and uses the `postMessage` API.

### Flutter to iframe Communication

```dart
void sendMessageToIframe(String message) { ... }
void sendJsonToIframe(Map<String, dynamic> data) { ... }

```

### iframe to Flutter Communication

```jsx
function sendMessageToFlutter(message) { ... }
function sendJsonToFlutter(data) { ... }

```

### Message Listening in Flutter

```dart
html.window.addEventListener('message', (event) { ... });

```

### Message Listening in iframe

```jsx
window.addEventListener('message', function(event) { ... });

```

---

> ⚠ Note : Make sure to add the above files in the web folder of your flutter project and use the link in the Custom widget which we created in the Step 1 Like shown below (`/test_quill.html`)
> 

```jsx
_iframe = html.IFrameElement()
        ..src = '/test_quill.html'
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%';
```

### Example 1: Basic Usage

```dart
QuillEditor(
  width: 400.0,
  height: 300.0,
  onMessageReceived: (message) async {
    print('Received HTML: $message');
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
)

```

### Example 3: Sending Commands

```dart
editor.sendJsonToIframe({
  'action': 'insertTable',
  'rows': 3,
  'cols': 4,
});

```

## Troubleshooting

### Common Issues

1. **iframe not loading** – check file paths
2. **Messages not received** – verify listeners
3. **Styling issues** – confirm CSS loaded
4. **Table not working** – ensure module registered

### Debug Tips

```jsx
console.log('Message received:', event.data)
```

```dart
print('Received message: $message');

```

---

## Advanced Features

### Custom Table Operations

```jsx
case 'insertRow': tableModule.insertRow(); break
```

### Custom Styling

```css
.ql-editor {
  font-family: 'Your Custom Font', sans-serif;

```

### Performance Optimization

- Throttle messages
- Use read-only mode for display
- Clean up resources in `dispose`
