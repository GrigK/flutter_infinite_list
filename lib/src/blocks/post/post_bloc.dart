import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import './bloc.dart';
import 'package:flutter_infinite_list/src/models/post.dart';

/// Для простоты наш PostBloc будет иметь прямую зависимость от http-клиента;
/// однако в производственном приложении вы можете вместо этого внедрить
/// клиент API и использовать шаблон хранилища.
/// https://bloclibrary.dev/#/./architecture
class PostBloc extends Bloc<PostEvent, PostState> {
  final http.Client httpClient;

  PostBloc({@required this.httpClient});

  @override
  PostState get initialState => PostUninitializedState();

  @override
  Stream<PostState> mapEventToState(PostEvent event,) async* {
    final currentState = state;

    if (event is FetchEvent && !_hasReachedMax(currentState)) {
      // если текущее событие - загрузка списка
      try {
        if (currentState is PostUninitializedState) {
          // при первом запуске прочтем первые 20 записей
          final posts = await _fetchPosts(0, 20);
          yield PostLoadedState(posts: posts, hasReachedMax: false);
        } else if (currentState is PostLoadedState) {
          // при последующих вызовах читаем следующие 20 записей
          final List<Post> posts = await _fetchPosts(currentState.posts.length, 20);
          // если больше не прочли - отметим это в [hasReachedMax]
          yield posts.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              // будем добавлять к текущему списку постов. Все равно их только 100
              : PostLoadedState(posts: [...currentState.posts, ...posts], hasReachedMax: false);
        }
      } catch (e) {
        // если ошибка загрузки - сообщить об этом
        yield PostErrorState(e.toString());
      }
    }
  }


  /// отменить события, чтобы избежать ненужного спама в нашем API.
  /// Переопределение transform позволяет нам преобразовать поток перед
  /// вызовом mapEventToState. Это позволяет применять такие операции, как
  /// distinct(), debounceTime() и т. д.
  @override
  Stream<PostState> transformEvents(Stream<PostEvent> events,
      Stream<PostState> next(PostEvent event)) {
    return super.transformEvents(
        (events as Observable<PostEvent>).debounceTime(
          Duration(milliseconds: 500),
        ), next);
  }

  /// истина если загрузились посты и достигнут максимум
  bool _hasReachedMax(PostState state) =>
      state is PostLoadedState && state.hasReachedMax;

  /// пока простое использование - читаем посты здесь же в блоке
  /// при усложнении приложения надо вывести в отдельный слой данных
  Future<List<Post>> _fetchPosts(int startIndex, int limit) async {
    final response = await httpClient.get(
        'https://jsonplaceholder.typicode.com/posts?_start=$startIndex&_limit=$limit');
    List<Post> ret = [];

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;

      ret = data.map((rawPost) {
        return Post(
            id: rawPost['id'],
            userId: rawPost['userId'],
            title: rawPost['title'],
            body: rawPost['body']);
      }).toList();
    } else {
      print("error fetching posts: ${response.statusCode}");
      throw Exception("error fetching posts: ${response.statusCode}");
    }

    return ret;
  }
}
