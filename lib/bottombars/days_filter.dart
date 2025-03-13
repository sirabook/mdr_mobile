import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DaysFilter extends StatefulWidget {
  final int? selectedDays;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final Function(int?, {DateTime? startDate, DateTime? endDate}) onFilterChanged;

  const DaysFilter({
    Key? key,
    required this.selectedDays,
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  _DaysFilterState createState() => _DaysFilterState();
}

class _DaysFilterState extends State<DaysFilter> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  int? selectedDays = 1;
  bool isCalendarActive = false; // ตรวจสอบว่ากดใช้ Calendar หรือไม่
  bool isFilterActive = true; // ตรวจสอบว่ากดใช้ Filter หรือไม่

  @override
  void initState() {
    super.initState();
    selectedStartDate = widget.selectedStartDate;
    selectedEndDate = widget.selectedEndDate;
    selectedDays = widget.selectedDays ?? 1;
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(now.year - 10);
    final DateTime lastDate = DateTime(now.year + 10);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: (selectedStartDate != null && selectedEndDate != null)
          ? DateTimeRange(start: selectedStartDate!, end: selectedEndDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        selectedStartDate = picked.start;
        selectedEndDate = picked.end;
        selectedDays = null; // ล้างค่าจำนวนวันเมื่อเลือกช่วงเวลา
        isCalendarActive = true; // ทำให้ปุ่ม Calendar เป็นสีเขียว
        isFilterActive = false; // ปิดสีเขียวของ Filter
      });
      widget.onFilterChanged(null, startDate: picked.start, endDate: picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedStartDate = null;
                  selectedEndDate = null;
                  selectedDays = 1;
                  isCalendarActive = false; // รีเซ็ตสีปุ่ม Calendar
                  isFilterActive = true; // ทำให้ Filter เป็นสีเขียว
                });
                widget.onFilterChanged(1);
              },
              child: _buildMainButton("Filter", 
              isFilterActive ? Colors.green : Colors.white,
              isFilterActive ? Colors.white : Colors.black,
               ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _selectDateRange(context),
              child: _buildMainButton(
                "Calendar",
                isCalendarActive ? Colors.green : Colors.white,
                isCalendarActive ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (isFilterActive) // ✅ แสดงตัวเลือก 1 day, 7 days, 15 days, 30 days เฉพาะตอนกด Filter
          Wrap(
            spacing: 8,
            children: [
              _buildFilterButton("1 day", 1),
              _buildFilterButton("7 days", 7),
              _buildFilterButton("15 days", 15),
              _buildFilterButton("30 days", 30),
            ],
          ),
        // ✅ แสดงวันที่เฉพาะเมื่อเลือกจาก Calendar
        if (selectedStartDate != null && selectedEndDate != null && selectedDays == null)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "${DateFormat('dd MMM yyyy').format(selectedStartDate!)} - ${DateFormat('dd MMM yyyy').format(selectedEndDate!)}",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildMainButton(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFilterButton(String label, int value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          DateTime now = DateTime.now();
          selectedStartDate = now.subtract(Duration(days: value - 1));
          selectedEndDate = now;
          selectedDays = value;
          isCalendarActive = false; // ปิดสีเขียวของ Calendar
          isFilterActive = true; // ทำให้ Filter เป็นสีเขียว
        });
        widget.onFilterChanged(value, startDate: selectedStartDate, endDate: selectedEndDate);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: selectedDays == value ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selectedDays == value ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
