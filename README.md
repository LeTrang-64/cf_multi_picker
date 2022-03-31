# cf_multi_picker

A package use for create multi picker

## Usage

To use this plugin, add cf_multi_picker as a dependency in your pubspec.yaml file.

##Example
```bash
CfPicker.showMultiPicker(
        context: context,
        data: PickerData,
        onConfirm: (data, _select) {
          print(data)
        });
  ```
- Install

```bash
flutter pub add cf_multi_picker
```
- Use package

```bash
import 'package:cf_multi_picker/cf_multi_picker.dart';
```

##Preview

![multi_picker](multi_picker.gif)