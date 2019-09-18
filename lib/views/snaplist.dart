import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:snaplist/snaplist.dart';
import 'package:strings/strings.dart';

import '../models/models.dart';

typedef void LoadMore(int center);
typedef void SelectedIndex(int index);

class PeopleSpanlist extends StatelessWidget {
  final List<People> items;
  final SnaplistController controller;
  final int initialIndex;
  final LoadMore loadMore;
  final bool isError;
  @required final Widget errorMessage;
  const PeopleSpanlist({Key key, this.items, this.controller, this.initialIndex, this.loadMore, this.isError = false, this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance
      .addPostFrameCallback((_) => controller.setPosition(initialIndex));
    final Size cardSize = Size(MediaQuery.of(context).size.width - 60, MediaQuery.of(context).size.height);
    return SnapList(
      padding: EdgeInsets.symmetric(
        horizontal: 30.0,
        vertical: 30.0
      ),
      sizeProvider: (index, data) => cardSize,
      separatorProvider: (index, data) => Size(15.0, 15.0),
      positionUpdate: (int index) {
        if (index == items.length - 1) {
          print(items.length - 1);
          print(index);
          loadMore(index);
        }
      },
      snaplistController: controller,
      count: items.length,
      builder: (context, index, data) {
        return ClipRRect(
          borderRadius: new BorderRadius.circular(16.0),
          child: Container(
            color: Colors.white,
            child: new CustomScrollView(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate([
                    (index < items.length - 1) ? new Column(
                      children: <Widget>[
                        new Container(
                          height: 350,
                          child: new SizedBox.expand(
                            child: new Image.network(
                              items[index].picture.large,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        new Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: new Text(
                            capitalize(items[index].name.first) + ' ' + capitalize(items[index].name.last),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                        new ListView.builder(
                          padding: EdgeInsets.only(top: 15.0),
                          itemCount: 1,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Column(
                              children: <Widget>[
                                new ListTile(
                                  title: new Text('Address:'),
                                  subtitle: new Text(items[index].location.street + ', ' + items[index].location.postcode.toString() + ' ' + items[index].location.city + ' ' + items[index].location.state),
                                ),
                                new ListTile(
                                  title: new Text('Email:'),
                                  subtitle: new Text(items[index].email),
                                ),
                                new ListTile(
                                  title: new Text('Phone:'),
                                  subtitle: new Text(items[index].phone),
                                ),
                              ],
                            );
                          },
                        )
                      ]
                    ) : new Center(
                      child: isError ? errorMessage : new CircularProgressIndicator(),
                    )
                  ])
                )
              ],
            )
          )
        );
      },
    );
  }
}