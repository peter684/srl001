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

  Todo.fromDocumentSnapshot(DocumentSnapshot doc)
      : this.fromMap(doc.data, reference: doc.reference);


  @override
  String toString() =>
      "Todo<key: $key user: $userId: sub: $subject completed: $completed>";
}
