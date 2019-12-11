import 'package:equatable/equatable.dart';
import 'package:flutter_infinite_list/src/models/Post.dart';
import 'package:meta/meta.dart';

@immutable
abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object> get props => [];
}

/// PostUninitialized- скажет визуализировать индикатор загрузки,
///                    пока загружается начальная партия сообщений
class PostUninitializedState extends PostState {}

/// PostError- сообщит слою презентации, что при получении сообщений произошла ошибка
class PostErrorState extends PostState {}

/// PostLoaded- скажет на уровне представления, что у него есть контент для рендеринга
///     posts- список List<Post> который будем выводить
///     hasReachedMax- сообщит уровню представления,
///                    достигло ли оно максимального количества постов
class PostLoadedState extends PostState {
  final List<Post> posts;
  final bool hasReachedMax;

  // для справки:
  // Смысл конструкторов const не в том, чтобы инициализировать конечные поля,
  // это может сделать любой генерирующий конструктор. Задача состоит в том,
  // чтобы создать постоянные значения времени компиляции: объекты, в которых
  // все значения полей известны уже во время компиляции, без выполнения
  // каких-либо операторов.
  //
  // Это накладывает некоторые ограничения на класс и конструктор. Константный
  // конструктор не может иметь тела (никакие операторы не выполняются!), А в
  // его классе не должно быть никаких неокончательных полей (значение, которое
  // мы «знаем» во время компиляции, не должно быть в состоянии изменить позже)
  //
  // если использовать несколько раз вместо new Class(0,0)
  // const Class(0,0) то это всегда будет только один объект
  // см: https://japhr.blogspot.com/2012/12/dart-constant-constructors.html
  const PostLoadedState({this.posts, this.hasReachedMax});

  /// copyWith, чтобы мы могли скопировать экземпляр PostLoaded
  /// и удобно обновить ноль или более свойств
  PostLoadedState copyWith(List<Post> posts, bool hasReachedMax) =>
      PostLoadedState(
          posts: posts ?? this.posts,
          hasReachedMax: hasReachedMax ?? this.hasReachedMax);

  @override
  List<Object> get props => [posts, hasReachedMax];

  @override
  String toString() =>
      'PostLoaded { posts: ${posts.length}, hasReachedMax: $hasReachedMax }';
}
