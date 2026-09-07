import 'package:flutter/material.dart';

class CustomDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime> onDateChanged;
  final String? labelText;
  final String? hintText;
  final IconData? icon;
  final bool enabled;
  final TextStyle? textStyle;
  final InputDecoration? decoration;
  final DatePickerMode initialDatePickerMode;
  final Locale? locale;
  final TextDirection? textDirection;
  final TransitionBuilder? builder;
  final DatePickerEntryMode initialEntryMode;
  final SelectableDayPredicate? selectableDayPredicate;
  final String? errorText;
  final bool showError;

  const CustomDatePicker({
    Key? key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    required this.onDateChanged,
    this.labelText,
    this.hintText,
    this.icon,
    this.enabled = true,
    this.textStyle,
    this.decoration,
    this.initialDatePickerMode = DatePickerMode.day,
    this.locale,
    this.textDirection,
    this.builder,
    this.initialEntryMode = DatePickerEntryMode.calendar,
    this.selectableDayPredicate,
    this.errorText,
    this.showError = false,
  }) : super(key: key);

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime? _selectedDate;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    if (_selectedDate != null) {
      _controller.text = _formatDate(_selectedDate!);
    }
  }

  @override
  void didUpdateWidget(CustomDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      _selectedDate = widget.initialDate;
      if (_selectedDate != null) {
        _controller.text = _formatDate(_selectedDate!);
      } else {
        _controller.clear();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!widget.enabled) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      initialDatePickerMode: widget.initialDatePickerMode,
      locale: widget.locale,
      textDirection: widget.textDirection,
      builder: widget.builder,
      initialEntryMode: widget.initialEntryMode,
      selectableDayPredicate: widget.selectableDayPredicate,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _controller.text = _formatDate(picked);
      });
      widget.onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration:
          widget.decoration ??
          InputDecoration(
            // labelText: widget.labelText,
            hintText: widget.hintText ?? 'Select a date',
            prefixIcon: widget.icon != null
                ? Icon(widget.icon)
                : const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.orange),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.deepOrangeAccent, width: 2),
            ),
            errorText: widget.showError ? widget.errorText : null,
            // suffixIcon: widget.enabled
            //     ? IconButton(
            //         icon: const Icon(Icons.clear),
            //         onPressed: () {
            //           setState(() {
            //             _selectedDate = null;
            //             _controller.clear();
            //           });
            //         },
            //       )
            //     : null,
          ),
      style: widget.textStyle,
      readOnly: true,
      enabled: widget.enabled,
      onTap: () => _selectDate(context),
    );
  }
}
