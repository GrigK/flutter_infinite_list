import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import './generated/i18n.dart';
import './src/blocks/simple_bloc_delegate.dart';
import './src/blocks/theme_block.dart';


void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeBloc>(
      create: (context) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeData>(
        builder: (context, theme) {
          /// ThemeBloc - это глобальный BLoC
          /// доступный из любого места MaterialApp через
          /// BlocProvider.of<ThemeBloc>(context)
          return MaterialApp(
            localizationsDelegates: [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              DefaultCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
//            localeResolutionCallback: S.delegate.resolution(fallback: new Locale("en", "")),

            onGenerateTitle: (context) => S.of(context).appName,
            home: BlocProvider(
              create: (context) => TimerBloc(context, ticker: Ticker()),
              child: TimerPage(),
            ),
            theme: theme,
          );
        },
      ),
    );
  }
}
