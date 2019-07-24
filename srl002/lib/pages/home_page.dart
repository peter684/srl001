import 'package:flutter/material.dart';
import 'package:srl002/services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:srl002/models/todo.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.authenticator, this.rootPageState})
      : super(key: key);

  final Authenticator authenticator;
  final State rootPageState;


  @override
  State<StatefulWidget> createState() => new _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();


  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('todo').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          return _buildList(context, snapshot.data.documents);
        }
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> documents) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: documents.map((doc) => _buildListItem(context, doc)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot doc) {
    final record = Todo.fromDocumentSnapshot(doc);
    return Padding(
      key: ValueKey(record.subject),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.subject),
          trailing: Checkbox(value: record.completed, onChanged: null,),
          onTap: () => Firestore.instance.runTransaction((transaction) async {
            final freshSnapshot = await transaction.get(record.reference);
            final fresh = Todo.fromDocumentSnapshot(freshSnapshot);
            await transaction
                .update(record.reference, {'completed': !fresh.completed});
          }),
        ),
      ),
    );
  }


   _signOut() async {
    try {
      await widget.authenticator.signOut();
      widget.rootPageState.setState(() {
        var s = widget.authenticator.authStatus.toString()+' '+widget.authenticator.userId;
        print(" signed out: auth.status: $s");
      });

    } catch (e) {
      print(e);
    }
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("You\'re in"),
          content: new Text("Yeheee!!"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK,OK. I get it."),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Flutter login demo'),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: _signOut)
          ],
        ),
        body: _buildBody(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAlertDialog();
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        )
    );
  }
}
