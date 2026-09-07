// widgets/delivery_address.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/B_controllers/auth_controllers.dart';
import 'package:jitco_app/JItco_Main/Bmain/B_JitMenu/Controllers/jm_cart_controller.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/J_Screens/A_Home%20and%20Drawer/a_Home_Drawer/drawer_screens/C_Profile_Settings/profile_outlet_form.dart';
import 'package:jitco_app/JItco_Main/Bmain/A_Jitco_Supply/C_services/api_service.dart';
// import 'package:jitco_app/controllers/cart_controller.dart';

class DeliveryAddressSection extends StatefulWidget {
  final Function(bool)? selectedValue;
  final Function(String)? onCitySelected;
  final Function(String)? onOutletSelected;
  final Function(String)? onAddressStringSelected;
  final String? label;
  final bool required;
  final bool showAddButton;

  const DeliveryAddressSection({
    super.key,
    this.selectedValue,
    this.onCitySelected,
    this.onOutletSelected,
    this.onAddressStringSelected,
    this.label = 'Delivery Address *',
    this.required = false,
    this.showAddButton = true,
  });

  @override
  State<DeliveryAddressSection> createState() => _DeliveryAddressSectionState();
}

class _DeliveryAddressSectionState extends State<DeliveryAddressSection> {
  final ApiServices apiService = Get.find<ApiServices>();
  final JmCartController cartController = Get.find<JmCartController>();
  final AuthController _authController = Get.find<AuthController>();
  List<Map<String, dynamic>> outlets = [];
  bool isLoading = true;
  String? error;
  String? _displayText;
  String? _selectedOutletId;
  String? _selectedCity;

  // Store previous selection for rollback
  String? _previousOutletId;
  String? _previousCity;
  bool _isProcessingChange = false;

  // Track temporary selection for UI only
  String? _tempSelectedOutletId;

  final GetStorage _storage = GetStorage();

  @override
  void initState() {
    super.initState();
    _loadOutlets();
  }

