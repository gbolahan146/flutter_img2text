import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';

class GenerateLiveCaptions extends StatefulWidget {
  @override
  _GenerateLiveCaptionsState createState() => _GenerateLiveCaptionsState();
}

class _GenerateLiveCaptionsState extends State<GenerateLiveCaptions> {
  String resultText = "Fetching response..";
  List<CameraDescription> cameras;
  CameraController controller;
  bool takePhoto = false;

  @override
  void initState() {
    super.initState();
    takePhoto = true;
    detectCameras().then((_) {
      initializeController();
    });
  }

  Future<void> detectCameras() async {
    cameras = await availableCameras();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void initializeController() {
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      if (takePhoto) {
        const interval = const Duration(seconds: 3);
        new Timer.periodic(interval, (Timer t) => capturePictures());
      }
    });
  }

  capturePictures() async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/$timeStamp.png';

    if (takePhoto) {
      controller.takePicture(filePath).then((_) {
        if (takePhoto) {
          File imgFile = File(filePath);
          fetchResponse(imgFile);
        } else {
          return;
        }
      });
    }
  }

  Future<Map<String, dynamic>> fetchResponse(File image) async {
    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');

    final imageUploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://max-image-caption-generator.codait-prod-41208c73af8fca213512856c7a09db52-0000.us-east.containers.appdomain.cloud/model/predict'
            // 'http://max-image-caption-generator-test.2886795277-80-host02nc.environments.katacoda.com/model/predict'
            ));

    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));

    imageUploadRequest.fields['ext'] = mimeTypeData[1];
    imageUploadRequest.files.add(file);

    try {
      final streamResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamResponse);
      final Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData);
      parseResponse(responseData);
      print('gogo $responseData');
      return responseData;
    } catch (e) {
      print('to $e');
      return null;
    }
  }

  void parseResponse(var response) {
    String r = "";
    var predictions = response['predictions'];
    for (var prediction in predictions) {
      var caption = prediction['caption'];
      var probability = prediction['probability'];
      r = r + '$caption\n\n';
    }
    setState(() {
      resultText = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.004, 1],
                  colors: [Color(0x11232526), Color(0xff232526)])),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(top: 35),
                child: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        takePhoto = false;
                      });
                      Navigator.pop(context);
                    }),
              ),
              (controller.value.isInitialized)
                  ? Center(
                      child: _buildCameraPreview(),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    var size = MediaQuery.of(context).size.width / 1.2;
    return Column(
      children: [
        Container(
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Container(
                width: size,
                height: size,
                child: CameraPreview(controller),
              ),
              SizedBox(
                height: 40,
              ),
              Text(
                "Prediction is \n ",
                style: TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.w900,
                    fontSize: 30),
              ),
              Text(
                resultText,
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              )
            ],
          ),
        )
      ],
    );
  }
}
