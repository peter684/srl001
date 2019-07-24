import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

class _Home extends State<StatefulWidget> {
  var _totalDocs = 0;
  var _queriedDocs = 0;
  var _interactionCount = 0;
  final _myContr = TextEditingController();
  final _getContr = TextEditingController();
  final _myUpdateContr = TextEditingController();
  bool _switchOnOff = false;
  var _listener;
  var _transactionListener;

  void initState() {
    super.initState();
    _transactionListener = Firestore.instance
        .collection('stats')
        .document('interactions')
        .snapshots()
        .listen((data) => transactionListenerUpdate(data));
  }

  @override
  void dispose() {
    _myContr.dispose();
    _getContr.dispose();
    _myUpdateContr.dispose();
    _transactionListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore demo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Text('Nr of interactions: $_interactionCount'),
            ),
            Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                  controller: _myContr,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: 'Enter text'),
                )),
                RaisedButton(
                  onPressed: clickWrite,
                  child: Text('Write text to db'),
                )
              ],
            ),
            Divider(),
            Center(
              child: Text('get nr of docs with text $_queriedDocs'),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _getContr,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Enter Text'),
                  ),
                ),
                RaisedButton(
                  child: const Text('Query db'),
                  onPressed: clickGet,
                ),
              ],
            ),
            Divider(),
            Center(child: Text('Documents in Store: $_totalDocs')),
            Row(
              children: <Widget>[
                Expanded(child: Text('Turn on Listener')),
                Switch(
                    value: _switchOnOff,
                    onChanged: (val) {
                      switchListener(val);
                    }),
              ],
            ),
            Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('docs').snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}.');
                  }
                  if (!snapshot.hasData) {
                    return Container();
                  } else {
                    return ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          final item = snapshot.data.documents[index];
                          final itemID =
                              snapshot.data.documents[index].documentID;
                          final list = snapshot.data.documents;
                          var s = item.data["text"];
                          if (s == null) {
                            s = "empty";
                          }
                          return Dismissible(
                            key: Key(itemID),
                            onDismissed: (direction) {
                              removeFromDb(itemID);
                              setState(() {
                                list.removeAt(index);
                              });
                            },
                            background: Container(color: Colors.red),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: ListTile(
                                    title: Text(s),
                                  ),
                                ),
                                RaisedButton(
                                  child: const Text('Edit'),
                                  onPressed: () {
                                    clickEdit(item);
                                  },
                                ),
                              ],
                            ),
                          );
                        });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void clickWrite() async {
    if (_myContr.text.isNotEmpty) {
      await Firestore.instance
          .collection('docs')
          .document()
          .setData({'text': _myContr.text}); //add new document with title 'text'

      interact();
    }
  }

  void clickEdit(item) {
    _myUpdateContr.text = item['text'];
    showDialog(
        context: context,
        builder: (_) => SimpleDialog(
              title: Text('Edit text'),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _myUpdateContr,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter new Text!'),
                        ),
                      ),
                      RaisedButton(
                        color: Colors.orange,
                        textColor: Colors.white,
                        splashColor: Colors.orangeAccent,
                        child: const Text('Update'),
                        onPressed: () {
                          clickUpdate(item);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ));
  }

  void clickGet() async {

    if (_getContr.text.isNotEmpty) {
      var query = await Firestore.instance
          .collection('docs')
          .where('text', isEqualTo: _getContr.text)
          .getDocuments();
      setState(() {
        _queriedDocs = query.documents.length;
      });
      interact();

    }
  }

  void removeFromDb(itemID) async {
    await Firestore.instance
        .collection('docs')
        .document(itemID)
        .delete();
    interact();
  }

  void clickUpdate(item) async {
    await Firestore.instance
        .collection('docs')
        .document(item.documentID)
        .updateData({'text': _myUpdateContr.text});
    interact();
    Navigator.pop(context);
  }

  void switchListener(isOn) async {
    bool switcher;
    if (isOn) {
      switcher=true;
      _listener = Firestore.instance.collection('docs')
      .snapshots()
      .listen((data)=> listenerUpdate(data));
   }
    else {
      switcher=false;
      await _listener.cancel();
    }

    setState(() {
      _switchOnOff = switcher;
    });
  }

  void listenerUpdate(data) {
    var number = data.documents.length;
    setState(() {
      _totalDocs = number;
    });
  }

  void transactionListenerUpdate(data) {
    var number = data['count'];
    setState(() {
      _interactionCount = number;
    });
  }

  void interact() async {
    final DocumentReference postRef =
        Firestore.instance.collection('stats').document('interactions');
    await Firestore.instance.runTransaction((Transaction tx) async {
      DocumentSnapshot postSnapshot = await tx.get(postRef);
      if (postSnapshot.exists) {
        await tx.update(postRef,
            <String, dynamic>{'count': postSnapshot.data['count'] + 1});
      }
    });
  }
}