  Future<void> _loadOutlets() async {
    setState(() {
      isLoading = true;
      error = null;
      _displayText = null;
    });

    try {
      final response = await apiService.getUserOutlet();

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        setState(() {
          outlets = data.map((item) => item as Map<String, dynamic>).toList();
        });

        // Try to load previously selected address
        _loadSavedAddress();

        // Update display text
        _updateDisplayText();
      } else {
        setState(() {
          error = response['message'] ?? 'Failed to load addresses';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Load saved address from storage
  void _loadSavedAddress() {
    try {
      // You can use GetStorage, SharedPreferences, or a simple key-value storage
      // For now, let's use a simple approach with GetStorage
      final savedOutletId = _getSavedOutletId();
      if (savedOutletId != null && savedOutletId.isNotEmpty) {
        // Check if this outlet exists in the loaded list
        final outletExists = outlets.any(
          (outlet) => outlet['_id']?.toString() == savedOutletId,
        );

        if (outletExists) {
          _selectedOutletId = savedOutletId;

          // Also get the city for this outlet
          final selectedOutlet = outlets.firstWhere(
            (outlet) => outlet['_id']?.toString() == savedOutletId,
          );

          if (selectedOutlet.isNotEmpty) {
            _selectedCity = selectedOutlet['city']?['name']?.toString() ?? '';
            final addressStr = selectedOutlet['address']?.toString() ?? '';

            // Notify parent about selected address
            widget.selectedValue?.call(true);
            widget.onOutletSelected?.call(savedOutletId);
            if (_selectedCity != null && _selectedCity!.isNotEmpty) {
              widget.onCitySelected?.call(_selectedCity!);
            }
            widget.onAddressStringSelected?.call(addressStr);
          }
        }
      }
    } catch (e) {
      print('Error loading saved address: $e');
    }
  }

  // Save address to storage
  void _saveAddress(String outletId) {
    try {
      _setSavedOutletId(outletId);
    } catch (e) {
      print('Error saving address: $e');
    }
  }

  // Simple in-memory storage (replace with GetStorage/SharedPreferences)
  static String? _savedOutletId;

  String? _getSavedOutletId() {
    // return _savedOutletId;
    return _storage.read('selectedDeliveryAddress');
    // Replace with: return GetStorage().read('selectedDeliveryAddress');
  }

  void _setSavedOutletId(String outletId) {
    // _savedOutletId = outletId;
    _storage.write('selectedDeliveryAddress', outletId);
    // Replace with: GetStorage().write('selectedDeliveryAddress', outletId);
  }

  void _updateDisplayText() {
    // Use temporary ID for display if it exists, otherwise use actual selected ID
    final displayId = _tempSelectedOutletId ?? _selectedOutletId;

    if (displayId == null || outlets.isEmpty) {
      setState(() {
        _displayText = 'Select delivery address';
      });
      return;
    }

    // Find the selected outlet
    final selectedOutlet = outlets.firstWhere(
      (outlet) => outlet['_id']?.toString() == displayId,
      orElse: () => {},
    );

    if (selectedOutlet.isEmpty) {
      setState(() {
        _displayText = 'Select delivery address';
      });
      return;
    }

    final String name = selectedOutlet['name']?.toString() ?? '';
    final String address = selectedOutlet['address']?.toString() ?? '';
    final String city = selectedOutlet['city']?['name']?.toString() ?? '';
    final String state = selectedOutlet['state']?['name']?.toString() ?? '';
    final String pinCode = selectedOutlet['pin_code']?.toString() ?? '';

    if (address.isNotEmpty) {
      final location = [
        city,
        state,
        pinCode,
      ].where((e) => e.isNotEmpty).join(', ');
      setState(() {
        _displayText =
            '$name - $address${location.isNotEmpty ? ', $location' : ''}';
      });
    } else {
      setState(() {
        _displayText = name;
      });
    }
  }

  void _handleSelection(String? newValue) async {
    if (_isProcessingChange) return;

    if (newValue == null) {
      // Handle null selection (deselection)
      setState(() {
        _selectedOutletId = null;
        _selectedCity = null;
        _tempSelectedOutletId = null;
      });

      widget.selectedValue?.call(false);
      widget.onOutletSelected?.call('');
      widget.onCitySelected?.call('');

      _updateDisplayText();
      return;
    }

    if (newValue == 'add_new') {
      Get.to(
        () => ProfileOutletForm(
          title: 'Add New Delivery Address',
          saveOutlet: 'Add Address',
        ),
      )?.then((value) {
        if (value == true) {
          _loadOutlets();
        }
      });
    } else {
      // IMMEDIATELY update UI to show the selected address (temporary)
      setState(() {
        _tempSelectedOutletId = newValue;
      });

      // Update display text immediately so user sees the selection
      _updateDisplayText();

      // Get city name from selected outlet
      String? newCity;
      if (newValue != null) {
        final selectedOutlet = outlets.firstWhere(
          (outlet) => outlet['_id']?.toString() == newValue,
          orElse: () => {},
        );

        if (selectedOutlet.isNotEmpty) {
          newCity = selectedOutlet['city']?['name']?.toString() ?? '';
        }
      }

      // Check if this is a different address (not null to null or same to same)
      bool isDifferentAddress =
          (_previousOutletId != newValue) &&
          !(_previousOutletId == null && newValue == null);

      if (isDifferentAddress && newCity != null && newCity.isNotEmpty) {
        _isProcessingChange = true;

        try {
          // First check if there are any items in cart
          if (cartController.cartItems.isEmpty) {
            // No items in cart, just update address without price check
            _finalizeAddressChange(newValue, newCity);
            _isProcessingChange = false;
            return;
          }

          // Store current warehouse before potential change
          final String previousWarehouseId =
              cartController.currentWarehouseId.value;

          // Fetch warehouse ID for the new city
          final warehouseResponse = await apiService.getWarehouseIdByCity(
            encodedCity: newCity,
          );

          String warehouseId = '';
          if (warehouseResponse['data'] != null) {
            if (warehouseResponse['data'] is List) {
              final warehouseList = warehouseResponse['data'] as List;
              if (warehouseList.isNotEmpty) {
                warehouseId = warehouseList[0]['_id'] ?? '';
              }
            } else if (warehouseResponse['data'] is Map) {
              warehouseId = warehouseResponse['data']['_id'] ?? '';
            }
          }

          // if (warehouseId.isEmpty) {
          //   // No warehouse found, update address without price changes
          //   _finalizeAddressChange(newValue, newCity);
          //   Get.snackbar(
          //     'No Warehouse Found',
          //     'Could not find warehouse for $newCity',
          //     backgroundColor: Colors.orange,
          //     colorText: Colors.white,
          //   );
          //   _isProcessingChange = false;
          //   return;
          // }

          // === MODIFIED/ADDED LOGIC STARTS HERE ===
          if (warehouseId.isEmpty) {
            // No warehouse found - show confirmation dialog
            final bool? confirmed = await _showAddressChangeConfirmationDialog(
              newCity,
            );

            if (confirmed == true) {
              // User confirmed to proceed without warehouse
              await cartController.updateCartPrices(
                warehouseId,
                _authController.userId.value,
                newCity,
              );
              // Update address without price changes
              _finalizeAddressChange(newValue, newCity);

              // Show warning about no warehouse
              Get.snackbar(
                'No Warehouse Found',
                'Could not find warehouse for $newCity. Prices may not be updated.',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
                duration: Duration(seconds: 3),
              );
            } else {
              // User cancelled, roll back UI
              _rollbackAddressChange();
            }
            _isProcessingChange = false;
            return;
          }

          // Check if warehouse is different
          if (warehouseId != previousWarehouseId) {
            // Show confirmation dialog
            final bool? confirmed = await _showAddressChangeConfirmationDialog(
              newCity,
            );

            if (confirmed == true) {
              // User confirmed, update prices and address
              await cartController.updateCartPrices(
                warehouseId,
                _authController.userId.value,
                newCity,
              );

              // FINALIZE the address change AFTER price update
              _finalizeAddressChange(newValue, newCity);
            } else {
              // User cancelled, roll back UI - IMPORTANT: Clear temp value
              _rollbackAddressChange();
            }
          } else {
            // Same warehouse, just update address
            _finalizeAddressChange(newValue, newCity);
          }
        } catch (e) {
          print('Error handling address change: $e');
          // Even if error occurs, update address
          _finalizeAddressChange(newValue, newCity);
        } finally {
          _isProcessingChange = false;
        }
      } else {
        // Same address or no city, just update
        _finalizeAddressChange(newValue, newCity);
      }
    }
  }

  Future<bool?> _showAddressChangeConfirmationDialog(String cityName) async {
    return await Get.dialog<bool>(
      WillPopScope(
        onWillPop: () async => false, // Disable back button
        child: AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Update Cart Prices?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Changing your delivery address to $cityName may update product prices based on the nearest warehouse.",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 10),
              Text(
                "Do you want to proceed with this address change?",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(Get.overlayContext!).pop(false),
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(Get.overlayContext!).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
              ),
              child: Text("Yes, Change Address"),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _finalizeAddressChange(String? outletId, String? city) {
    setState(() {
      _tempSelectedOutletId = null;
      _selectedOutletId = outletId;
      _selectedCity = city;
    });

    if (outletId != null) {
      _saveAddress(outletId);
    }

    //THIS WAS MISSING
    widget.selectedValue?.call(outletId != null);
    widget.onOutletSelected?.call(outletId ?? '');
    if (city != null && city.isNotEmpty) {
      widget.onCitySelected?.call(city);
    }
    
    // Pass the actual address string
    if (outletId != null && outlets.isNotEmpty) {
      final selectedOutlet = outlets.firstWhere(
        (o) => o['_id']?.toString() == outletId,
        orElse: () => {},
      );
      if (selectedOutlet.isNotEmpty) {
        widget.onAddressStringSelected?.call(selectedOutlet['address']?.toString() ?? '');
      }
    }

    _updateDisplayText();

    _previousOutletId = null;
    _previousCity = null;
  }

  void _rollbackAddressChange() {
    // Clear temporary value and revert to actual selected ID
    setState(() {
      _tempSelectedOutletId = null;
    });

    // Update display text with actual selected value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _updateDisplayText();
      });
    });

    // Clear previous values
    _previousOutletId = null;
    _previousCity = null;
  }

  @override
  void didUpdateWidget(DeliveryAddressSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update display text when selectedValue changes from parent
    if (_selectedOutletId != null) {
      _updateDisplayText();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            if (widget.label != null)
              Row(
                children: [
                  Text(
                    widget.label!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (widget.required)
                    Text(
                      ' *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),

            if (widget.label != null) 8.heightBox,

            // Dropdown Container with fixed height
            Container(
              constraints: BoxConstraints(minHeight: 56, maxHeight: 100),
              decoration: BoxDecoration(
                border: Border.all(
                  color: error != null
                      ? Colors.red.shade300
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dropdown Button with fixed height items
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        // Use temporary value for display, but actual value for dropdown state
                        value: _tempSelectedOutletId ?? _selectedOutletId,
                        isExpanded: true,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey.shade600,
                          size: 24,
                        ),
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                        hint: isLoading
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                  8.widthBox,
                                  Text(
                                    'Loading addresses...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                _displayText ?? 'Select delivery address',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _selectedOutletId != null
                                      ? Colors.black87
                                      : Colors.grey.shade600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                        items: [
                          // DEFAULT "SELECT ADDRESS" OPTION (ADD THIS)
                          // DropdownMenuItem<String>(
                          //   value: null, // null value for default option
                          //   enabled: false, // Disable selection of this item
                          //   child: Container(
                          //     height: 48,
                          //     alignment: Alignment.centerLeft,
                          //     child: Text(
                          //       'Select delivery address',
                          //       style: TextStyle(
                          //         color: Colors.grey.shade600,
                          //         fontStyle: FontStyle.italic,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // Add new address option
                          if (widget.showAddButton)
                            DropdownMenuItem<String>(
                              value: 'add_new',
                              child: Container(
                                height: 48, // Fixed height
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.orange.shade700,
                                      size: 18,
                                    ),
                                    8.widthBox,
                                    Flexible(
                                      child: Text(
                                        'Add New Address',
                                        style: TextStyle(
                                          color: Colors.orange.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Address items with fixed height
                          ...outlets.map((outlet) {
                            final id = outlet['_id']?.toString() ?? '';
                            final name =
                                outlet['name']?.toString() ?? 'No Name';
                            final address = outlet['address']?.toString() ?? '';
                            final city =
                                outlet['city']?['name']?.toString() ?? '';
                            final state =
                                outlet['state']?['name']?.toString() ?? '';
                            final pinCode =
                                outlet['pin_code']?.toString() ?? '';

                            final isSelected = id == _selectedOutletId;

                            return DropdownMenuItem<String>(
                              value: id,
                              child: Container(
                                height: 100, // Fixed height for each item
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Name with selection indicator
                                    Row(
                                      children: [
                                        if (isSelected)
                                          Icon(
                                            Icons.check_circle,
                                            size: 16,
                                            color: Colors.orange.shade700,
                                          ),
                                        if (isSelected) 6.widthBox,
                                        Flexible(
                                          child: Text(
                                            name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              color: isSelected
                                                  ? Colors.orange.shade800
                                                  : Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Address - only show if there's space
                                    if (address.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: Text(
                                          '${address} - ${[city, state, pinCode].where((e) => e.isNotEmpty).join(', ')}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: _handleSelection,
                      ),
                    ),
                  ),

                  // Error message
                  if (error != null)
                    Container(
                      padding: EdgeInsets.fromLTRB(12, 4, 12, 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 14,
                            color: Colors.red,
                          ),
                          4.widthBox,
                          Flexible(
                            child: Text(
                              error!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Selected city display
            if (_selectedCity != null)
              Container(
                padding: EdgeInsets.only(top: 8, left: 4),
                child: Row(
                  children: [
                    Icon(Icons.location_city, size: 14, color: Colors.blue),
                    SizedBox(width: 4),
                    Text(
                      'City: $_selectedCity',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),

            // Refresh button (if error or empty) - FIXED HEIGHT
            if (error != null || outlets.isEmpty)
              Container(
                height: 40, // Fixed height to prevent overflow
                margin: EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    if (widget.showAddButton && outlets.isEmpty)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Get.to(
                              () => ProfileOutletForm(
                                title: 'Add New Outlet Address',
                                saveOutlet: 'Add Outlet Address',
                              ),
                            )?.then((value) {
                              if (value == true) {
                                _loadOutlets();
                              }
                            });
                          },
                          icon: Icon(Icons.add, size: 14),
                          label: Text(
                            'Add Address',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange.shade700,
                            side: BorderSide(color: Colors.orange.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                        ),
                      ),

                    if (error != null &&
                        widget.showAddButton &&
                        outlets.isEmpty)
                      8.widthBox,

                    if (error != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _loadOutlets,
                          icon: Icon(Icons.refresh, size: 14),
                          label: Text('Retry', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
