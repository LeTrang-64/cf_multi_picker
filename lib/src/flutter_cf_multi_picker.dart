import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';



const bool __printDebug = false;

/// Picker selected callback.
typedef PickerSelectedCallback = void Function(
    Picker picker, int index, List<int> selected);

/// Picker confirm callback.
typedef PickerConfirmCallback = void Function(
    Picker picker, List<int> selected);

/// Picker confirm before callback.
typedef PickerConfirmBeforeCallback = Future<bool> Function(
    Picker picker, List<int> selected);

/// Picker value format callback.
typedef PickerValueFormat<T> = String Function(T value);

/// Picker
class Picker {
  static const double DefaultTextSize = 20.0;

  /// Index of currently selected items
  late List<int> selecteds;

  /// Picker adapter, Used to provide data and generate widgets
  late PickerAdapter adapter;

  /// insert separator before picker columns
  final List<PickerDelimiter>? delimiter;

  final VoidCallback? onCancel;
  final PickerSelectedCallback? onSelect;
  final PickerConfirmCallback? onConfirm;
  final PickerConfirmBeforeCallback? onConfirmBefore;

  /// When the previous level selection changes, scroll the child to the first item.
  final changeToFirst;

  /// Specify flex for each column
  final List<int>? columnFlex;

  final Widget? title;
  final Widget? cancel;
  final Widget? confirm;
  final String? cancelText;
  final String? confirmText;

  final double height;

  /// Height of list item
  final double itemExtent;

  final TextStyle? textStyle,
      cancelTextStyle,
      confirmTextStyle,
      selectedTextStyle;
  final TextAlign textAlign;
  final IconThemeData? selectedIconTheme;

  /// Text scaling factor
  final double? textScaleFactor;

  final EdgeInsetsGeometry? columnPadding;
  final Color? backgroundColor, headerColor, containerColor;

  /// Hide head
  final bool hideHeader;

  /// Show pickers in reversed order
  final bool reversedOrder;

  /// Generate a custom header， [hideHeader] = true
  final WidgetBuilder? builderHeader;

  /// List item loop
  final bool looping;

  /// Delay generation for smoother animation, This is the number of milliseconds to wait. It is recommended to > = 200
  final int smooth;

  final Widget? footer;

  /// A widget overlaid on the picker to highlight the currently selected entry.
  final Widget selectionOverlay;

  final Decoration? headerDecoration;

  final double magnification;
  final double diameterRatio;
  final double squeeze;

  Widget? _widget;
  PickerWidgetState? _state;

  Picker(
      {required this.adapter,
        this.delimiter,
        List<int>? selecteds,
        this.height = 150.0,
        this.itemExtent = 28.0,
        this.columnPadding,
        this.textStyle,
        this.cancelTextStyle,
        this.confirmTextStyle,
        this.selectedTextStyle,
        this.selectedIconTheme,
        this.textAlign = TextAlign.start,
        this.textScaleFactor,
        this.title,
        this.cancel,
        this.confirm,
        this.cancelText,
        this.confirmText,
        this.backgroundColor = Colors.white,
        this.containerColor,
        this.headerColor,
        this.builderHeader,
        this.changeToFirst = false,
        this.hideHeader = false,
        this.looping = false,
        this.reversedOrder = false,
        this.headerDecoration,
        this.columnFlex,
        this.footer,
        this.smooth = 0,
        this.magnification = 1.0,
        this.diameterRatio = 1.1,
        this.squeeze = 1.45,
        this.selectionOverlay = const CupertinoPickerDefaultSelectionOverlay(),
        this.onCancel,
        this.onSelect,
        this.onConfirmBefore,
        this.onConfirm}) {
    this.selecteds = selecteds == null ? <int>[] : selecteds;
  }

  Widget? get widget => _widget;

  PickerWidgetState? get state => _state;
  int _maxLevel = 1;

  /// 生成picker控件
  /// Build picker control
  Widget makePicker([ThemeData? themeData, bool isModal = false]) {
    _maxLevel = adapter.maxLevel;
    adapter.picker = this;
    adapter.initSelects();
    _widget = PickerWidget(
      key: ValueKey(this),
      child:
      _PickerWidget(picker: this, themeData: themeData, isModal: isModal),
      data: this,
    );
    return _widget!;
  }

