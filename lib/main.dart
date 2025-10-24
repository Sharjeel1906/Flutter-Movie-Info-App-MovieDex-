import 'package:flutter/material.dart';
import 'package:movie_info_app/description.dart';
import 'package:movie_info_app/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:movie_info_app/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FilmDex',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late String api_key;
  late String popular_uri;
  late String search_uri;
  late String genre_uri;
  late String search_query;

  final String image_uri = "https://image.tmdb.org/t/p/w500/";
  final search_cont = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String selectedGenre = "All";
  bool is_loading = true;
  int page = 1;

  List<dynamic> results = [];
  List<dynamic> poster_path = [];
  List<dynamic> titles = [];
  List<dynamic> rating = [];
  List<dynamic> genres = [];
  List<dynamic> genres_names = [];
  List<dynamic> backdrop_path = [];

  @override
  void initState() {
    super.initState();
    api_key = dotenv.env['API_KEY'] ?? '';
    search_query = search_cont.text.toString();

    popular_uri = "https://api.themoviedb.org/3/movie/popular?api_key=$api_key&page=$page";
    search_uri = "https://api.themoviedb.org/3/search/movie?query=$search_query&api_key=$api_key&page=$page";
    genre_uri = "https://api.themoviedb.org/3/genre/movie/list?api_key=$api_key";

    fetch_data();
    fetch_genres();
  }

  Future<void> fetch_data() async {
    setState(() => is_loading = true);
    try {
      final response = await http.get(Uri.parse(popular_uri));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newResults = data["results"];

        setState(() {
          results.addAll(newResults);
          for (var result in newResults) {
            poster_path.add(result["poster_path"]);
            titles.add(result["original_title"]);
            rating.add(result["vote_average"]);
            backdrop_path.add(result["backdrop_path"]);
          }
        });
      } else {
        print("Failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() => is_loading = false);
    }
  }

  Future<void> fetch_genres() async {
    try {
      var response = await http.get(Uri.parse(genre_uri));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        genres = data["genres"];
        genres_names = genres.map((g) => g["name"]).toList();
        genres_names.insert(0, "All");
      }
    } catch (e) {
      print("Error fetching genres: $e");
    }
  }

  Future<void> Specific_genre(String genreName) async {
    final genre = genres.firstWhere(
          (g) => g["name"].toLowerCase() == genreName.toLowerCase(),
      orElse: () => null,
    );
    final genreId = genre["id"];

    setState(() {
      poster_path.clear();
      titles.clear();
      rating.clear();
    });

    for (var result in results) {
      if (result["genre_ids"] != null &&
          result["genre_ids"].contains(genreId)) {
        setState(() {
          poster_path.add(result["poster_path"]);
          titles.add(result["original_title"]);
          rating.add(result["vote_average"]);
        });
      }
    }
  }

  Future<void> Searched_data() async {
    setState(() => is_loading = true);
    try {
      var response = await http.get(Uri.parse(search_uri));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var searched_results = data["results"];
        setState(() {
          poster_path.clear();
          titles.clear();
          rating.clear();
          for (var searched_result in searched_results) {
            poster_path.add(searched_result["poster_path"]);
            titles.add(searched_result["original_title"]);
            rating.add(searched_result["vote_average"]);
          }
        });
      }
    } catch (e) {
      print("Search Error: $e");
    } finally {
      setState(() => is_loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height - kToolbarHeight;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: is_loading?Color(0xff09203f):Color(0xff09203f),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xff27496d),
        foregroundColor: Colors.white,
        title: const Text(
          "FilmDex",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      body: is_loading
          ?  Center(child: buildCoolLoadingIndicator())
          : Container(
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 16),
              child: TextField(
                controller: search_cont,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search Movies",
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon:
                  const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: IconButton(
                    onPressed: () async {
                      setState(() {
                        poster_path.clear();
                        titles.clear();
                        rating.clear();
                        results.clear();
                        page = 1;
                        search_query = search_cont.text.trim();
                        popular_uri = "https://api.themoviedb.org/3/search/movie?query=$search_query&api_key=$api_key&page=$page";
                      });
                      await fetch_data();
                    },
                    icon: const Icon(Icons.arrow_forward_outlined,
                        color: Colors.white),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: height * 0.01),
            SizedBox(
              height: height * 0.07,
              child: ListView.builder(
                itemCount: genres_names.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  String genre = genres_names[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: TextButton(
                      onPressed: () async {
                        setState(() {
                          selectedGenre = genre;
                        });

                        if (genre == "All") {
                          setState(() {
                            poster_path.clear();
                            titles.clear();
                            rating.clear();
                            results.clear();
                            page = 1;
                            popular_uri =
                            "https://api.themoviedb.org/3/movie/popular?api_key=$api_key&page=$page";
                          });
                          await fetch_data();
                        } else {
                          final selected = genres.firstWhere(
                                (g) =>
                            g["name"].toLowerCase() ==
                                genre.toLowerCase(),
                            orElse: () => null,
                          );

                          if (selected != null) {
                            final genreId = selected["id"];
                            final genreUrl =
                                "https://api.themoviedb.org/3/discover/movie?api_key=$api_key&with_genres=$genreId&page=1";
                            setState(() {
                              poster_path.clear();
                              titles.clear();
                              rating.clear();
                              results.clear();
                              popular_uri = genreUrl;
                            });
                            await fetch_data();
                          }
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedGenre == genre
                              ? Colors.deepOrange
                              : const Color(0xff09203f),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Center(
                          child: Text(
                            genre.toUpperCase(),
                            style: TextStyle(
                              fontSize: width > 600
                                  ? width * 0.018
                                  : width * 0.030,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: height * 0.01),

            //Grid inside ListView
            Expanded(
              child: ListView(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent:
                      width > 600 ? width * 0.25 : width * 0.55,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      var movie = results[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Description(
                                backdrop_path: movie["poster_path"],
                                rating: movie["vote_average"],
                                title: movie["original_title"],
                                overview: movie["overview"],
                                date: movie["release_date"],
                                adult: movie["adult"],
                                popularity: movie["popularity"],
                                index: index,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: const Color(0xff537895),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 8,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                  child: Image.network(
                                    image_uri +
                                        (movie["poster_path"] ?? ""),
                                    fit: BoxFit.fill,
                                    width: double.infinity,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                        Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                            children: const [
                                              Icon(Icons.broken_image,
                                                  color: Colors.white,
                                                  size: 40),
                                              SizedBox(height: 5),
                                              Text(
                                                "Could not find image",
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12),
                                                textAlign:
                                                TextAlign.center,
                                              ),
                                            ]),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        movie["original_title"] ??
                                            "Unknown",
                                        style: TextStyle(
                                          fontSize: width > 600
                                              ? width * 0.013
                                              : width * 0.025,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.star_outlined,
                                              size: 18,
                                              color: Colors.yellow),
                                          const SizedBox(width: 4),
                                          Text(
                                            (movie["vote_average"]
                                            is num
                                                ? (movie["vote_average"]
                                            as num)
                                                .toStringAsFixed(
                                                1)
                                                : "0.0")
                                                .toString(),
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Load More Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          page++;
                          popular_uri = "https://api.themoviedb.org/3/movie/popular?api_key=$api_key&page=$page";
                        });
                        fetch_data();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff27496d),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Load More Movies'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
