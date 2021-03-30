import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttils/fluttils.dart';

/// A text that provides a [TextStyle] from a list of attributes.
///
/// The available attributes are color, fontWeight, fontSize, fontStyle,
/// locale and decoration.
///
/// The following usages are equivalent:
///
/// ```
/// Text text;
///
/// text = Text("weight", style: TextStyle(fontWeight: FontWeight.bold));
/// text = StyledText("weight", [FontWeight.bold]);
///
/// text = Text("color and size", style: TextStyle(color: Colors.red, fontSize: 24));
/// text = StyledText("color and size", [Colors.red, 24]);
/// ```
class StyledText extends Text {
  static TextStyle _styleFrom(List<Object> attributes) {
    final List<Object> args = List.generate(5, (_) => null);
    for (Object attribute in attributes) {
      int i;
      if (attribute is FontWeight)
        i = 0;
      else if (attribute is Color)
        i = 1;
      else if (attribute is num)
        i = 2;
      else if (attribute is TextDecoration)
        i = 3;
      else if (attribute is Locale)
        i = 4;
      else
        continue;

      args[i] = attribute;
    }

    return TextStyle(
      fontWeight: args[0] as FontWeight,
      color: args[1] as Color,
      fontSize: args[2] as num,
      decoration: args[3] as TextDecoration,
      locale: args[4] as Locale,
    );
  }

  /// Creates a [StyledText].
  ///
  /// If there are duplicated types in [attributes], the last one will be used.
  /// If there are unsupported types in [attributes] (such as boolean), they
  /// will be ignored.
  StyledText(String text, List<Object> attributes, {TextAlign align})
      : super(text, style: _styleFrom(attributes), textAlign: align);
}

/// A [FutureBuilder] that displays a progress indicator while its connection
/// state is not done.
///
/// The widget provided by [builder] will only be displayed when the connection
/// state is equal to [ConnectionState.done].
///
/// The progress indicator can be changed using the [indicator] parameter
/// (defaults to [CircularProgressIndicator]).
class SimpleFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final T initialData;
  final Widget Function(T) builder;
  final Widget indicator;

  const SimpleFutureBuilder(
      {Key key,
      @required this.future,
      @required this.builder,
      this.indicator = const CircularProgressIndicator(),
      this.initialData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      initialData: initialData,
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return indicator;
        final T data = snapshot.data;
        return builder(data);
      },
    );
  }
}

/// A [StreamBuilder] that displays a progress indicator while its connection
/// state is waiting.
///
/// The widget provided by [builder] will only be displayed when the connection
/// state is equal to [ConnectionState.done], [ConnectionState.active] or
/// [ConnectionState.none].
///
/// The progress indicator can be changed using the [indicator] parameter
/// (defaults to [CircularProgressIndicator]).
class SimpleStreamBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  final T initialData;
  final Widget Function(T) builder;
  final Widget indicator;

  const SimpleStreamBuilder(
      {Key key,
      @required this.stream,
      @required this.builder,
      this.initialData,
      this.indicator = const CircularProgressIndicator()})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      initialData: initialData,
      builder: (context, snapshot) {
        if (snapshot.data == ConnectionState.waiting) return indicator;
        final T data = snapshot.data;
        return builder(data);
      },
    );
  }
}

/// A [Padding] that combines [EdgeInsets.only], [EdgeInsets.symmetric] and
/// [EdgeInsets.all] as values.
class SimplePadding extends Padding {
  static EdgeInsetsGeometry _calculatePadding(List<double> heap) {
    assert(heap.length == 7);
    final List<double> values = [];
    for (int i = heap.length - 4; i < heap.length; i++) {
      int vi = i;
      while (vi >= 0 && heap[vi] == null) {
        if (vi == 0) {
          vi = null;
          break;
        }
        vi = (vi - 1) ~/ 2;
      }

      values.add(vi == null ? 0 : heap[vi]);
    }

    return EdgeInsets.only(
      left: values[0],
      right: values[1],
      top: values[2],
      bottom: values[3],
    );
  }

