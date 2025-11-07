import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'textfield.dart';
import 'types.dart';


/// A [TextFormField] with a [value] and [onValueChanged] instead of having the
/// [controller].
/// 
/// The purpose is to make the [TextFormField] easily bindable to any provider,
/// like this:
/// 
/// ```dart
/// ReactiveTextFormField(
///   value: context.watch<TextHolder>().value,
///   onValueChanged: (value) {
///     context.read<TextHolder>().value = value;
///   },
/// )
/// ```
/// 
/// See also:
///
///  * [ReactiveTextField] is under the hood.
class ReactiveTextFormField extends FormField<String>
{
  /// {@macro flutter.widgets.editableText.groupId}
  final Object groupId;

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController] and
  /// initialize its [TextEditingController.text] with [value].
  final TextEditingController? controller;

  /// {@template flutter.material.TextFormField.onChanged}
  /// Called when the user initiates a change to the TextField's
  /// value: when they have inserted or deleted text or reset the form.
  /// {@endtemplate}
  final ValueChanged<String>? onChanged;

  /// Creates a [FormField] that contains a [ReactiveTextField].
  ///
  /// When a [controller] is specified, its `text` will be reset from [value].
  /// If [controller] is null, then a [TextEditingController] will be
  /// constructed automatically and its `text` will be initialized to [value].
  ///
  /// For documentation about the various parameters, see the
  /// [ReactiveTextField] class and [TextField.new], the constructor.
  ReactiveTextFormField({
    super.key,
    this.groupId = EditableText,
    this.controller,
    final FocusNode? focusNode,
    final UndoHistoryController? undoController,
    super.forceErrorText,
    final InputDecoration? decoration = const InputDecoration(),
    final TextInputType? keyboardType,
    final TextCapitalization textCapitalization = TextCapitalization.none,
    final TextInputAction? textInputAction,
    final TextStyle? style,
    final StrutStyle? strutStyle,
    final TextDirection? textDirection,
    final TextAlign textAlign = TextAlign.start,
    final TextAlignVertical? textAlignVertical,
    final bool autofocus = false,
    final bool readOnly = false,
    final bool? showCursor,
    final String obscuringCharacter = '•',
    final bool obscureText = false,
    final bool autocorrect = true,
    final SmartDashesType? smartDashesType,
    final SmartQuotesType? smartQuotesType,
    final bool enableSuggestions = true,
    final MaxLengthEnforcement? maxLengthEnforcement,
    final int? maxLines = 1,
    final int? minLines,
    final bool expands = false,
    final int? maxLength,
    this.onChanged,
    final GestureTapCallback? onTap,
    final bool onTapAlwaysCalled = false,
    final TapRegionCallback? onTapOutside,
    final TapRegionUpCallback? onTapUpOutside,
    final VoidCallback? onEditingComplete,
    final ValueChanged<String>? onFieldSubmitted,
    super.onSaved,
    super.validator,
    super.errorBuilder,
    final List<TextInputFormatter>? inputFormatters,
    final bool? enabled,
    final bool? ignorePointers,
    final double cursorWidth = 2.0,
    final double? cursorHeight,
    final Radius? cursorRadius,
    final Color? cursorColor,
    final Color? cursorErrorColor,
    final Brightness? keyboardAppearance,
    final EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    final bool? enableInteractiveSelection,
    final bool? selectAllOnFocus,
    final TextSelectionControls? selectionControls,
    final InputCounterWidgetBuilder? buildCounter,
    final ScrollPhysics? scrollPhysics,
    final Iterable<String>? autofillHints,
    final AutovalidateMode? autovalidateMode,
    final ScrollController? scrollController,
    super.restorationId,
    final bool enableIMEPersonalizedLearning = true,
    final MouseCursor? mouseCursor,
    final EditableTextContextMenuBuilder? contextMenuBuilder = _defaultContextMenuBuilder,
    final SpellCheckConfiguration? spellCheckConfiguration,
    final TextMagnifierConfiguration? magnifierConfiguration,
    final AppPrivateCommandCallback? onAppPrivateCommand,
    final bool? cursorOpacityAnimates,
    final ui.BoxHeightStyle? selectionHeightStyle,
    final ui.BoxWidthStyle? selectionWidthStyle,
    final DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    final ContentInsertionConfiguration? contentInsertionConfiguration,
    final WidgetStatesController? statesController,
    final Clip clipBehavior = Clip.hardEdge,
    final bool stylusHandwritingEnabled = EditableText.defaultStylusHandwritingEnabled,
    final bool canRequestFocus = true,
    final List<Locale>? hintLocales,
    required final String value,
    final ValueChanged<String>? onValueChanged,
    final ValueChanged<String>? onTextChanged,
    final UnfocusBehavior unfocusBehavior = UnfocusBehavior.resetValue,
  })
  : assert(obscuringCharacter.length == 1),
    assert(maxLines == null || maxLines > 0),
    assert(minLines == null || minLines > 0),
    assert(
      (maxLines == null) || (minLines == null) || (maxLines >= minLines),
      "minLines can't be greater than maxLines",
    ),
    assert(
      !expands || (maxLines == null && minLines == null),
      'minLines and maxLines must be null when expands is true.',
    ),
    assert(!obscureText || maxLines == 1, 'Obscured fields cannot be multiline.'),
    assert(maxLength == null || maxLength == TextField.noMaxLength || maxLength > 0),
    super(
      initialValue: value,
      enabled: enabled ?? decoration?.enabled ?? true,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
      builder: (final FormFieldState<String> field) {
        final state = field as _ReactiveTextFormFieldState;
        var effectiveDecoration = (decoration ?? const InputDecoration())
          .applyDefaults(Theme.of(field.context).inputDecorationTheme);
        final errorText = field.errorText;
        if (errorText != null) {
          effectiveDecoration = errorBuilder != null
            ? effectiveDecoration.copyWith(error: errorBuilder(state.context, errorText))
            : effectiveDecoration.copyWith(errorText: errorText);
        }

        void onTextChangedHandler(final String value)
        {
          field.didChange(value);
          onTextChanged?.call(value);
        }

        return UnmanagedRestorationScope(
          bucket: field.bucket,
          child: ReactiveTextField(
            groupId: groupId,
            controller: state._effectiveController,
            focusNode: focusNode,
            undoController: undoController,
            decoration: effectiveDecoration,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            style: style,
            strutStyle: strutStyle,
            textAlign: textAlign,
            textAlignVertical: textAlignVertical,
            textDirection: textDirection,
            readOnly: readOnly,
            showCursor: showCursor,
            autofocus: autofocus,
            statesController: statesController,
            obscuringCharacter: obscuringCharacter,
            obscureText: obscureText,
            autocorrect: autocorrect,
            smartDashesType: smartDashesType
              ?? (obscureText ? SmartDashesType.disabled : SmartDashesType.enabled),
            smartQuotesType: smartQuotesType
              ?? (obscureText ? SmartQuotesType.disabled : SmartQuotesType.enabled),
            enableSuggestions: enableSuggestions,
            maxLines: maxLines,
            minLines: minLines,
            expands: expands,
            maxLength: maxLength,
            maxLengthEnforcement: maxLengthEnforcement,
            onChanged: onChanged,
            onEditingComplete: onEditingComplete,
            onSubmitted: onFieldSubmitted,
            onAppPrivateCommand: onAppPrivateCommand,
            inputFormatters: inputFormatters,
            enabled: enabled ?? decoration?.enabled ?? true,
            ignorePointers: ignorePointers,
            cursorWidth: cursorWidth,
            cursorHeight: cursorHeight,
            cursorRadius: cursorRadius,
            cursorOpacityAnimates: cursorOpacityAnimates,
            cursorColor: cursorColor,
            cursorErrorColor: cursorErrorColor,
            selectionHeightStyle: selectionHeightStyle
              ?? EditableText.defaultSelectionHeightStyle,
            selectionWidthStyle: selectionWidthStyle
              ?? EditableText.defaultSelectionWidthStyle,
            keyboardAppearance: keyboardAppearance,
            scrollPadding: scrollPadding,
            scrollPhysics: scrollPhysics,
            scrollController: scrollController,
            dragStartBehavior: dragStartBehavior,
            enableInteractiveSelection: enableInteractiveSelection
              ?? (!obscureText || !readOnly),
            selectAllOnFocus: selectAllOnFocus,
            selectionControls: selectionControls,
            onTap: onTap,
            onTapAlwaysCalled: onTapAlwaysCalled,
            onTapOutside: onTapOutside,
            onTapUpOutside: onTapUpOutside,
            mouseCursor: mouseCursor,
            buildCounter: buildCounter,
            autofillHints: autofillHints,
            contentInsertionConfiguration: contentInsertionConfiguration,
            clipBehavior: clipBehavior,
            restorationId: restorationId,
            stylusHandwritingEnabled: stylusHandwritingEnabled,
            enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
            contextMenuBuilder: contextMenuBuilder,
            canRequestFocus: canRequestFocus,
            spellCheckConfiguration: spellCheckConfiguration,
            magnifierConfiguration: magnifierConfiguration,
            hintLocales: hintLocales,
            value: value,
            onValueChanged: onValueChanged,
            onTextChanged: onTextChangedHandler,
            unfocusBehavior: unfocusBehavior,
          ),
        );
      },
    );

  static Widget _defaultContextMenuBuilder(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    if (defaultTargetPlatform == TargetPlatform.iOS && SystemContextMenu.isSupported(context)) {
      return SystemContextMenu.editableText(editableTextState: editableTextState);
    }
    return AdaptiveTextSelectionToolbar.editableText(editableTextState: editableTextState);
  }

  @override
  FormFieldState<String> createState() => _ReactiveTextFormFieldState();
}


