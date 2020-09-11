import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as Im;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketplace/models/models.dart';
import 'package:marketplace/screens/screens.dart';
import 'package:marketplace/widgets/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  File _file;
  bool isUploading = false;
  String postId = Uuid().v4();

  handleTakePhoto() async {
    Navigator.pop(context);
    final picker = ImagePicker();
    PickedFile file = await picker.getImage(
      source: ImageSource.camera,
      maxWidth: 960,
      maxHeight: 675,
    );

    setState(() {
      this._file = File(file.path);
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    final picker = ImagePicker();
    PickedFile file = await picker.getImage(
      source: ImageSource.gallery,
    );

    setState(() {
      this._file = File(file.path);
    });
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text('Create Post'),
          children: [
            SimpleDialogOption(
              child: Text('Photo with camera'),
              onPressed: handleTakePhoto,
            ),
            SimpleDialogOption(
              child: Text('Image from gallery'),
              onPressed: handleChooseFromGallery,
            ),
            SimpleDialogOption(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Future<void> retrieveLostData() async {
    final picker = ImagePicker();
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        if (response.type == RetrieveType.video) {
          print('video');
        } else {
          setState(() {
            this._file = File(response.file.path);
            print('retrieved');
          });
        }
      });
    } else {
      print(response.exception.code);
    }
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/images/upload.svg', height: 260.0),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                "Upload Image",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
              color: Colors.deepOrange,
              onPressed: () => selectImage(context),
            ),
          )
        ],
      ),
    );
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    Im.Image imageFile = Im.decodeImage(this._file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));

    setState(() {
      this._file = compressedImageFile;
    });
  }
  
  Future<String> uploadImage(File imageFile) async {
    StorageUploadTask uploadTask = storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();

    return downloadUrl;
  }

  createPostInFireStore({String mediaUrl, String location, String description}) {
    postsRef
    .document(widget.currentUser.id)
    .collection("userPosts")
    .document(postId)
    .setData({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      'username': widget.currentUser.username,
      "mediaUrl": mediaUrl,
      'location': location,
      'description': description,
      'timestamp': DateTime.now(),
      'likes': {},
    });

    captionController.clear();
    locationController.clear();

    setState(() {
      this._file = null;
      this.isUploading = false;
      this.postId = Uuid().v4();
    });
  }

  handleSubmit() async {
    setState(() {
      this.isUploading = true;
    });

    await compressImage();
    String medialUrl = await uploadImage(this._file);
    createPostInFireStore(
      mediaUrl: medialUrl,
      location: locationController.text,
      description: captionController.text,
    );
  }

  buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearImage,
        ),
        title: Text("Caption Post", style: TextStyle(color: Colors.black)),
        actions: [
          FlatButton(
            child: Text(
              "Post",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
            ),
            onPressed: this.isUploading ? null : () => handleSubmit(),
          )
        ],
      ),
      body: ListView(
        children: [
          this.isUploading ? linearProgress() : Text(""),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(this._file),
                  )),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                    hintText: "write a caption...", border: InputBorder.none),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                    hintText: "Where was this photo taken?",
                    border: InputBorder.none),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              onPressed: () => getUserLocation(),
              icon: Icon(Icons.my_location, color: Colors.white,),
              label: Text(
                "use current location",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.blue,
            ),
          )
        ],
      ),
    );
  }

  getUserLocation() async {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    
    List<Placemark> placemarks = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress = '${placemark.subThoroughfare} ${placemark.thoroughfare}, '
        '${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea} ${placemark.administrativeArea}, '
        '${placemark.postalCode}, ${placemark.country}, ${placemark.name}';

    String formattedAddress = '${placemark.locality}, ${placemark.country}';
    locationController.text = formattedAddress;

    print(completeAddress);
  }

  clearImage() {
    setState(() {
      this._file = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    _file == null && Platform.isAndroid
        ? retrieveLostData()
        : print("not retrieved");
    return _file == null ?  buildSplashScreen() : buildUploadForm();
//    return buildUploadForm();
  }
}
