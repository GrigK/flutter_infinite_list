import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

/// Блок должен реагировать на прокрутку - добавлять больше постов
@immutable
abstract class PostEvent extends Equatable {

  @override
  List<Object> get props => [];
}

// событие - прокрутка списка
class FetchEvent extends PostEvent {}