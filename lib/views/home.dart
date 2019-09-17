// package
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_application/models/models.dart';
import 'package:test_application/modules/http.client.dart';
import 'package:strings/strings.dart';

class HomePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {

  CustomHttpClient httpClient = new CustomHttpClient();
  ScrollController _scrollController = new ScrollController();
  List<People> arrayPeople = [];
  bool isLoaded = false;
  bool isError = false;
  int count = 10;

  @override
  void initState() {
    super.initState();
    getPeople();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoaded = false;
        });        
        getPeople();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getPeople() {
    httpClient.getPeople(count).then((res) {
      List responseJson = res['results'];
      setState(() {
        var items = responseJson.map((m) => new People.fromJson(m)).toList();
        arrayPeople = []..addAll(arrayPeople)..addAll(items);
        isLoaded = true;
      });
    }).catchError((onError) {
      setState(() {
        isLoaded = true;
        isError = true;
      });
    });
  }

  _getMoreInformatino(item) {
    print(item);
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
                _getMoreInformatino(item);
              }
            ),
          ),
          new Divider(),
        ]
      ),
    );
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
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: new SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: new Column(
          children: <Widget>[
            new Expanded(
              child: new ListView(
                controller: _scrollController,
                children: listPeople.toList(),
              )
            ),
            !isLoaded ? new Container(
              padding: const EdgeInsets.only(top: 30, bottom: 30),
              child: new CircularProgressIndicator()
            ) : new Container(),
            isError ? new Container(
              child: new Column(
                children: <Widget>[
                  new Text('Произошла ошибка'),
                  new FlatButton(
                    child: new Text('Повторить'),
                    textColor: Colors.blue,
                    onPressed: () {
                      setState(() {
                        isLoaded = false;
                        isError = false;
                      });
                      getPeople();
                    },
                  )
                ],
              ),
            ) : new Container()
          ]
        )
      )
    );
  }
}