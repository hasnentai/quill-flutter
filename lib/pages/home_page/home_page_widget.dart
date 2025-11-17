import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:convert';
import 'dart:html' as html;
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page_model.dart';
import 'global_key.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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
                    fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                    fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      height: 500.0,
                      child: custom_widgets.QuillEditor(
                        key: editorKey,
                        width: MediaQuery.sizeOf(context).width * 0.8,
                        height: 500.0,
                        onMessageReceived: (message) async {
                          _model.htmlString = message;
                          safeSetState(() {});
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.sizeOf(context).width * 0.2,
                    padding: EdgeInsets.all(16.0),
                    child: DropdownButton<String>(
                      value: _model.selectedDropdownValue,
                      hint: Text('Select text to insert'),
                      isExpanded: true,
                      items: [
                        'Hello',
                        'World',
                        'Flutter',
                        'Quill',
                        'Editor',
                        'Custom Text',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _model.selectedDropdownValue = newValue;
                          // Insert text at cursor position
                          final state = editorKey.currentState;
                          if (state != null) {
                            // Access the insertText method through the state
                            (state as dynamic).insertText(newValue);
                          }
                          safeSetState(() {});
                        }
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: ElevatedButton(
                    child: Text('Download as HTML'),
                    onPressed: () {
                      _model.htmlString = '''
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <link href="https://cdn.jsdelivr.net/npm/quill@2/dist/quill.snow.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/quill-table-better@1/dist/quill-table-better.css" rel="stylesheet">
    <style>
      table, td, th {
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
    <div class="ql-editor">
      ${_model.htmlString}
    </div>
  </body>
</html>
''';
                      safeSetState(() {});
                      final htmlContent = _model.htmlString ?? '';
                      final bytes = utf8.encode(htmlContent);
                      final blob = html.Blob([bytes], 'text/html');
                      final url = html.Url.createObjectUrlFromBlob(blob);
                      final anchor = html.AnchorElement(href: url)
                        ..setAttribute('download', 'quill_data.html')
                        ..click();
                      html.Url.revokeObjectUrl(url);
                    }),
              ),
              Text(
                'Preview',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      letterSpacing: 0.0,
                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
              Container(
                width: MediaQuery.sizeOf(context).width * 1.0,
                height: 300.0,
                child: custom_widgets.QuillEditor(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  height: 300.0,
                  realOnly: true,
                  htmlString: _model.htmlString,
                  onMessageReceived: (message) async {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
