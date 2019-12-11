import 'package:equatable/equatable.dart';

// generated File > New > JsonToDartBeanAction
// добавим extends Equatable чтоб можно было сравнивать экзкмпляры класса
// добавим для этого  props и toString на будущее
/// Модель постов в ленте
/// https://jsonplaceholder.typicode.com/posts?_start=0&_limit=5
class Post extends Equatable {
  final int userId;
  final int id;
  final String title;
  final String body;

  const Post({this.body, this.id, this.title, this.userId});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      body: json['body'],
      id: json['id'],
      title: json['title'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['body'] = this.body;
    data['id'] = this.id;
    data['title'] = this.title;
    data['userId'] = this.userId;
    return data;
  }

  @override
  List<Object> get props => [id, title, body, userId];

  @override
  String toString() => 'Post { id: $id, userId: $userId }';


}
