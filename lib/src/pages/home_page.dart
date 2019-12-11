import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_infinite_list/src/blocks/post/post_bloc.dart';
import 'package:flutter_infinite_list/src/blocks/post/post_event.dart';
import 'package:flutter_infinite_list/src/blocks/post/post_state.dart';
import 'package:flutter_infinite_list/src/blocks/theme_block.dart';

import 'package:flutter_infinite_list/generated/i18n.dart';

import 'package:flutter_infinite_list/src/widgets/bottom_loader.dart';
import 'package:flutter_infinite_list/src/widgets/post_widget.dart';

/// StatefulWidget т.к. надо поддерживать ScrollController
class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final double _scrollThreshold = 200.0;
  PostBloc _postBloc;

  @override
  void initState() {
    super.initState();
    // добавим подписчика контроллеру списка
    // чтоб следить за прокруткой
    _scrollController.addListener(_onScroll);
    _postBloc = BlocProvider.of<PostBloc>(context);
  }

  @override
  void dispose() {
    // важно удалить за собой ScrollController
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).titlePosts),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.cached),
                onPressed: () {
                  _postBloc.add(FetchEvent());
                  setState(() { });
                }),
            IconButton(
                icon: Icon(Icons.brightness_medium),
                onPressed: () {
                  // Используем глобальный BLoC (смена темы)
                  BlocProvider.of<ThemeBloc>(context).add(ThemeEvent.toggle);
                }),
            SizedBox(
              width: 16.0,
            )
          ],
        ),
        // BlocBuilder будет вызывать builder на каждое новое состояние BLoC
        body: BlocBuilder<PostBloc, PostState>(builder: _bodyScroll));
  }

  Widget _bodyScroll(BuildContext context, PostState state) {
    if (state is PostUninitializedState) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (state is PostErrorState) {
      print(state.err);
      return Center(
        child: Text(S.of(context).failLoadPost),
      );
    }
    if (state is PostLoadedState) {
      if (state.posts.isEmpty) {
        return Center(
          child: Text(S.of(context).noPosts),
        );
      }
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return index >= state.posts.length
              ? BottomLoader()
              : PostWidget(post: state.posts[index]);
        },
        itemCount:
            state.hasReachedMax ? state.posts.length : state.posts.length + 1,
        controller: _scrollController,
      );
    }
  }

  /// проверяем если прокрытка дошла почти до конца
  /// то инициируем событие загрузки следующих постов
  void _onScroll() {
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= _scrollThreshold) {
      _postBloc.add(FetchEvent());
    }
  }
}
