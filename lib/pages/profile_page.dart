import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../utils/profile_image_util.dart';

class ImageOverlay extends StatefulWidget {
  final ImageProvider imageProvider;

  ImageOverlay({required this.imageProvider});

  @override
  _ImageOverlayState createState() => _ImageOverlayState();
}

class _ImageOverlayState extends State<ImageOverlay> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        color: Colors.black.withOpacity(0.7),
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {},
          child: Image(
            image: widget.imageProvider,
          ),
        ),
      ),
    );
  }
}

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  static const String id = '/profile_page';

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isImageSelected = false;
  String selectedImageUrl = '';
  OverlayEntry? _overlayEntry;
  final TextEditingController textController = TextEditingController();
  String name = "";
  String email = "";
  int followers = 2002;
  int followings = 31;
  var imagePicker;

// ...

  Future<String?> uploadImageToFirebase(File file) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        String fileName = file.name!;
        firebase_storage.Reference firebaseStorageRef = firebase_storage
            .FirebaseStorage.instance
            .ref('profile_images/$fileName');

        firebase_storage.UploadTask uploadTask =
            firebaseStorageRef.putFile(File(file.path!));

        firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
        String downloadURL = await taskSnapshot.ref.getDownloadURL();
        return downloadURL;
      } else {
        // El usuario canceló la selección del archivo
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  List<String> defaultImage = [
    'https://i2.wp.com/wallpapercave.com/wp/wp2338602.jpg',
  ];

  Future<void> refresh() async {
    setState(() {
      defaultImage = [
        'https://i2.wp.com/wallpapercave.com/wp/wp2338602.jpg',
      ];
    });
  }

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();

    // Llama a getCurrentUserEmail() cuando la página se inicie
    getCurrentUserEmail();
  }

  // Método para obtener el correo electrónico del usuario actual
  void getCurrentUserEmail() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        email = user.email ?? "";
        name = email.split("@")[
            0]; // Asigna el correo electrónico o una cadena vacía si no está disponible
      });
    }
  }

  Future<void> uploadImage() async {
    var source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Select Image Source'),
        actions: <Widget>[
          TextButton(
            child: const Text('Camera'),
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          ),
          TextButton(
            child: const Text('Gallery'),
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );

    if (source != null) {
      XFile? image = await imagePicker.pickImage(
        source: source,
        imageQuality: 50,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image != null) {
        String? downloadURL = await uploadImageToFirebase(File(image.path));
        if (downloadURL != null) {
          setState(() {
            // Agrega la URL de descarga a la lista de imágenes
            defaultImage.add(downloadURL);
          });
        } else {
          // La subida de la imagen falló, maneja el error como desees
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.share,
                        color: Colors.black,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        FontAwesomeIcons.ellipsisH,
                        color: Colors.black,
                        size: 18,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                // profile image
                GestureDetector(
                  onTap: () async {
                    var source = await showDialog<ImageSource>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Select Image Source'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Camera'),
                            onPressed: () =>
                                Navigator.pop(context, ImageSource.camera),
                          ),
                          TextButton(
                            child: const Text('Gallery'),
                            onPressed: () =>
                                Navigator.pop(context, ImageSource.gallery),
                          ),
                        ],
                      ),
                    );

                    if (source != null) {
                      XFile? image = await imagePicker.pickImage(
                        source: source,
                        imageQuality: 50,
                        preferredCameraDevice: CameraDevice.front,
                      );

                      if (image != null) {
                        String? downloadURL =
                            await uploadImageToFirebase(File(image.path));
                        if (downloadURL != null) {
                          setState(() {
                            UpdateProfileImage.setImage(File(image.path));
                          });
                        } else {
                          // La subida de la imagen falló, maneja el error como desees
                        }
                      }
                    }
                  },
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: UpdateProfileImage.getImage() != null
                          ? Image.file(
                              UpdateProfileImage.getImage(),
                              fit: BoxFit.cover,
                            )
                          : const Image(
                              image:
                                  AssetImage('assets/local/profile_image.png'),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),
                Center(
                    child: Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 35,
                      color: Colors.black),
                )),
                const SizedBox(
                  height: 12,
                ),
                Center(
                    child: Text(
                  email,
                  style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: Colors.black),
                )),
                const SizedBox(
                  height: 12,
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child: Text(followers.toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Colors.black))),
                      const SizedBox(
                        width: 5,
                      ),
                      const Center(
                          child: Text("followers",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Colors.black))),
                      const SizedBox(
                        width: 5,
                      ),
                      const CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 1,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Center(
                          child: Text(
                        followings.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.black),
                      )),
                      const SizedBox(
                        width: 5,
                      ),
                      const Center(
                          child: Text(
                        "followings",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.black),
                      )),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                // text field
                SizedBox(
                  height: 38,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: TextField(
                            controller: textController,
                            keyboardType: TextInputType.text,
                            onChanged: (value) {},
                            onSubmitted: (search) {},
                            onTap: () {},
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.search_sharp,
                                color: Colors.black54,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              hintText: 'Search your Pins',
                              hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(45.0)),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(45.0)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(45.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          size: 28,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          uploadImage();
                        },
                      ),
                      const SizedBox(width: 20)
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: MasonryGridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(0),
                        itemCount: defaultImage.length,
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        itemBuilder: (context, index) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: CachedNetworkImage(
                                  imageUrl: defaultImage[index],
                                  placeholder: (context, url) => const Image(
                                      image: AssetImage('assets/cash/img.png')),
                                  errorWidget: (context, url, error) =>
                                      const Image(
                                          image: AssetImage(
                                              'assets/cash/img_1.png')),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Align(
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: const Icon(
                                        FontAwesomeIcons.ellipsisH,
                                        color: Colors.black,
                                        size: 17,
                                      ),
                                    ),
                                    alignment: Alignment.centerRight,
                                  ),
                                ),
                                width: MediaQuery.of(context).size.width / 2,
                                height: 20,
                              ),
                            ],
                          );
                        }),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
