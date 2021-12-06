import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

void main() {
  AppModel model = AppModel();
  runApp(App(
    model: model,
  ));
}

const List<String> urls = [
  'https://cdn.hobbyconsolas.com/sites/navi.axelspringer.es/public/styles/hc_480x270/public/media/image/2021/11/elder-scrolls-v-skyrim-anniversary-edition-2529235.jpg?itok=Azbl2BEW',
  'https://areajugones.sport.es/wp-content/uploads/2021/10/captura-de-pantalla-2021-10-29-a-las-175027-1080x609.jpg',
  'https://media.revistagq.com/photos/617164b3219207ace1a59e20/16:9/w_2560%2Cc_limit/skyrim_bethesda.jpeg',
  'https://i.ytimg.com/vi/ooqdJTYspyo/maxresdefault.jpg'
];

class App extends StatelessWidget {
  final AppModel model;
  const App({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Viewer',
      home: GalleryPage(
        title: 'Image Gallery',
        model: model,
      ),
    );
  }
}

class PhotoState {
  String url;
  bool selected;
  bool display;
  Set<String> tags = {};

  PhotoState(this.url, {this.selected = false, this.display = true, tags});
}

class AppModel {
  Stream<bool> get isTagging => _taggingController.stream;
  Stream<List<PhotoState>> get photoStates => _photoStateController.stream;

  final StreamController<bool> _taggingController =
      StreamController.broadcast();
  final StreamController<List<PhotoState>> _photoStateController =
      StreamController.broadcast();

  AppModel() {
    _photoStateController.onListen = () {
      _photoStateController.add(_photoStates);
    };

    _taggingController.onListen = () {
      _taggingController.add(_isTagging);
    };
  }

  bool _isTagging = false;
  final List<PhotoState> _photoStates =
      List.of(urls.map((url) => PhotoState(url)));

  Set<String> tags = {'all', 'hero', 'dragon', 'emblem'};

  void toggleTagging(String url) {
    _isTagging = !_isTagging;
    for (var element in _photoStates) {
      if (_isTagging && element.url == url) {
        element.selected = true;
      } else {
        element.selected = false;
      }
    }
    _taggingController.add(_isTagging);
    _photoStateController.add(_photoStates);
  }

  void onPhotoSelect(String url, bool selected) {
    for (var element in _photoStates) {
      if (element.url == url) {
        element.selected = selected;
      }
    }
    _photoStateController.add(_photoStates);
  }

  void selectTag(String tag) {
    if (_isTagging) {
      if (tag != "all") {
        for (var element in _photoStates) {
          if (element.selected) {
            element.tags.add(tag);
          }
        }
      }
      toggleTagging('null');
    } else {
      for (var element in _photoStates) {
        element.display = tag == "all" ? true : element.tags.contains(tag);
      }
    }
    _photoStateController.add(_photoStates);
  }
}

class GalleryPage extends StatelessWidget {
  final String title;
  final AppModel model;
  // final _AppState model;

  GalleryPage({required this.title, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: StreamBuilder<List<PhotoState>>(
        initialData: [],
        stream: model.photoStates,
        builder: (context, snapshot) {
          return GridView.count(
            primary: false,
            crossAxisCount: (2),
            children: List.of(snapshot.data! //TODO handle the null
                .where((ps) => ps.display)
                .map((ps) => Photo(
                      state: ps,
                      model: model,
                    ))),
          );
        },
      ),
      drawer: Drawer(
          child: ListView(
        children: List.of(model.tags.map((t) => ListTile(
              title: Text(t),
              onTap: () {
                model.selectTag(t);
                Navigator.of(context).pop();
              },
            ))),
      )),
    );
  }
}

class Photo extends StatelessWidget {
  final PhotoState state;
  final AppModel model;
  // final _AppState model;

  Photo({required this.state, required this.model});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        initialData: false,
        stream: model.isTagging,
        builder: (context, snapshot) {
          List<Widget> children = [
            GestureDetector(
                child: Image.network(state.url),
                onLongPress: () => model.toggleTagging(state.url))
          ];

          if (snapshot.data!) {
            children.add(Positioned(
                left: 20,
                top: 0,
                child: Theme(
                    data: Theme.of(context)
                        .copyWith(unselectedWidgetColor: Colors.grey[200]),
                    child: Checkbox(
                      onChanged: (value) {
                        model.onPhotoSelect(state.url, value ?? false);
                      },
                      value: state.selected,
                      activeColor: Colors.grey.shade200,
                      checkColor: Colors.black,
                    ))));
          }
          return Container(
              padding: EdgeInsets.all(10),
              child: Stack(alignment: Alignment.center, children: children));
        });
  }
}
