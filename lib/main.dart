import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(App());
}

const List<String> urls = [
  'https://cdn.hobbyconsolas.com/sites/navi.axelspringer.es/public/styles/hc_480x270/public/media/image/2021/11/elder-scrolls-v-skyrim-anniversary-edition-2529235.jpg?itok=Azbl2BEW',
  'https://areajugones.sport.es/wp-content/uploads/2021/10/captura-de-pantalla-2021-10-29-a-las-175027-1080x609.jpg',
  'https://media.revistagq.com/photos/617164b3219207ace1a59e20/16:9/w_2560%2Cc_limit/skyrim_bethesda.jpeg',
  'https://i.ytimg.com/vi/ooqdJTYspyo/maxresdefault.jpg'
];

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class PhotoState {
  String url;
  bool selected;
  bool display;
  Set<String> tags = {};

  PhotoState(this.url, {this.selected = false, this.display = true, tags});
}

class _AppState extends State<App> {
  bool isTagging = false;
  Set<String> tags = {'all', 'hero', 'dragon', 'emblem'};

  List<PhotoState> photoStates = List.of(urls.map((url) => PhotoState(url)));

  void selectTag(String tag) {
    setState(() {
      if (isTagging) {
        if (tag != "all") {
          photoStates.forEach((element) {
            if (element.selected) {
              element.tags.add(tag);
            }
          });
        }
        toggleTagging('null');
      } else {
        photoStates.forEach((element) {
          element.display = tag == "all" ? true : element.tags.contains(tag);
        });
      }
    });
  }

  void toggleTagging(String url) {
    setState(() {
      isTagging = !isTagging;
      for (var element in photoStates) {
        if (isTagging && element.url == url) {
          element.selected = true;
        } else {
          element.selected = false;
        }
      }
    });
  }

  void onPhotoSelect(String url, bool selected) {
    setState(() {
      for (var element in photoStates) {
        if (element.url == url) {
          element.selected = selected;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Viewer',
      home: GalleryPage(
          title: 'Image Gallery',
          photoStates: photoStates,
          tags: tags,
          tagging: isTagging,
          toggleTagging: toggleTagging,
          selectTag: selectTag,
          onPhotoSelected: onPhotoSelect),
    );
  }
}

class GalleryPage extends StatelessWidget {
  final String title;
  final List<PhotoState> photoStates;
  final bool tagging;
  final Set<String> tags;

  final Function toggleTagging;
  final Function onPhotoSelected;
  final Function selectTag;

  GalleryPage({
    required this.title,
    required this.photoStates,
    required this.tags,
    required this.tagging,
    required this.toggleTagging,
    required this.selectTag,
    required this.onPhotoSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: GridView.count(
        primary: false,
        crossAxisCount: (2),
        children:
            List.of(photoStates.where((ps) => ps.display).map((ps) => Photo(
                  state: ps,
                  selectable: tagging,
                  onLongPress: toggleTagging,
                  onSelect: onPhotoSelected,
                ))),
      ),
      drawer: Drawer(
          child: ListView(
        children: List.of(tags.map((t) => ListTile(
              title: Text(t),
              onTap: () {
                selectTag(t);
                Navigator.of(context).pop();
              },
            ))),
      )),
    );
  }
}

class Photo extends StatelessWidget {
  final PhotoState state;
  final bool selectable;

  final Function onLongPress;
  final Function onSelect;

  Photo(
      {required this.state,
      required this.selectable,
      required this.onLongPress,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      GestureDetector(
          child: Image.network(state.url),
          onLongPress: () => onLongPress(state.url))
    ];
    if (selectable) {
      children.add(Positioned(
          left: 20,
          top: 0,
          child: Theme(
              data: Theme.of(context)
                  .copyWith(unselectedWidgetColor: Colors.grey[200]),
              child: Checkbox(
                onChanged: (value) {
                  onSelect(state.url, value);
                },
                value: state.selected,
                activeColor: Colors.grey.shade200,
                checkColor: Colors.black,
              ))));
    }

    return Container(
        padding: EdgeInsets.all(10),
        child: Stack(alignment: Alignment.center, children: children));
  }
}
