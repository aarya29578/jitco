import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

// class FormUnknownDropdown<T> extends StatelessWidget {
//   final String title;
//   final String hint;
//   final List<T> items;
//   final String Function(T) displayItem;
//   final T? selectedValue;
//   final Function(T?)? onChanged;
//   final bool enabled;
//   final String? errorText;

//   const FormUnknownDropdown({
//     super.key,
//     required this.title,
//     required this.hint,
//     required this.items,
//     required this.displayItem,
//     required this.selectedValue,
//     required this.onChanged,
//     this.enabled = true,
//     this.errorText,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Debug logs to understand the issue
//     print('=== FormUnknownDropdown Debug ===');
//     print('Type: $T');
//     print('Title: $title');
//     print('Items count: ${items.length}');
//     print('Selected value: $selectedValue');
//     print('Selected value type: ${selectedValue?.runtimeType}');

//     if (items.isNotEmpty) {
//       print('First item: ${items.first} (type: ${items.first.runtimeType})');
//       print('First item display: ${displayItem(items.first)}');
//     }

//     // Check if selectedValue exists in items
//     bool valueExists = false;
//     if (selectedValue != null) {
//       valueExists = items.any((item) => item == selectedValue);
//       print('Selected value exists in items: $valueExists');

//       // If not found, check by string representation
//       if (!valueExists) {
//         print('WARNING: Selected value not found in items list!');
//         print('Selected: $selectedValue');
//         print('Available items:');
//         for (var item in items) {
//           print('  - $item (display: ${displayItem(item)})');
//         }
//       }
//     }

//     print('===============================');

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.black54,
//           ),
//         ),
//         8.heightBox,
//         DropdownButtonFormField<T>(
//           // Only set value if it exists in items, otherwise null
//           value: valueExists ? selectedValue : null,
//           items: items
//               .map(
//                 (item) => DropdownMenuItem(
//                   value: item,
//                   child: Text(displayItem(item)),
//                 ),
//               )
//               .toList(),
//           onChanged: enabled ? onChanged : null,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(
//                 color: Colors.deepOrangeAccent,
//                 width: 2,
//               ),
//             ),
//             hintText: hint,
//             errorText: errorText,
//             // Add a hint when no value is selected
//             hintStyle: valueExists == false && selectedValue != null
//                 ? TextStyle(color: Colors.orange)
//                 : null,
//           ),
//           isExpanded: true,
//           // Add validator to show error if value is not in list
//           validator: (value) {
//             if (selectedValue != null && !valueExists) {
//               return 'Selected value not found in list';
//             }
//             return null;
//           },
//           // Show hint when no valid value is selected
//           hint: valueExists == false && selectedValue != null
//               ? Text(
//                   'Cannot find: $selectedValue',
//                   style: TextStyle(color: Colors.orange),
//                 )
//               : Text(hint),
//         ),
//       ],
//     );
//   }
// }

///********************************NOW WE USING THIS */
// class SearchableListBottomSheet<T> extends StatefulWidget {
//   final String title;
//   final List<T> items;
//   final String Function(T) displayItem;

//   const SearchableListBottomSheet({
//     super.key,
//     required this.title,
//     required this.items,
//     required this.displayItem,
//   });

//   @override
//   State<SearchableListBottomSheet<T>> createState() =>
//       _SearchableListBottomSheetState<T>();
// }

// class _SearchableListBottomSheetState<T>
//     extends State<SearchableListBottomSheet<T>> {
//   String query = "";

//   @override
//   Widget build(BuildContext context) {
//     final filteredItems = widget.items
//         .where(
//           (item) => widget
//               .displayItem(item)
//               .toLowerCase()
//               .contains(query.toLowerCase()),
//         )
//         .toList();

//     return DraggableScrollableSheet(
//       expand: false,

//       ///KEY SETTINGS
//       initialChildSize: 1.0, // Opens FULL SCREEN
//       minChildSize: 0.6, //  Allows drag down
//       maxChildSize: 1.0, // Prevents overscroll
//       builder: (_, controller) {
//         return SafeArea(
//           child: Container(
//             // color: Colors.white,
//             // height: MediaQuery.of(context).size.height * 0.85,
//             padding: EdgeInsets.all(16),
//             // padding: EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 Text(
//                   widget.title,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black54,
//                   ),
//                 ),

//                 // DefaultTextStyle.merge(
//                 //   style: const TextStyle(
//                 //     fontSize: 28,
//                 //     fontWeight: FontWeight.bold,
//                 //     color: Colors.black,
//                 //   ),
//                 //   child: Text(widget.title),
//                 // ),
//                 10.heightBox,

//                 TextField(
//                   decoration: InputDecoration(
//                     hintText: "Search...",
//                     prefixIcon: Icon(Icons.search),
//                     border: OutlineInputBorder(),
//                   ),
//                   onChanged: (value) {
//                     setState(() => query = value);
//                   },
//                 ),

//                 10.heightBox,

//                 Expanded(
//                   child: ListView.builder(
//                     controller: controller,
//                     itemCount: filteredItems.length,
//                     itemBuilder: (_, index) {
//                       final item = filteredItems[index];

//                       return ListTile(
//                         title: Text(widget.displayItem(item)),
//                         onTap: () => Navigator.pop(context, item),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
class SearchableListBottomSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) displayItem;

  const SearchableListBottomSheet({
    super.key,
    required this.title,
    required this.items,
    required this.displayItem,
  });

  @override
  State<SearchableListBottomSheet<T>> createState() =>
      _SearchableListBottomSheetState<T>();
}

class _SearchableListBottomSheetState<T>
    extends State<SearchableListBottomSheet<T>> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    final trimmedQuery = query.trim().toLowerCase();

    // Filter items based on trimmed query
    final filteredItems = widget.items
        .where(
          (item) =>
              widget.displayItem(item).toLowerCase().contains(trimmedQuery),
        )
        .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 1.0, // Opens FULL SCREEN
      minChildSize: 0.6, // Allows drag down
      maxChildSize: 1.0, // Prevents overscroll
      builder: (_, controller) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              15.heightBox,
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Get.back();
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                ],
              ),
              10.heightBox,

              TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() => query = value);
                },
              ),
              10.heightBox,

              // Show "No results" if filtered list is empty
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Text(
                          'No ${widget.title} found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: controller,
                        itemCount: filteredItems.length,
                        itemBuilder: (_, index) {
                          final item = filteredItems[index];

                          return ListTile(
                            title: Text(widget.displayItem(item)),
                            onTap: () => Navigator.pop(context, item),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
