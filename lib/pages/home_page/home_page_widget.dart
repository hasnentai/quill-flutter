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
                    child: Text('Download as plain HTML'),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: ElevatedButton(
                    child: Text('Download as DRA-DAYTIME HTML'),
                    onPressed: () {
                      _model.htmlString = '''
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<meta charset="UTF-8">
<style>
  @import url('https://fonts.googleapis.com/css2?family=Mulish:ital,wght@0,200..1000;1,200..1000&display=swap');
  </style>
	<style>
		html, body { min-width:260px; min-height:100%; padding:0; Margin:0 auto; background:#FFFFFF !important; }
		img, a{border:0px;}
		a img { border:0px; }
		a:link {color:#94292e;} 
        a:visited {color:#94292e;} 
        a:active {color:#94292e;}
		.ReadMsgBody { width:100%; }
		.ExternalClass { width:100%; }
		.ExternalClass * { line-height:100%; }
		table, td { border-collapse:collapse; mso-table-lspace:0pt; mso-table-rspace:0pt; }
a.maroon, a.maroon:link, a.maroon:visited, a.maroon:hover, a.maroon:focus, a.maroon:active{
  color:#94292e !important;
}
a.whiteclr, a.whiteclr:link, a.whiteclr:visited, a.whiteclr:hover, a.whiteclr:focus, a.whiteclr:active{
  color:#FFFFFF !important;
}
.showcent{display:none;}
	</style>
	<style type="text/css">
		@media only screen and (max-width:530px) {
			@-ms-viewport { width:320px; }
			@viewport { width:320px; }
		}
	</style>
	<meta name="viewport" content="width=device-width, initial-scale=1.0" />
	<!--[if !mso]><!-- -->
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<!--<![endif]-->
</head>

<body>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
 
  <tr>
    <td></td>
    <td  style="max-width:100%; width:600px;"><table width="100%" border="1"  bordercolor="#e3530f"  cellspacing="0" cellpadding="0" style="border-collapse:collapse; border:1px solid #e3530f;">
  <tr>
    <td><table width="100%" border="0" cellpadding="0" cellspacing="0" >
    	<tr>
        <td><img src="https://www.assets.icicibank.com/campaigns/mailers-v3/marketing/2025/july/23/forex-deal-2/unmapped/images/headercenter.jpg" alt="ICICI Bank" width="100%" style="display:block;" /></td>
      </tr>
     
      
     <tr>
      	<td>&nbsp;</td>
      </tr>

      <tr>
        <td>
          ${_model.htmlString}
        </td>
      </tr>
    
      <tr>
         <td height="20"></td>
       </tr>
       <tr>
         <td style="text-align:center; padding-left:25px; padding-right:25px;"><font style="font-size:16px; color:#000000; font-family:'Mulish Extrabold', Arial;"><strong>To know more, please call only on</strong></font></td>
       </tr>
        <tr>
         <td height="5"></td>
       </tr>
            <tr>
        <td align="center">
                   <a href="tel:18001080" target="_blank"> <img src="https://www.assets.icicibank.com/campaigns/mailers-v3/marketing/2025/july/23/forex-deal-2/unmapped/images/call.png" width="183" height="39"  style="display:block;"  /> </a>
                  </td>
          </tr>
      <tr>
         <td height="5"></td>
       </tr>
       
          <tr>
         <td style="text-align:center; padding-left:25px; padding-right:25px;"><font style="font-size:16px; color:#000000; font-family:'Mulish Extrabold', Arial;"><strong>Stay safe from fraudsters. Do not call any other number. </strong></font></td>
       </tr>
       <tr>
         <td height="20" align="left" bgcolor="#ffffff"  style=" padding:0px 0px 0px 0px; "><div style="text-align:center; font-size:0; ">
           <!--[if mso]>
      <table border="0" cellpadding="0" cellspacing="0" width="600" align="center" bgcolor="#ffffff" style="width:600px;"><tr><td style="width:48%; >
      <![endif]-->
           <div style="display:inline-block; font-size:16px; text-align:left; vertical-align:top; width:48%; min-width:300px; max-width:100%; width:-webkit-calc(230400px - 48000%); min-width:-webkit-calc(48%); width:calc(230400px - 48000%); min-width:calc(48%);">
             <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#ffffff">
               <tr>
                 <td align="center"><table width="100%" border="0" cellpadding="0" cellspacing="0" align="center">
                   <tr>
                     <td style="text-align:center;padding-top:15px;"><font style="font-size:16px; color:#000000; font-family:'Mulish Extrabold', Arial;"><strong>For further assistance</strong></font><br />
                       <a href="https://www.assets.icicibank.com/campaigns/mailers-v3/marketing/2025/july/23/forex-deal-2/unmapped/ComLinks/Chatwithus.html" target="_blank" style="font-size:12px; color:#97291e; font-family:  'Mulish Semibold', Arial;text-decoration:underline;" class="maroon"><font color="#97291e">Chat with us</font></a> &#10072; <a href="https://www.assets.icicibank.com/campaigns/mailers-v3/marketing/2025/july/23/forex-deal-2/unmapped/ComLinks/Locatebranch.html" target="_blank" style="font-size:12px; color:#97291e; font-family:  'Mulish Semibold', Arial; text-decoration:underline;" class="maroon"><font color="#97291e">Locate a branch</font></a> &#10072; <a href="https://www.assets.icicibank.com/campaigns/mailers-v3/marketing/2025/july/23/forex-deal-2/unmapped/ComLinks/WhatsAppus.html" target="_blank" style="font-size:12px; color:#97291e; font-family:  'Mulish Semibold', Arial;text-decoration:underline;" class="maroon"><font color="#97291e">WhatsApp us</font></a></td>
                   </tr>
                 </table></td>
               </tr>
             </table>
           </div>
           <!--[if mso]>
      </td>
      <td style="width:40%; >

      <![endif]-->
           <div style="display:inline-block; font-size:16px; text-align:left; vertical-align:top; width:48%; min-width:270px; max-width:100%; width:-webkit-calc(230400px - 48000%); min-width:-webkit-calc(48%); width:calc(230400px - 48000%); min-width:calc(48%);">
             <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#ffffff">
               <tr>
                 <td align="center"><table width="90%" border="0" cellpadding="0" cellspacing="0" align="center">
                   <tr>
                     <td style="padding-top:15px;text-align:center;"><font style="font-size:16px; color:#000000; font-family:'Mulish Extrabold', Arial;"><strong>Access your account</strong></font><br />
                       <a href="https://www.assets.icicibank.com/campaigns/mailers-v3/marketing/2025/july/23/forex-deal-2/unmapped/ComLinks/InternetBanking.html" target="_blank" style="font-size:12px; color:#97291e; font-family:  'Mulish Semibold', Arial;text-decoration:underline;" class="maroon"><font color="#97291e">Internet Banking</font></a> &#10072; <a href="https://www.assets.icicibank.com/campaigns/mailers-v3/marketing/2025/july/23/forex-deal-2/unmapped/ComLinks/iMobile.html" target="_blank" style="font-size:12px; color:#97291e; font-family:  'Mulish Semibold', Arial;text-decoration:underline;" class="maroon"><font color="#97291e">iMobile</font></a></td>
                   </tr>
                 </table></td>
               </tr>
             </table>
           </div>
           <!--[if mso]>
      </td>
      
      </tr>
      </table>
      <![endif]-->
         </div></td>
       </tr>
       <tr>
         <td height="20"></td>
       </tr>
       <tr>
         <td style="padding:0px 25px; text-align:justify;"><font style="font-size:14px; color:#000000; font-family:  'Mulish Semibold', Arial;"> Sincerely,<br />
           Team ICICI Bank</font></td>
       </tr>

      
     <tr>
       <td height="12"></td>
     </tr>
     
 
       <tr>
         <td bgcolor="#e3530f" height="10"></td>
       </tr>
    </table></td>
  </tr>
</table>
</td>
    <td></td>
  </tr>
   <tr>
     <td></td>
     <td style="max-width:100%; width:600px; padding:5px 0;">
       <table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tbody>
            
            <tr>
              <td align="center" style="padding:10px;"><font style="font-size:13px; color:#000000; font-family:'Mulish Semibold', Arial;">This is a system generated e-mail. Please do not reply. </font>
        </td>
            </tr>
            <tr>
              <td style="padding:0px 25px;text-align:center;">
                 <a href="https://www.assets.icicibank.com/campaigns/mailers-v3/marketing/2025/july/23/forex-deal-2/unmapped/ComLinks/TnCs.html" target="_blank" style="font-size:13px; color:#97291e; font-family:  'Mulish Semibold', Arial;" class="maroon"><font color="#97291e">T&Cs </font> </a> &#10072; <a href="https://www.assets.icicibank.com/campaigns/mailers-v3/marketing/2025/july/23/forex-deal-2/unmapped/ComLinks/Disclaimer.html" target="_blank" style="font-size:13px; color:#97291e; font-family:  'Mulish Semibold', Arial;" class="maroon"><font color="#97291e">Disclaimer</font></a> 
              </td>
            </tr>
            <tr>
              <td>&nbsp;</td>
            </tr>
          </tbody>
        </table>

     </td>
     <td></td>
   </tr>
</table>
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
