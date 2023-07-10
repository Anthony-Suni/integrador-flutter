import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

List<String> imageUrls = [
  'https://images.pexels.com/photos/2023384/pexels-photo-2023384.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
  'https://example.com/image2.jpg',
  'https://example.com/image3.jpg',
];
Widget HomePageSliverAppBar(BuildContext context, bool isScrolled,
    TabController _tabController, List<String> imageUrls) {
  const List<Tab> myTabs = [
    Tab(text: 'For you', height: 28),
    Tab(text: 'Today', height: 28),
    Tab(text: 'Following', height: 28),
    Tab(text: 'Health', height: 28),
    Tab(text: 'Recipes', height: 28),
  ];
  return SliverAppBar(
    backgroundColor: Colors.white,
    toolbarHeight: 35,
    expandedHeight: 40,
    collapsedHeight: 40,
    pinned: true,
    floating: true,
    snap: true,
    forceElevated: isScrolled,
    centerTitle: true,
    bottom: PreferredSize(
      preferredSize: MediaQuery.of(context).size.shortestSide > 600
          ? Size.fromHeight(MediaQuery.of(context).size.shortestSide * 0.045)
          : Size.fromHeight(MediaQuery.of(context).size.shortestSide * 0.072),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        unselectedLabelColor: Colors.blueGrey,
        padding: const EdgeInsets.all(0),
        labelPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.shortestSide / 15,
          vertical: 0,
        ),
        labelColor: Colors.black,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade300,
        ),
        tabs: myTabs,
      ),
    ),
    flexibleSpace: FlexibleSpaceBar(
      background: FirebaseImagesPage(imageUrls: imageUrls),
    ),
  );
}

class FirebaseImagesPage extends StatelessWidget {
  final List<String> imageUrls;

  FirebaseImagesPage({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: imageUrls.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final imageUrl = imageUrls[index];
        return GestureDetector(
          onTap: () {
            // Implementa la lógica para mostrar la imagen en pantalla completa
          },
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        );
      },
    );
  }
}
