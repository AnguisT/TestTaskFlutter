// package
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snaplist/snaplist_controller.dart';
import 'package:test_application/models/models.dart';
import 'package:test_application/modules/http.client.dart';
import 'package:strings/strings.dart';
import 'package:test_application/views/snaplist.dart';

class HomePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {

  CustomHttpClient httpClient = new CustomHttpClient();
  ScrollController _scrollController = new ScrollController();
  SnaplistController _snaplistController = new SnaplistController();
  List<People> arrayPeople = [];
  bool refresingBottom = false;
  bool errorBottom = false;
  bool isLoad = false;
  bool isError = false;
  bool isDetail = false;
  bool spanListError = false;
  int count = 10;
  int initalIndex = 0;
  int indexSelect = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoad = true;
    });
    getPeople();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        setState(() {
          refresingBottom = true;
        });
        getPeopleBottom();
      }
    });
  }

  getPeople() async {
    await httpClient.getPeople(count).then((res) {
      List responseJson = res['results'];
      setState(() {
        List<People> items = responseJson.map((m) => new People.fromJson(m)).toList();
        arrayPeople = []..addAll(arrayPeople)..addAll(items);
        isLoad = false;
      });
    }).catchError((onError) {
      setState(() {
        isLoad = false;
        isError = true;
      });
    });
  }

  getPeopleBottom() async {
    await httpClient.getPeople(count).then((res) {
      List responseJson = res['results'];
      setState(() {
        List<People> items = responseJson.map((m) => new People.fromJson(m)).toList();
        arrayPeople = []..addAll(arrayPeople)..addAll(items);
        refresingBottom = false;
        errorBottom = false;
      });
    }).catchError((onError) {
      setState(() {
        refresingBottom = false;
        errorBottom = true;
      });
    });
  }

  _getMoreInformatino(item, index) {
    setState(() {
      initalIndex = index;
      isDetail = true;
    });
  }

  Widget errorMessage() {
    return new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Text('Произошла ошибка'),
          new FlatButton(
            child: new Text('Повторить'),
            textColor: Colors.blue,
            onPressed: () {
              setState(() {
                isLoad = true;
                isError = false;
              });
              getPeople();
            },
          )
        ],
      ),
    );
  }

  Widget errorMessageBottom() {
    return new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Text('Произошла ошибка'),
          new FlatButton(
            child: new Text('Повторить'),
            textColor: Colors.blue,
            onPressed: () {
              setState(() {
                refresingBottom = true;
                errorBottom = false;
              });
              getPeopleBottom();
            },
          )
        ],
      ),
    );
  }

  Widget buildListPeople(BuildContext context, People item) {
    return new MergeSemantics(
      child: new Column(
        children: <Widget>[
          new Container(
            child: new ListTile(
              title: new Text(
                capitalize(item.name.first) + ' ' + capitalize(item.name.last)
              ),
              subtitle: new Text(item.location.street + ', ' + item.location.postcode.toString() + ' ' + item.location.city + ' ' + item.location.state),
              leading: new Image.network(item.picture.thumbnail),
              onTap: () {
                var index = arrayPeople.indexOf(item);
                _getMoreInformatino(item, index);
              }
            ),
          ),
          new Divider(),
        ]
      ),
    );
  }

  _loadMorePeople(int index) {
    print('Start');
    httpClient.getPeople(count).then((res) {
      if (res == "Error") {
        setState(() {
          initalIndex = index;
          spanListError = true;
        });
      } else {
        List responseJson = res['results'];
        setState(() {
          spanListError = false;
          var items = responseJson.map((m) => new People.fromJson(m)).toList();
          initalIndex = index;
          arrayPeople = []..addAll(arrayPeople)..addAll(items);
        });
        print('End');
      }
    }).catchError((onError) {
      print('error');
    });
  }

  @override
  Widget build(BuildContext context) {
    Iterable<Widget> listPeople = arrayPeople.map((People item) => buildListPeople(context, item));

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          "Home",
          style: new TextStyle(
            color: Colors.white,
            fontSize: 16.0
          )
        ),
        actions: <Widget>[
          isDetail ? new IconButton(
            icon: Icon(Icons.close),
            color: Colors.white,
            onPressed: () {
              setState(() {
                isDetail = false;
              });
            },
          ) : new Container()
        ],
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: new SafeArea(
        child: (isError || isLoad) ? new Center(
          child: isLoad ? new CircularProgressIndicator() : errorMessage(),
        ) : new Stack (
          children: [
            new Column(
              children: <Widget>[
                new Expanded(
                  child: new ListView(
                    controller: _scrollController,
                    children: listPeople.toList(),
                  ),
                ),
                refresingBottom ? new Container(
                  padding: const EdgeInsets.only(top: 30, bottom: 30),
                  child: new CircularProgressIndicator()
                ) : new Container(),
                errorBottom ? errorMessageBottom() : new Container(),
              ],
            ),
            isDetail ? new BackdropFilter(
              filter: new ImageFilter.blur(
                sigmaX: 5, sigmaY: 5
              ),
              child: new PeopleSpanlist(
                controller: _snaplistController,
                items: arrayPeople,
                initialIndex: initalIndex,
                loadMore: (int index) {
                  setState(() {
                    initalIndex = index;
                  });
                  this._loadMorePeople(index);
                },
                isError: spanListError,
                errorMessage: errorMessage(),
              )
            ) : new Container()
          ]
        )
      )
    );
  }
}