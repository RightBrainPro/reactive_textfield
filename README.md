A reactive `TextField` with a `value` and `onValueChanged` instead of the `TextEditingController`.

Creates the internal controller for manipulating the text. This limits the ability to manipulate text selection and other functions of the controller. To track instant text changes, an `onTextChanged` callback is provided, which, unlike `onChanged`, is triggered not only when the text is changed by the user, but also when the text is changed by the undo controller or when the widget is rebuilt with a new text `value`.

## Features

* Supports for reactivity using providers.
* Inherits the native TextField properties.
* Configuring behavior when input focus is lost (do nothing, reset the text value or save it automatically).

## Getting started

Just import the package and use `ReactiveTextField` instead of `TextField`.

## Usage

Specify the `value` and implement `onValueChanged` callback instead of using the `TextEditingController`. You also can specify any other properties the regular `TextField` supports.

```dart
ReactiveTextField(
    decoration: InputDecoration(
        labelText: 'Reactive email field',
    ),
    undoController: myHistoryController,
    focusNode: myFocusNode,
    value: context.read<User>().email,
    onValueChanged: (value) => context.read<User>().email = value,
)
```

## Additional information

The widget stores the `value` and saves the text to the `value` when the user submits the text. By default, it resets the text from the `value` when the text field loses the focus, but you can specify another `unfocusBehavior`. It can be useful in multiline text field where submitting is not provided, in this case you can choose `UnfocusBehavior.nothing` and implement your own button for submitting the text cought from the `onTextChanged` callback of the `ReactiveTextField` widget.

See the `example` in the package.