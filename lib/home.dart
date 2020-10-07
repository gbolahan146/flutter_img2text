import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:generate_live_captions/generatecaptions.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = true;
  File _image;
  final picker = ImagePicker();
  String resultText = "Fetching response..";

  pickImage() async {
    var image = await picker.getImage(source: ImageSource.camera);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
      _loading = false;
    });
    var str = fetchResponse(_image);
    print(str);
  }

  pickGalleryImage() async {
    var image = await picker.getImage(source: ImageSource.gallery);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
      _loading = false;
    });
    var str = fetchResponse(_image);
    print('fo $str');
  }

  Future<Map<String, dynamic>> fetchResponse(File image) async {
    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');

    final imageUploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://max-image-caption-generator.codait-prod-41208c73af8fca213512856c7a09db52-0000.us-east.containers.appdomain.cloud/model/predict'));

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
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.004, 1],
                  colors: [Color(0x11232256), Color(0xff232526)])),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Text Generator',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 35),
                ),
                Text(
                  'Image To Text Generator',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  height: MediaQuery.of(context).size.height - 250,
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7)
                      ]),
                  child: ListView(
                    children: [
                      Center(
                        child: _loading
                            ? Container(
                                width: 500,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 50,
                                    ),
                                    Container(
                                      width: 100,
                                      child: Image.asset('assets/notepad.png'),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          GenerateLiveCaptions()));
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 24, vertical: 17),
                                              decoration: BoxDecoration(
                                                  color: Color(0xff56ab2f),
                                                  borderRadius:
                                                      BorderRadius.circular(6)),
                                              child: Text(
                                                "Live Camera",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          GestureDetector(
                                            onTap: pickImage,
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 24, vertical: 17),
                                              decoration: BoxDecoration(
                                                  color: Color(0xff56ab2f),
                                                  borderRadius:
                                                      BorderRadius.circular(6)),
                                              child: Text(
                                                "Take a Photo",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          GestureDetector(
                                            onTap: pickGalleryImage,
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 24, vertical: 17),
                                              decoration: BoxDecoration(
                                                  color: Color(0xff56ab2f),
                                                  borderRadius:
                                                      BorderRadius.circular(6)),
                                              child: Text(
                                                "Camera Roll",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Container(
                                padding: EdgeInsets.only(top: 10),
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      height: 200,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: IconButton(
                                                icon: Icon(
                                                  Icons.arrow_back_ios,
                                                  color: Colors.black,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _loading = true;
                                                    resultText =
                                                        "Fetching :( response...";
                                                  });
                                                }),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                205,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.file(
                                                _image,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      child: Text(
                                        "$resultText",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
