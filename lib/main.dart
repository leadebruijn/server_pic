import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: UploadImageDemo(),
    );
  }
}

class UploadImageDemo extends StatefulWidget {
 UploadImageDemo() : super();

 final String title = "Upload Image Demo";

  @override
  _UploadImageDemoState createState() => _UploadImageDemoState();
}

class _UploadImageDemoState extends State<UploadImageDemo> {

  // static final String uploadEndPoint = 'http://192.168.56.1/server_pic/upload_image.php'; //huis
  // static final String uploadEndPoint = 'http://172.20.10.8:80/server_pic/upload_image.php'; //flat ONDER
  static final String uploadEndPoint = 'http://192.168.56.1:80/server_pic/upload_image.php'; //flat BO
  // static final String uploadEndPoint = 'http://10.0.2.207:80/server_pic/upload_image.php'; //flat MOIBLE

  Future <File> ?file;
  String status = '';
  String base64Image = '';
  File ?tmpFile;
  String errMessage = 'Error Uploading Image';

  ImagePicker picker = ImagePicker();

  chooseImage() {
   setState(() {
     file = ImagePicker.pickImage(source: ImageSource.gallery);
     // final picker = ImagePicker();
     //
     // file = picker.pickImage(source: ImageSource.gallery);
   });
     setStatus('');
  }

  setStatus(String message) {
    setState(() {
      status = message;
    });
  }

  startUpload() {
    setStatus('Uploading Image...');
    if (null == tmpFile) {
      setStatus(errMessage);
      return;
    }
    String fileName = tmpFile!.path.split('/').last;
    upload(fileName);
  }

  upload(String fileName) {
    http.post(Uri.parse(uploadEndPoint), body: {
      "image": base64Image,
      "name": fileName,
    }).then((result) {
      setStatus(result.statusCode == 200 ? result.body : errMessage);
    }).catchError((error) {
      setStatus(error);
    });
  }

  Widget showImage(){
    return FutureBuilder<File>(
      future: file,
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          if(snapshot.connectionState == ConnectionState.done &&
          null != snapshot.data){
            tmpFile = snapshot.data;
            base64Image = base64Encode(snapshot.data!.readAsBytesSync());
            return Flexible(
              child: Image.file(
                snapshot.data!,
                fit: BoxFit.fill,
              ),
            );
          }else if(null != snapshot.error) {
            return const Text(
              'Error Picking Image',
              textAlign: TextAlign.center,
            );
          }
            else {
            return const Text(
              'No Image Selected',
              textAlign: TextAlign.center,
            );
          }
        },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Image Demo"),
      ),
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            OutlinedButton(
              onPressed: chooseImage,
              child: const Text('Choose Image'),
            ),
            const SizedBox(height: 20.0),
            showImage(),
            const SizedBox(height: 20.0),
            OutlinedButton(
              onPressed: startUpload,
              child: const Text('Upload Image'),
            ),
            const SizedBox(height: 20.0),
            Text(status,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w500,
              fontSize: 20.0,
            ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}

