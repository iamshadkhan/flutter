import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';

class CsvPicker extends StatefulWidget {
  const CsvPicker({Key? key}) : super(key: key);

  @override
  State<CsvPicker> createState() => _CsvPickerState();
}


class _CsvPickerState extends State<CsvPicker> {
  FilePickerResult? result;
  File? files;

  String uint8ListTob64(Uint8List uint8list) {
    String base64String = base64Encode(uint8list);
    return  base64String;
  }

  late final PlatformWebViewController _controller;

// postReq(String b64)
// async {
//   var headers = {
//     'Content-Type': 'application/json'
//   };
//   // var request = http.Request('POST', Uri.parse('https://us-central1-prepu-ai.cloudfunctions.net/reporting'));
//   // request.body = json.encode({
//   //   "message": b64
//   // });
//   var
//   request.headers.addAll(headers);
//
//   http.StreamedResponse response = await request.send();
//
//   if (response.statusCode == 200) {
//     return await response.stream.bytesToString();
// }
// else {
// print(response.reasonPhrase);
// }
// }

  Future<dynamic> postRequest(String url,
      {Map<String, dynamic>? body, bool? bodyIsRaw}) async {
    if (bodyIsRaw == null) {
      bodyIsRaw = false;
    }
    print(body.toString());
    var options = BaseOptions(
        baseUrl: "https://us-central1-prepu-ai.cloudfunctions.net",
        responseType: ResponseType.json,
        followRedirects: false,
        headers: {
          "Content-Type": "application/json",
        },
        receiveTimeout: Duration(seconds: 60));
    try {
      Dio dio = Dio(options);
      Response response;
      print(dio.options.baseUrl + url);
      response = await dio.post(url, data:jsonEncode(body));
      print("try");
      var responseData = response.data.toString();
      return responseData;
    } on DioError catch (e) {
      print(e);
      print("Dio" + e.error.toString());
      return {"isSuccess": false};
      // return e.response!.data;
    } catch (e) {
      if (e is DioError) {
        print("error2");
        return e.response!.data;
      }
      print(e);
    }
    return {"isSuccess": false};
  }

  int cs=0;

  Future<void> loadHtmlFromAssets(String htmlCode) async {
    // _controller.loadUrl(Uri.dataFromString(htmlCode,
    //     mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
    //     .toString());

    _controller = PlatformWebViewController(
      const PlatformWebViewControllerCreationParams(),
    )..loadRequest(
      LoadRequestParams(
        uri: Uri.dataFromString(htmlCode,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8')),
      ),
    );


    // await _controller.loadHtmlString(htmlCode);
    setState(() {
      cs=2;
    });
  }

  Future getFiles() async {
    result = await FilePicker.platform.pickFiles(type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      Uint8List? fileBytes = result?.files.first.bytes;
      String? fileName = result?.files.first.name;

      print("$fileName : ${uint8ListTob64(fileBytes!)}");
      setState(() {
        cs=1;
      });

      Map<String,dynamic> body ={};
      body['message']=uint8ListTob64(fileBytes!);

      var res=await postRequest('/reporting',body: body);

      loadHtmlFromAssets(res);

      // Upload file
      // await FirebaseStorage.instance.ref('uploads/$fileName').putData(fileBytes);
    }


    // if (result != null) {
    //   files = result!.paths.map((path) => File(path??"")).toList()[(result?.files.length??1)-1];
    //   print('${result?.files.length}');
    //   print('files selected');
    //   // print(files[0]);
    // } else {
    //
    //   print("No file selected");
    // }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI Based Data Reporting"),
      ),
      body: cs==0?Center(
        child: Container(
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF212332),
                foregroundColor: Colors.grey,
                side: BorderSide(
                    width: 1, color: Colors.grey),
                textStyle: TextStyle(
                  fontSize: 50,
                ),
              ),
              onPressed: () {
                getFiles();
              },
              child: Text("+")),
        ),
      ):cs==2?PlatformWebViewWidget(
        PlatformWebViewWidgetCreationParams(controller: _controller),
      ).build(context):Container(
        child: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20,),
            Text("Generating Report")
          ],
        )),
      )
    );
  }
}
