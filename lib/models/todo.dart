//import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String key;
  String subject;
  bool completed;
  String userId;
  DocumentReference reference;

  Todo(this.subject, this.userId, this.completed);

  Todo.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['key'] != null),
        assert(map['subject'] != null),
        assert(map['completed'] != null),
        assert(map['userId'] != null),
        key = map['key'],
        subject = map['subject'],
        completed = map['completed'],
        userId = map['userId'];

  Todo.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() =>
      "Todo<key: $key user: $userId: sub: $subject completed: $completed>";
}