  /// Display modal picker
  Future<T?> showModal<T>(BuildContext context,
      [ThemeData? themeData, bool isScrollControlled = false]) async {
    return await showModalBottomSheet<T>(
        context: context, //state.context,
        isScrollControlled: isScrollControlled,
        barrierColor: Color.fromRGBO(0, 0, 0, 0.1),
        builder: (BuildContext context) {
          return makePicker(themeData, true);
        });
  }

  /// Get the value of the current selection
  List getSelectedValues() {
    return adapter.getSelectedValues();
  }

  /// 取消
  void doCancel(BuildContext context) {
    Navigator.of(context).pop<List<int>>(null);
    if (onCancel != null) onCancel!();
    _widget = null;
  }

  /// 确定
  void doConfirm(BuildContext context) async {
    if (onConfirmBefore != null && !(await onConfirmBefore!(this, selecteds))) {
      return; // Cancel;
    }
    Navigator.of(context).pop<List<int>>(selecteds);
    if (onConfirm != null) onConfirm!(this, selecteds);
    _widget = null;
  }

  static ButtonStyle _getButtonStyle(ButtonThemeData? theme) => ButtonStyle(
      minimumSize: MaterialStateProperty.all(Size(theme?.minWidth ?? 0.0, 42)),
      padding: MaterialStateProperty.all(theme?.padding));
}

// /// 分隔符
class PickerDelimiter {
  final Widget? child;
  final int column;

  PickerDelimiter({required this.child, this.column = 1});
}

/// picker data list item
class PickerItem<T> {
  final Widget? text;

  final T? value;

  final List<PickerItem<T>>? children;

  PickerItem({this.text, this.value, this.children});
}

class PickerWidget<T> extends InheritedWidget {
  final Picker data;

  const PickerWidget({Key? key, required this.data, required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant PickerWidget oldWidget) =>
      oldWidget.data != data;

  static PickerWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PickerWidget>()
    as PickerWidget;
  }
}

class _PickerWidget<T> extends StatefulWidget {
  final Picker picker;
  final ThemeData? themeData;
  final bool isModal;

  _PickerWidget(
      {Key? key, required this.picker, this.themeData, required this.isModal})
      : super(key: key);

  @override
  PickerWidgetState createState() =>
      PickerWidgetState<T>(picker: this.picker, themeData: this.themeData);
}

class PickerWidgetState<T> extends State<_PickerWidget> {
  final Picker picker;
  final ThemeData? themeData;

  PickerWidgetState({required this.picker, this.themeData});

  ThemeData? theme;
  final List<FixedExtentScrollController> scrollController = [];
  final List<StateSetter?> _keys = [];

  @override
  void initState() {
    super.initState();
    picker._state = this;
    picker.adapter.doShow();

    if (scrollController.length == 0) {
      for (int i = 0; i < picker._maxLevel; i++) {
        scrollController
            .add(FixedExtentScrollController(initialItem: picker.selecteds[i]));
        _keys.add(null);
      }
    }
  }

  void update() {
    setState(() {});
  }

