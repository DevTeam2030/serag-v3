import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:mine/constants/app_colors.dart';
import 'package:mine/constants/app_text_styles.dart';

class CustomDropdown extends StatefulWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final double? margin;
  final String? label;
  final String? Function(String?)? validator;

  const CustomDropdown({
    super.key,
    required this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
    this.margin,
    this.label,
    this.validator,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  late TextEditingController controller;
  late FocusNode _focusNode;
  bool isBoxOpen = false;
  bool _allowKeyboard = false;
  String _lastText = "";
  bool _programmaticChange = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value ?? "");
    _lastText = widget.value ?? "";
    _focusNode = FocusNode();

    // Listen to text changes to detect manual typing
    controller.addListener(_onTextChanged);

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          isBoxOpen = false;
          _allowKeyboard = false;
        });
      } else {
        // When focus is gained, check if keyboard should show
        if (!_allowKeyboard) {
          // Hide keyboard by unfocusing briefly
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted && _focusNode.hasFocus && !_allowKeyboard) {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
            }
          });
        }
      }
    });
  }

  void _onTextChanged() {
    // Skip if this is a programmatic change
    if (_programmaticChange) {
      _programmaticChange = false;
      return;
    }

    // Detect if user is actually typing
    if (controller.text != _lastText && _focusNode.hasFocus) {
      if (!_allowKeyboard) {
        setState(() {
          _allowKeyboard = true;
          isBoxOpen = true;
        });
      }
    }
    _lastText = controller.text;
  }

  @override
  void didUpdateWidget(CustomDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _programmaticChange = true;
      controller.text = widget.value ?? "";
      _lastText = widget.value ?? "";
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onTextChanged);
    controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSelection(String suggestion, FormFieldState<String> field) {
    _allowKeyboard = false;
    _programmaticChange = true;
    controller.text = suggestion;
    _lastText = suggestion;
    widget.onChanged(suggestion);
    field.didChange(suggestion);
    field.validate();
    _focusNode.unfocus();
    setState(() => isBoxOpen = false);
  }

  void _handleTap() {
    if (_focusNode.hasFocus && isBoxOpen) {
      // If already open and focused, close it
      _focusNode.unfocus();
      setState(() {
        isBoxOpen = false;
        _allowKeyboard = false;
      });
    } else {
      // Open dropdown without keyboard
      setState(() {
        _allowKeyboard = false;
        isBoxOpen = true;
      });

      // Request focus
      _focusNode.requestFocus();

      // Hide keyboard
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted && !_allowKeyboard) {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        }
      });
    }
  }

  void _enableManualTyping() {
    setState(() {
      _allowKeyboard = true;
    });
    _focusNode.requestFocus();
    // Show keyboard
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: widget.margin ?? 10.h),
      child: FormField<String>(
        initialValue: widget.value,
        validator: widget.validator,
        builder: (field) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropDownSearchField<String>(
                animationDuration: const Duration(milliseconds: 300),
                textFieldConfiguration: TextFieldConfiguration(
                  controller: controller,
                  focusNode: _focusNode,
                  autofocus: false,
                  onTap: _handleTap,
                  enableInteractiveSelection: _allowKeyboard,
                  decoration: InputDecoration(
                    labelText: widget.label,
                    labelStyle: AppTextStyles.regularGrey15.copyWith(fontSize: 13.sp),
                    hintText: widget.hint,
                    hintStyle: AppTextStyles.regularGrey15.copyWith(fontSize: 13.sp),
                    filled: true,
                    fillColor: const Color(0xFFF7F8F9),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE8ECF4), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE8ECF4), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey, width: 1.2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 1.2),
                    ),
                    errorText: field.errorText,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon to enable manual typing
                        if (isBoxOpen && !_allowKeyboard)
                          IconButton(
                            icon: const Icon(Icons.keyboard, size: 20),
                            color: Colors.grey,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: _enableManualTyping,
                            tooltip: 'كتابة يدوية',
                          ),
                        if (isBoxOpen && !_allowKeyboard)
                          SizedBox(width: 4.w),
                        Icon(
                          isBoxOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 8.w),
                      ],
                    ),
                  ),
                  style: AppTextStyles.regularGrey15.copyWith(fontSize: 13.sp),
                ),
                suggestionsBoxDecoration: SuggestionsBoxDecoration(
                  color: const Color(0xFFF7F8F9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppColors.lightGrey.withOpacity(.8),
                      width: 1,
                    ),
                  ),
                  elevation: 4,
                ),
                suggestionsBoxVerticalOffset: 5,
                itemBuilder: (context, suggestion) {
                  if (suggestion == "__no_items__") {
                    return const ListTile(
                      title: Text(
                        "لا يوجد عناصر متاحة",
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final idx = widget.items.indexOf(suggestion);
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          _handleSelection(suggestion, field);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          alignment: Alignment.centerRight,
                          child: Text(
                            suggestion,
                            style: AppTextStyles.regularGrey15.copyWith(fontSize: 13.sp),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                      if (idx != widget.items.length - 1)
                        const Divider(height: 1, color: Color(0xFFE8ECF4)),
                    ],
                  );
                },
                onSuggestionSelected: (suggestion) {
                  if (suggestion != "__no_items__") {
                    _handleSelection(suggestion, field);
                  } else {
                    _focusNode.unfocus();
                    setState(() {
                      isBoxOpen = false;
                      _allowKeyboard = false;
                    });
                  }
                },
                suggestionsCallback: (String pattern) {
                  if (pattern.isEmpty || pattern == 'غير محدد') {
                    return widget.items;
                  }
                  final matches = widget.items
                      .where((item) => item.toLowerCase().contains(pattern.toLowerCase()))
                      .toList();
                  if (matches.isEmpty) {
                    return ["__no_items__"];
                  }
                  return matches;
                },
              ),
            ],
          );
        },
      ),
    );
  }
}