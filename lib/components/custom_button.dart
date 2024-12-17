import 'package:flowers_app/constants/constants.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    required this.buttonText,
    required this.bgButtonColor,
    this.buttonBorderColor,
    required this.onPress,
    this.iconButton,
    this.colorIconButton,
    this.iconSize,
    this.colorTextButton,
    this.sizeTextButton,
    this.elevation,
  });

  final String buttonText;
  final Color bgButtonColor;
  final Color? buttonBorderColor;
  final VoidCallback? onPress;
  final IconData? iconButton;
  final Color? colorIconButton;
  final double? iconSize;
  final double? sizeTextButton;
  final Color? colorTextButton;
  final double? elevation;

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  Color? _currentBgColor;

  @override
  void initState() {
    super.initState();
    _currentBgColor = widget.bgButtonColor;
  }

  void _onTap() {
    setState(() {
      _currentBgColor = secondaryColor;
    });
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _currentBgColor = widget.bgButtonColor;
      });
    });
    if (widget.onPress != null) {
      widget.onPress!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: widget.elevation ?? 0.0,
      borderRadius: BorderRadius.circular(50.0),
      color: Colors.transparent,
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          height: MediaQuery.of(context).size.height / 13,
          width: MediaQuery.of(context).size.width / 1.1,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.0),
            border: Border.all(color: widget.buttonBorderColor ?? Colors.white),
            color: _currentBgColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.buttonText,
                style: TextStyle(
                  color: widget.colorTextButton ?? Colors.white,
                  fontSize: widget.sizeTextButton,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              if (widget.iconButton != null) SizedBox(width: 8),
              Icon(
                widget.iconButton,
                color: widget.colorIconButton,
                size: widget.iconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