  // var ref = 0;
  @override
  Widget build(BuildContext context) {
    // print("picker build ${ref++}");
    theme = themeData ?? Theme.of(context);

    if (_wait && picker.smooth > 0) {
      Future.delayed(Duration(milliseconds: picker.smooth), () {
        if (!_wait) return;
        setState(() {
          _wait = false;
        });
      });
    } else
      _wait = false;

    var _body = <Widget>[];
    if (!picker.hideHeader) {
      if (picker.builderHeader != null) {
        _body.add(picker.headerDecoration == null
            ? picker.builderHeader!(context)
            : DecoratedBox(
            child: picker.builderHeader!(context),
            decoration: picker.headerDecoration!));
      } else {
        _body.add(DecoratedBox(
          child: Row(
            children: _buildHeaderViews(context),
          ),
          decoration: picker.headerDecoration ??
              BoxDecoration(
                // borderRadius: BorderRadius.all(Radius.circular(40)),
                border: Border(
                  top: BorderSide(color: theme!.dividerColor, width: 0.5),
                  bottom: BorderSide(color: theme!.dividerColor, width: 0.5),
                ),
                color: picker.headerColor == null
                    ? (theme!.bottomAppBarColor)
                    : picker.headerColor,
              ),
        ));
      }
    }
    _body.add(_wait
        ? Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _buildViews(),
    )
        : AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _buildViews(),
      ),
    ));

    if (picker.footer != null) _body.add(picker.footer!);
    Widget v = SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _body,
      ),
    );
    if (widget.isModal) {
      return GestureDetector(
        onTap: () {},
        child: v,
      );
    }
    return v;
  }

  List<Widget>? _headerItems;

  Widget _buildHeaderButton(BuildContext context,
      {required String text,
        required VoidCallback onPressed,
        TextStyle? style}) {
    return TextButton(
        style: Picker._getButtonStyle(ButtonTheme.of(context)),
        onPressed: onPressed,
        child: Text(text,
            overflow: TextOverflow.ellipsis,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            style: style ??
                theme!.textTheme.button!.copyWith(
                    color: theme!.accentColor,
                    fontSize: Picker.DefaultTextSize)));
  }

  List<Widget> _buildHeaderViews(BuildContext context) {
    if (_headerItems != null) return _headerItems!;
    if (theme == null) theme = Theme.of(context);
    List<Widget> items = [];

    if (picker.cancel != null) {
      items.add(DefaultTextStyle(
          style: picker.cancelTextStyle ??
              theme!.textTheme.button!.copyWith(
                  color: theme!.accentColor, fontSize: Picker.DefaultTextSize),
          child: picker.cancel!));
    } else {
      String? _cancelText = picker.cancelText ?? 'Cancel';
      if (_cancelText != "") {
        items.add(_buildHeaderButton(context,
            text: _cancelText, style: picker.cancelTextStyle, onPressed: () {
              picker.doCancel(context);
            }));
      }
    }

    items.add(Expanded(
        child: Center(
          child: picker.title == null
              ? picker.title
              : DefaultTextStyle(
              style: theme!.textTheme.headline6!.copyWith(
                fontSize: Picker.DefaultTextSize,
              ),
              child: picker.title!),
        )));

    if (picker.confirm != null) {
      items.add(DefaultTextStyle(
          style: picker.confirmTextStyle ??
              theme!.textTheme.button!.copyWith(
                  color: theme!.accentColor, fontSize: Picker.DefaultTextSize),
          child: picker.confirm!));
    } else {
      String? _confirmText = picker.confirmText ?? 'Confirm';
      if (_confirmText != "") {
        items.add(_buildHeaderButton(context,
            text: _confirmText, style: picker.confirmTextStyle, onPressed: () {
              picker.doConfirm(context);
            }));
      }
    }

    _headerItems = items;
    return items;
  }

  bool _changing = false;
  bool _wait = true;
  final Map<int, int> lastData = {};

  List<Widget> _buildViews() {
    if (__printDebug) print("_buildViews");
    if (theme == null) theme = Theme.of(context);

    List<Widget> items = [];

    PickerAdapter? adapter = picker.adapter;
    adapter.setColumn(-1);

    if (adapter.length > 0) {
      var _decoration = BoxDecoration(
        color: picker.containerColor == null
            ? theme!.dialogBackgroundColor
            : picker.containerColor,
      );

      for (int i = 0; i < picker._maxLevel; i++) {
        Widget view = Expanded(
          flex: adapter.getColumnFlex(i),
          child: Container(
            padding: picker.columnPadding,
            height: picker.height,
            decoration: _decoration,
            child: _wait
                ? null
                : StatefulBuilder(
              builder: (context, state) {
                _keys[i] = state;
                adapter.setColumn(i - 1);

                // 上一次是空列表
                final _lastIsEmpty = scrollController[i].hasClients &&
                    !scrollController[i].position.hasContentDimensions;

                final _length = adapter.length;
                var _view = CupertinoPicker.builder(
                  key: _lastIsEmpty ? ValueKey(_length) : null,
                  backgroundColor: picker.backgroundColor,
                  scrollController: scrollController[i],
                  itemExtent: picker.itemExtent,
                  // looping: picker.looping,
                  magnification: picker.magnification,
                  diameterRatio: picker.diameterRatio,
                  squeeze: picker.squeeze,
                  selectionOverlay: picker.selectionOverlay,
                  onSelectedItemChanged: (int _index) {
                    if (__printDebug) print("onSelectedItemChanged");
                    if (_length <= 0) return;
                    var index = _index % _length;
                    picker.selecteds[i] = index;
                    updateScrollController(i);
                    adapter.doSelect(i, index);
                    if (picker.changeToFirst) {
                      for (int j = i + 1;
                      j < picker.selecteds.length;
                      j++) {
                        picker.selecteds[j] = 0;
                        scrollController[j].jumpTo(0.0);
                      }
                    }
                    if (picker.onSelect != null)
                      picker.onSelect!(picker, i, picker.selecteds);

                    if (adapter.needUpdatePrev(i))
                      setState(() {});
                    else {
                      if (_keys[i] != null) _keys[i]!(() => null);
                      if (adapter.isLinkage) {
                        for (int j = i + 1;
                        j < picker.selecteds.length;
                        j++) {
                          if (j == i) continue;
                          adapter.setColumn(j - 1);
                          if (_keys[j] != null) _keys[j]!(() => null);
                        }
                      }
                    }
                  },
                  itemBuilder: (context, index) {
                    adapter.setColumn(i - 1);
                    return adapter.buildItem(context, index % _length);
                  },
                  childCount: picker.looping ? null : _length,
                );

                if (_lastIsEmpty ||
                    (!picker.changeToFirst &&
                        picker.selecteds[i] >= _length)) {
                  Timer(Duration(milliseconds: 100), () {
                    if (!this.mounted) return;
                    if (__printDebug) print("timer last");
                    var _len = adapter.length;
                    var _index = (_len < _length ? _len : _length) - 1;
                    if (scrollController[i]
                        .position
                        .hasContentDimensions) {
                      scrollController[i].jumpToItem(_index);
                    } else {
                      scrollController[i] = FixedExtentScrollController(
                          initialItem: _index);
                      state(() => null);
                    }
                  });
                }

                return _view;
              },
            ),
          ),
        );
        items.add(view);
      }
    }

    if (picker.delimiter != null && !_wait) {
      for (int i = 0; i < picker.delimiter!.length; i++) {
        var o = picker.delimiter![i];
        if (o.child == null) continue;
        var item = Container(child: o.child, height: picker.height);
        if (o.column < 0)
          items.insert(0, item);
        else if (o.column >= items.length)
          items.add(item);
        else
          items.insert(o.column, item);
      }
    }

    if (picker.reversedOrder) return items.reversed.toList();

    return items;
  }

  void updateScrollController(int i) {
    if (_changing || !(picker.adapter.isLinkage)) return;
    _changing = true;
    for (int j = 0; j < picker.selecteds.length; j++) {
      if (j != i) {
        if (scrollController[j].hasClients &&
            scrollController[j].position.hasContentDimensions)
          scrollController[j].position.notifyListeners();
      }
    }
    _changing = false;
  }

  @override
  void debugFillProperties(properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('_changing', _changing));
    properties.add(DiagnosticsProperty<bool>('_changing', _changing));
  }
}