  /// Creates a [SimplePadding].
  ///
  /// Parameters work as a tree-like structure, where [all] is the root node,
  /// [width] and [height] are children of [all], [left] and [right] are children
  /// of [width] and [top] and [bottom] are children of [height].
  ///
  /// To get the padding of a parameter, its value will be checked. If it's not
  /// null, its value is returned, otherwise the padding of its parent will be
  /// returned. If this parameter has no parent, its padding will be zero.
  /// Using [left] as example:
  ///
  /// ```dart
  /// double padding;
  /// if (left == null) {
  ///   // width is left's parent
  ///   if (width == null) {
  ///     // all is width's parent
  ///     padding = all ?? 0;
  ///   } else {
  ///     padding = width;
  ///   }
  /// } else {
  ///   padding = left;
  /// }
  /// left = padding;
  /// ```
  ///
  /// That being said, the following usages are equivalent:
  ///
  /// ```
  /// Padding p;
  ///
  /// p = SimplePadding(all: 5);
  /// p = Padding(padding: EdgeInsets.all(5));
  ///
  /// p = SimplePadding(width: 2, height: 3);
  /// p = Padding(padding: EdgeInsets.symmetric(horizontal: 2, vertical: 3));
  ///
  /// p = SimplePadding(left: 1, top: 4);
  /// p = Padding(padding: EdgeInsets.only(left: 1, top: 4));
  ///
  /// p = SimplePadding(all: 5, right: 3);
  /// p = Padding(padding: EdgeInsets.only(left: 5, right: 3, top: 5, bottom: 5));
  ///
  /// p = SimplePadding(all: 10, width: 20, top: 5);
  /// p = Padding(padding: EdgeInsets.only(left: 20, top: 5, right: 20, bottom: 10));
  /// ```
  SimplePadding(
      {@required Widget child,
      double all,
      double width,
      double height,
      double left,
      double right,
      double top,
      double bottom})
      : super(
            child: child,
            padding: _calculatePadding(
                [all, width, height, left, right, top, bottom]));
}

/// A widget that hides or show a [child] widget.
///
/// If [isVisible] is false, the size, state and animation of the widget will be
/// maintained.
class SimpleVisibility extends StatelessWidget {
  final Widget child;
  final bool isVisible;

  SimpleVisibility({Key key, this.isVisible = true, @required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isVisible) return child;
    return Visibility(
      child: child,
      visible: false,
      maintainSize: true,
      maintainState: true,
      maintainAnimation: true,
    );
  }
}

/// A splash screen used for loading purposes.
///
/// If [init] ends first than [duration], then the duration of the splash will
/// be [duration], otherwise it will be the execution time of [init].
///
/// To just show some content, use [SimpleSplashScreen].
class SplashScreen extends StatefulWidget {
  /// The minimum duration of this splash.
  final Duration duration;

  /// The widget that will appear during the splash.
  final Widget content;

  /// The widget that will replace the splash after it's done.
  final WidgetBuilder builder;

  /// The initialization that should be done during the splash.
  final Future<void> init;

  const SplashScreen(
      {Key key,
      this.duration = const Duration(seconds: 3),
      this.content,
      this.builder,
      @required this.init})
      : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([Future.delayed(widget.duration), widget.init]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done)
          asap(() => Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: widget.builder)));

        return widget.content;
      },
    );
  }
}

/// A simple splash screen that shows some content.
///
/// To use a splash screen for loading purposes, use [SplashScreen].
class SimpleSplashScreen extends SplashScreen {
  /// Creates a [SimpleSplashScreen].
  SimpleSplashScreen(
      {Key key,
      Duration duration = const Duration(seconds: 3),
      @required Widget content,
      WidgetBuilder builder})
      : super(
            key: key,
            duration: duration,
            content: content,
            builder: builder,
            init: Future.delayed(Duration.zero));
}

/// A widget that hides the soft keyboard by clicking outside of a [TextField]
/// or anywhere on the screen.
class TapOutsideToUnfocus extends StatelessWidget {
  final Widget child;

  const TapOutsideToUnfocus({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: child,
    );
  }
}

/// A [ListView] that creates its children on demand.
///
/// A simple [ListView.builder].
class OnDemandListView<T> extends StatelessWidget {
  /// The original values to be transformed into children of this list.
  final List<T> values;

  /// The transform to be applied to each value in the [values], where
  /// its arguments are the context, the index and the value.
  final Widget Function(BuildContext, int, T) onBuild;

  /// See `shrinkWrap` parameter of [ListView.builder].
  final bool shrinkWrap;

  /// Creates a on-demand [ListView] from a list of widgets.
  static OnDemandListView<Widget> from(List<Widget> widgets,
          {bool shrinkWrap = false}) =>
      OnDemandListView._(widgets,
          onBuild: (_, __, widget) => widget, shrinkWrap: shrinkWrap);

  /// Creates a on-demand [ListView] using each index and value from [values].
  const OnDemandListView._(this.values,
      {Key key, this.onBuild, this.shrinkWrap = false})
      : super(key: key);

  /// Creates a on-demand [ListView] using each index and value from [values].
  const OnDemandListView.indexed(
      List<T> values, Widget Function(BuildContext, int, T) onBuild,
      {bool shrinkWrap = false})
      : this._(values, onBuild: onBuild, shrinkWrap: shrinkWrap);

  /// Creates a on-demand [ListView] using each value from [values].
  OnDemandListView.mapped(
      List<T> values, Widget Function(BuildContext, T) onBuild,
      {bool shrinkWrap = false})
      : this._(values,
            onBuild: (context, _, value) => onBuild(context, value),
            shrinkWrap: shrinkWrap);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: shrinkWrap,
      itemCount: values.length,
      itemBuilder: (context, i) => onBuild(context, i, values[i]),
    );
  }
}
