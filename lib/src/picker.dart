import 'package:flutter/material.dart';

import 'flutter_cf_multi_picker.dart';

const commonText = TextStyle(
  color: Colors.blue,
  fontStyle: FontStyle.normal,
  fontWeight: FontWeight.normal,
  fontSize: 18,
);

class _CfPicker {

  showMultiPicker(
      {required BuildContext context,
      required List<dynamic> data,
      Function(List<dynamic>, List<int>)?
          onConfirm, //danh sách giá trị và vị trí của nó trong data
      List<int>? selectIndex}) {
    List<int> selectIndex =
        List<int>.from(data.map((e) => e['select']).toList());
    List<dynamic> array = data.map((e) => e['data']).toList();

    Picker(
        selecteds: selectIndex,
        adapter: PickerDataAdapter<String>(pickerdata: array, isArray: true),
        hideHeader: false,
        confirmText: "Done",
        cancelText: '',
        confirmTextStyle: commonText,
        textStyle: commonText,
        selectedTextStyle: commonText,
        height: 303,
        itemExtent: 50,
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.25),
        headerColor: Colors.black12,
        onConfirm: (Picker picker, List value) {
          if (onConfirm != null) {
            onConfirm(picker.getSelectedValues(), picker.selecteds);
          }
        }).showModal(context);
  }
}

_CfPicker CfPicker = _CfPicker();