abstract class PickerAdapter<T> {
  Picker? picker;

  int getLength();

  int getMaxLevel();

  void setColumn(int index);

  void initSelects();

  Widget buildItem(BuildContext context, int index);

  /// Need to update previous columns
  bool needUpdatePrev(int curIndex) {
    return false;
  }

  Widget makeText(Widget? child, String? text, bool isSel) {
    return Center(
        child: DefaultTextStyle(
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: picker!.textAlign,
            style: picker!.textStyle ??
                TextStyle(
                    color: Colors.black87,
                    fontFamily: picker?.state?.context != null
                        ? Theme.of(picker!.state!.context)
                        .textTheme
                        .headline6!
                        .fontFamily
                        : "",
                    fontSize: Picker.DefaultTextSize),
            child: child != null
                ? (isSel && picker!.selectedIconTheme != null
                ? IconTheme(
              data: picker!.selectedIconTheme!,
              child: child,
            )
                : child)
                : Text(text ?? "",
                textScaleFactor: picker!.textScaleFactor,
                style: (isSel ? picker!.selectedTextStyle : null))));
  }

  Widget makeTextEx(
      Widget? child, String text, Widget? postfix, Widget? suffix, bool isSel) {
    List<Widget> items = [];
    if (postfix != null) items.add(postfix);
    items.add(
        child ?? Text(text, style: (isSel ? picker!.selectedTextStyle : null)));
    if (suffix != null) items.add(suffix);

    Color? _txtColor = Colors.black87;
    double? _txtSize = Picker.DefaultTextSize;
    if (isSel && picker!.selectedTextStyle != null) {
      if (picker!.selectedTextStyle!.color != null)
        _txtColor = picker!.selectedTextStyle!.color;
      if (picker!.selectedTextStyle!.fontSize != null)
        _txtSize = picker!.selectedTextStyle!.fontSize;
    }

    return new Center(
      //alignment: Alignment.center,
        child: DefaultTextStyle(
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: picker!.textAlign,
            style: picker!.textStyle ??
                TextStyle(color: _txtColor, fontSize: _txtSize),
            child: Wrap(
              children: items,
            )));
  }