class _ReactiveTextFormFieldState extends FormFieldState<String>
{
  @override
  void initState()
  {
    super.initState();
    if (_textFormField.controller == null) {
      _createLocalController(widget.initialValue != null
        ? TextEditingValue(text: widget.initialValue!)
        : null,
      );
    } else {
      _textFormField.controller!.addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(final ReactiveTextFormField oldWidget)
  {
    super.didUpdateWidget(oldWidget);
    if (_textFormField.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      _textFormField.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && _textFormField.controller == null) {
        _createLocalController(oldWidget.controller!.value);
      }

      if (_textFormField.controller != null) {
        setValue(_textFormField.controller!.text);
        if (oldWidget.controller == null) {
          unregisterFromRestoration(_controller!);
          _controller!.dispose();
          _controller = null;
        }
      }
    }
  }

  @override
  void dispose()
  {
    _textFormField.controller?.removeListener(_handleControllerChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void restoreState(final RestorationBucket? oldBucket, final bool initialRestore)
  {
    super.restoreState(oldBucket, initialRestore);
    if (_controller != null) {
      _registerController();
    }
    // Make sure to update the internal [FormFieldState] value to sync up with
    // text editing controller value.
    setValue(_effectiveController.text);
  }

  @override
  void didChange(final String? value)
  {
    super.didChange(value);
    if (_effectiveController.text != value) {
      _effectiveController.value = TextEditingValue(text: value ?? '');
    }
  }

  @override
  void reset()
  {
    // Set the controller value before calling super.reset() to let
    // _handleControllerChanged suppress the change.
    _effectiveController.value = TextEditingValue(text: widget.initialValue ?? '');
    super.reset();
    _textFormField.onChanged?.call(_effectiveController.text);
  }

  void _registerController()
  {
    assert(_controller != null);
    registerForRestoration(_controller!, 'controller');
  }

  void _createLocalController([ final TextEditingValue? value ])
  {
    assert(_controller == null);
    _controller = value == null
      ? RestorableTextEditingController()
      : RestorableTextEditingController.fromValue(value);
    if (!restorePending) {
      _registerController();
    }
  }

  void _handleControllerChanged()
  {
    // Suppress changes that originated from within this class.
    //
    // In the case where a controller has been passed in to this widget, we
    // register this change listener. In these cases, we'll also receive change
    // notifications for changes originating from within this class -- for
    // example, the reset() method. In such cases, the FormField value will
    // already have been set.
    if (_effectiveController.text != value) {
      didChange(_effectiveController.text);
    }
  }

  TextEditingController get _effectiveController => _textFormField.controller
    ?? _controller!.value;

  ReactiveTextFormField get _textFormField => super.widget as ReactiveTextFormField;

  RestorableTextEditingController? _controller;
}
