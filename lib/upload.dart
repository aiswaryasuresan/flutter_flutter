import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http_parser/http_parser.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

import 'config.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {

  List<Asset> images = [];
  Dio dio = Dio();

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 6,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = [];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      print(error = e.toString());
      // error = e.toString();
    }
    if (!mounted) return;

    setState(() {
      images = resultList;
      // _error = error;
    });
  }



  _saveImage() async {
    if(images != null){
      int count = 0;
      for(var i=0; i<images.length; i++){
        ByteData byteData = await images[i].getByteData();
        List<int> imageData = byteData.buffer.asUint8List();
        
        MultipartFile multipartFile = MultipartFile.fromBytes(
          imageData,
          filename: images[i].name,
          contentType: MediaType('image','jpg'),
        );
        
        FormData formData = FormData.fromMap({
          "image": multipartFile
        });
        EasyLoading.show(status: 'uploading... ');

        var response = await dio.post(UPLOAD_URL,data: formData);
        if(response.statusCode ==200){
          count++;
          EasyLoading.showSuccess('Success  $count !');
          EasyLoading.dismiss();
          print(response.data);
        }
      }
    }
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Image"),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 20),
        child: Center(
          child: Column(
            children: [
              RaisedButton(onPressed: loadAssets,child: Text("Pick Image"),),
              Expanded(
                child: buildGridView(),
              ),
              RaisedButton(onPressed: _saveImage,child: Text("Save"),),
            ],
          ),
        ),
      ),
    );
  }
}