  String getText() {
    return getSelectedValues().toString();
  }

  List<T> getSelectedValues() {
    return [];
  }

  void doShow() {}

  void doSelect(int column, int index) {}

  int getColumnFlex(int column) {
    if (picker!.columnFlex != null && column < picker!.columnFlex!.length)
      return picker!.columnFlex![column];
    return 1;
  }

  int get maxLevel => getMaxLevel();

  /// Content length of current column
  int get length => getLength();

  String get text => getText();

  // 是否联动，即后面的列受前面列数据影响
  bool get isLinkage => getIsLinkage();

  @override
  String toString() {
    return getText();
  }

  bool getIsLinkage() {
    return true;
  }

  void notifyDataChanged() {
    if (picker?.state != null) {
      picker!.adapter.doShow();
      picker!.adapter.initSelects();
      for (int j = 0; j < picker!.selecteds.length; j++) {
        picker!.state!.scrollController[j].jumpToItem(picker!.selecteds[j]);
      }
    }
  }
}

class PickerDataAdapter<T> extends PickerAdapter<T> {
  late List<PickerItem<T>> data;
  List<PickerItem<dynamic>>? _datas;
  int _maxLevel = -1;
  int _col = 0;
  final bool isArray;

  PickerDataAdapter(
      {List? pickerdata, List<PickerItem<T>>? data, this.isArray = false}) {
    this.data = data ?? <PickerItem<T>>[];
    _parseData(pickerdata);
  }

  @override
  bool getIsLinkage() {
    return !isArray;
  }

  void _parseData(List? pickerData) {
    if (pickerData != null && pickerData.length > 0 && (data.length == 0)) {
      if (isArray) {
        _parseArrayPickerDataItem(pickerData, data);
      } else {
        _parsePickerDataItem(pickerData, data);
      }
    }
  }

  _parseArrayPickerDataItem(List? pickerData, List<PickerItem> data) {
    if (pickerData == null) return;
    var len = pickerData.length;
    for (int i = 0; i < len; i++) {
      var v = pickerData[i];
      if (!(v is List)) continue;
      List lv = v;
      if (lv.length == 0) continue;

      PickerItem item = PickerItem<T>(children: <PickerItem<T>>[]);
      data.add(item);

      for (int j = 0; j < lv.length; j++) {
        var o = lv[j];
        if (o is T) {
          item.children!.add(PickerItem<T>(value: o));
        } else if (T == String) {
          String _v = o.toString();
          item.children!.add(PickerItem<T>(value: _v as T));
        }
      }
    }
    if (__printDebug) print("data.length: ${data.length}");
  }

