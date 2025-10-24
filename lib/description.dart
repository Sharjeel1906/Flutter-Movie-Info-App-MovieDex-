import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Description extends StatefulWidget {
  final dynamic backdrop_path;
  final dynamic adult;
  final dynamic rating;
  final dynamic title;
  final dynamic date;
  final dynamic overview;
  final dynamic popularity;
  final dynamic index;
  const Description({
    super.key,
    required this.backdrop_path,
    required this.rating,
    required this.title,
    required this.overview,
    required this.date,
    required this.adult,
    required this.popularity,
    required this.index,
  });
  @override
  State<Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<Description> {
  final String image_uri = "https://image.tmdb.org/t/p/w500/";
  bool is_favourite = false;
  List<dynamic>Fav_indexes_list=[];
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getFavourite();
      checkFavourite();
    });
  }

  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isDesktop = width > 800;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.topLeft,
            colors: [
              Color(0xff09203f),
              Color(0xff537895),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 600 : width,
              ),
              child: Column(
                children: [
                  // Image section
                Padding(
                    padding: EdgeInsets.only(
                      top: isDesktop?30:45,
                      left: isDesktop ? 15 : 15,
                      right: isDesktop ? 15 : 15,
                      bottom: 15,
                    ),
                    child: Container(
                      height: isDesktop ? 550 : height * 0.58,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            widget.backdrop_path != null
                                ? image_uri + widget.backdrop_path
                                : 'https://via.placeholder.com/500x300?text=No+Image',
                            fit: BoxFit.fill,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.broken_image,
                                      color: Colors.white, size: 40),
                                  SizedBox(height: 5),
                                  Text(
                                    "Could not find image",
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ]),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Content section
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 25 : 20,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.title ?? "No Title",
                                style: TextStyle(
                                  fontSize: isDesktop ? 24 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            const SizedBox(width: 5),
                            IconButton(
                              onPressed: () async {
                                var prefs = await SharedPreferences.getInstance();
                                List<String> favs = prefs.getStringList('Fav') ?? [];
                                setState(() {
                                  if (is_favourite) {
                                    favs.remove(widget.index.toString());
                                    is_favourite = false;
                                  } else {
                                    favs.add(widget.index.toString());
                                    is_favourite = true;
                                  }
                                });
                                prefs.setStringList('Fav', favs);
                              },
                              icon: Icon(
                                is_favourite ? Icons.favorite : Icons.favorite_border_outlined,
                                size: isDesktop ? 20 : 18,
                                color: is_favourite ? Colors.red : Colors.white,
                              ),
                            ),

                            const SizedBox(width: 5,),
                            Icon(
                              Icons.star_outlined,
                              color: Colors.yellow,
                              size: isDesktop ? 20 : 18,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              (widget.rating is num)
                                  ? widget.rating.toStringAsFixed(1)
                                  : "N/A",
                              style: TextStyle(
                                fontSize: isDesktop ? 16 : 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // Overview
                        Text(
                          "Overview",
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.overview ?? "No Overview Available",
                          style: TextStyle(
                            fontSize: isDesktop ? 14 : 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Movie details
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow("Release Date", widget.date ?? "Unknown"),
                              const SizedBox(height: 6),
                              _buildDetailRow("Popularity",
                                  (widget.popularity is num)
                                      ? widget.popularity.toStringAsFixed(1)
                                      : "N/A"),
                              const SizedBox(height: 6),
                              _buildDetailRow("Adult Content",
                                  widget.adult == true ? "Yes" : "No"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Row(
      children: [
        Text(
          "$label: ",
          style: TextStyle(
            fontSize: isDesktop ? 12 : 11,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 12 : 11,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  void getFavourite() async {
    var prefs = await SharedPreferences.getInstance();
    List<String> favs = prefs.getStringList('Fav') ?? [];
    setState(() {
      Fav_indexes_list = favs;
      print("Favourite Indexes:");
      for (var i in Fav_indexes_list) {
        print(i);
      }
    });
  }
  void checkFavourite() async {
    var prefs = await SharedPreferences.getInstance();
    List<String> favs = prefs.getStringList('Fav') ?? [];
    setState(() {
      is_favourite = favs.contains(widget.index.toString());
    });
  }
}
