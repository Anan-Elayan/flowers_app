import 'package:flutter/material.dart';

class CustomTextFields extends StatefulWidget {
  const CustomTextFields(
      {Key? key,
      required this.txtLabel,
      required this.txtPrefixIcon,
      this.enableBorderColor,
      this.focusedBorderColor,
      this.disabledBorderColor,
      this.txtSuffixIcon,
      required this.isVisibleContent,
      required this.validate,
      this.backgroundColor,
      this.controller,
      this.hintText,
      this.hintTextColor,
      this.keyBordType,
      this.colorLabelError,
      this.readOnly,
      this.labelTextColor,
      this.labelColor, // New labelColor parameter
      this.maxLength,
      this.onMyTap,
      this.textInputAction,
      this.onSubmitted})
      : super(key: key);

  final String txtLabel;
  final IconData txtPrefixIcon;
  final IconData? txtSuffixIcon;
  final bool isVisibleContent;
  final Color? enableBorderColor;
  final Color? focusedBorderColor;
  final Color? disabledBorderColor;
  final Color? backgroundColor;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyBordType;
  final Color? colorLabelError;
  final String? Function(String? value) validate;
  final Color? hintTextColor;
  final bool? readOnly;
  final Color? labelTextColor;
  final Color? labelColor; // New labelColor parameter
  final int? maxLength;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final Function()? onMyTap;

  @override
  _CustomTextFieldsState createState() => _CustomTextFieldsState();
}

class _CustomTextFieldsState extends State<CustomTextFields> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      onTap: widget.onMyTap,
      keyboardType: widget.keyBordType,
      readOnly: widget.readOnly ?? false,
      maxLength: widget.maxLength,
      onFieldSubmitted: widget.onSubmitted ?? (value) {},
      textInputAction: widget.textInputAction ?? TextInputAction.go,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: widget.hintTextColor ?? Colors.grey),
        labelText: widget.txtLabel,
        labelStyle: TextStyle(
          color:
              widget.labelColor ?? Colors.black, // Use labelColor if provided
        ),
        filled: widget.backgroundColor != null,
        fillColor: widget.backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        prefixIcon: Icon(widget.txtPrefixIcon, color: Colors.black),
        suffixIcon: widget.txtSuffixIcon != null
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black,
                ),
                onPressed: _toggleVisibility,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: widget.enableBorderColor ?? Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: widget.focusedBorderColor ?? Color(0xFF215A0E)),
          borderRadius: BorderRadius.circular(10),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        errorBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: widget.disabledBorderColor ?? Colors.red),
          borderRadius: BorderRadius.circular(10),
        ),
        errorStyle: TextStyle(
          color: widget.colorLabelError, // Use the colorLabelError here
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      obscureText: widget.isVisibleContent ? _obscureText : false,
      validator: widget.validate,
    );
  }
}