  _parsePickerDataItem(List? pickerData, List<PickerItem> data) {
    if (pickerData == null) return;
    var len = pickerData.length;
    for (int i = 0; i < len; i++) {
      var item = pickerData[i];
      if (item is T) {
        data.add(new PickerItem<T>(value: item));
      } else if (item is Map) {
        final Map map = item;
        if (map.length == 0) continue;

        List<T> _mapList = map.keys.toList().cast();
        for (int j = 0; j < _mapList.length; j++) {
          var _o = map[_mapList[j]];
          if (_o is List && _o.length > 0) {
            List<PickerItem<T>> _children = <PickerItem<T>>[];
            //print('add: ${data.runtimeType.toString()}');
            data.add(PickerItem<T>(value: _mapList[j], children: _children));
            _parsePickerDataItem(_o, _children);
          }
        }
      } else if (T == String && !(item is List)) {
        String _v = item.toString();
        //print('add: $_v');
        data.add(PickerItem<T>(value: _v as T));
      }
    }
  }

  void setColumn(int index) {
    if (_datas != null && _col == index + 1) return;
    _col = index + 1;
    if (isArray) {
      if (__printDebug) print("index: $index");
      if (_col < data.length)
        _datas = data[_col].children;
      else
        _datas = null;
      return;
    }
    if (index < 0) {
      _datas = data;
    } else {
      _datas = data;
      // 列数过多会有性能问题
      for (int i = 0; i <= index; i++) {
        var j = picker!.selecteds[i];
        if (_datas != null && _datas!.length > j)
          _datas = _datas![j].children;
        else {
          _datas = null;
          break;
        }
      }
    }
  }

  @override
  int getLength() => _datas?.length ?? 0;

  @override
  getMaxLevel() {
    if (_maxLevel == -1) _checkPickerDataLevel(data, 1);
    return _maxLevel;
  }

  @override
  Widget buildItem(BuildContext context, int index) {
    final PickerItem item = _datas![index];
    final isSel = index == picker!.selecteds[_col];
    if (item.text != null) {
      return isSel && picker!.selectedTextStyle != null
          ? DefaultTextStyle(
          style: picker!.selectedTextStyle!,
          child: picker!.selectedIconTheme != null
              ? IconTheme(
            data: picker!.selectedIconTheme!,
            child: item.text!,
          )
              : item.text!)
          : item.text!;
    }
    return makeText(
        item.text, item.text != null ? null : item.value.toString(), isSel);
  }

  @override
  void initSelects() {
    // ignore: unnecessary_null_comparison
    if (picker!.selecteds == null) picker!.selecteds = <int>[];
    if (picker!.selecteds.length == 0) {
      for (int i = 0; i < _maxLevel; i++) picker!.selecteds.add(0);
    }
  }

  @override
  List<T> getSelectedValues() {
    List<T> _items = [];
    var _sLen = picker!.selecteds.length;
    if (isArray) {
      for (int i = 0; i < _sLen; i++) {
        int j = picker!.selecteds[i];
        if (j < 0 || data[i].children == null || j >= data[i].children!.length)
          break;
        _items.add(data[i].children![j].value!);
      }
    } else {
      List<PickerItem<dynamic>>? datas = data;
      for (int i = 0; i < _sLen; i++) {
        int j = picker!.selecteds[i];
        if (j < 0 || j >= datas!.length) break;
        _items.add(datas[j].value);
        datas = datas[j].children;
        if (datas == null || datas.length == 0) break;
      }
    }
    return _items;
  }

  _checkPickerDataLevel(List<PickerItem>? data, int level) {
    if (data == null) return;
    if (isArray) {
      _maxLevel = data.length;
      return;
    }
    for (int i = 0; i < data.length; i++) {
      if (data[i].children != null && data[i].children!.length > 0)
        _checkPickerDataLevel(data[i].children, level + 1);
    }
    if (_maxLevel < level) _maxLevel = level;
  }
}


