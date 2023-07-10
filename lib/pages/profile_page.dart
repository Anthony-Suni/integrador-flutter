//perfil
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

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
import 'package:flutter/cupertino.dart';

import '../screens/login_screen.dart';
import '../utils/profile_image_util.dart';

class ImageOverlay extends StatefulWidget {
  final String imageUrl;

  ImageOverlay({required this.imageUrl});

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
            image: CachedNetworkImageProvider(widget.imageUrl),
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
  List<int> likes = [];
  List<int> comments = [];
  List<String> imageUrls = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isImageSelected = false;
  String selectedImageUrl = '';
  OverlayEntry? _overlayEntry;
  final TextEditingController textController = TextEditingController();
  String name = "";
  String email = "";
  int followers = 2002;
  int followings = 31;
  var imagePicker = ImagePicker();

  Future<String?> uploadImageToFirebase(Uint8List data) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      firebase_storage.Reference firebaseStorageRef = firebase_storage
          .FirebaseStorage.instance
          .ref('profile_images/$fileName');

      firebase_storage.UploadTask uploadTask = firebaseStorageRef.putData(data);

      firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<List<String>> getFirebaseStorageImageUrls() async {
    List<String> urls = [];

    try {
      firebase_storage.ListResult result = await firebase_storage
          .FirebaseStorage.instance
          .ref('profile_images')
          .listAll();

      for (firebase_storage.Reference ref in result.items) {
        String downloadURL = await ref.getDownloadURL();
        urls.add(downloadURL);
      }
    } catch (e) {
      print('Error al obtener las URL de las imágenes: $e');
    }

    return urls;
  }

  List<String> defaultImage = [
    'https://i2.wp.com/wallpapercave.com/wp/wp2338602.jpg',
  ];

  Future<void> refresh() async {
    List<String> urls = await getFirebaseStorageImageUrls();

    setState(() {
      imageUrls = urls; // Corregir esta línea
    });
  }

  @override
  void initState() {
    super.initState();
    // Llama a getCurrentUserEmail() cuando la página se inicie
    getCurrentUserEmail();
    // Carga las imágenes desde Firebase Storage
    loadFirebaseStorageImages();
  }

  Future<void> loadFirebaseStorageImages() async {
    List<String> urls = await getFirebaseStorageImageUrls();
    setState(() {
      imageUrls = urls;
    });
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

  // Método para mostrar la pantalla de comentarios
  void showCommentsScreen(int imageIndex) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Comments'),
        content: Column(
          children: [
            Text('Image Index: $imageIndex'),
            // Aquí puedes agregar widgets para mostrar y agregar comentarios
          ],
        ),
      ),
    );
  }

  Future<void> uploadImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      Uint8List? bytes = file.bytes;
      if (bytes != null) {
        String? downloadURL = await uploadImageToFirebase(bytes);
        if (downloadURL != null) {
          setState(() {
            imageUrls.add(downloadURL);
          });
        } else {
          // La subida de la imagen falló, maneja el error como desees
        }
      }
    } else {
      // El usuario canceló la selección del archivo
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
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: const [
                        Icon(
                          Icons.logout,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Login Now",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

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
                    ImageSource? source;

                    var sourceDialog = await showDialog<ImageSource>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Seleccione la fuente de la imagen'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cámara'),
                            onPressed: () =>
                                Navigator.pop(context, ImageSource.camera),
                          ),
                          TextButton(
                            child: const Text('Galería'),
                            onPressed: () =>
                                Navigator.pop(context, ImageSource.gallery),
                          ),
                        ],
                      ),
                    );

                    if (sourceDialog != null) {
                      source = sourceDialog;

                      final XFile? image = await imagePicker.pickImage(
                        source: source,
                        imageQuality: 50,
                        preferredCameraDevice: CameraDevice.front,
                      );

                      if (image != null) {
                        Uint8List? bytes = await image.readAsBytes();
                        if (bytes != null) {
                          String? downloadURL =
                              await uploadImageToFirebase(bytes);
                          if (downloadURL != null) {
                            setState(() {
                              imageUrls.add(downloadURL);
                            });
                          } else {
                            // La subida de la imagen falló, maneja el error como desees
                          }
                        }
                      }
                    }
                  },
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: imageUrls.isNotEmpty
                          ? Image.network(
                              imageUrls.last,
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
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Center(
                  child: Text(
                    email,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          followers.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Center(
                        child: Text(
                          "followers",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 1,
                      ),
                      const SizedBox(width: 5),
                      Center(
                        child: Text(
                          followings.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Center(
                        child: Text(
                          "followings",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
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
                                fontSize: 16,
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(45.0),
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(45.0),
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(45.0),
                                ),
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
                      itemCount: imageUrls.length,
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      itemBuilder: (context, index) {
                        final imageUrl = imageUrls[index];
                        final likeCount =
                            likes.length > index ? likes[index] : 0;
                        final commentCount =
                            comments.length > index ? comments[index] : 0;

                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  placeholder: (context, url) => const Image(
                                    image: AssetImage('assets/cash/img.png'),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Image(
                                    image: AssetImage('assets/cash/img_1.png'),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (likes.contains(index)) {
                                            likes.remove(index);
                                          } else {
                                            likes.add(index);
                                          }
                                        });
                                      },
                                      child: Icon(
                                        likes.contains(index)
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: Colors.black,
                                        size: 17,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        showCommentsScreen(index);
                                      },
                                      child: Icon(
                                        Icons.comment,
                                        color: Colors.black,
                                        size: 17,
                                      ),
                                    ),
                                    Text(
                                      '$likeCount Likes',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      '$commentCount Comments',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                width: MediaQuery.of(context).size.width / 2,
                                height: 20,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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
