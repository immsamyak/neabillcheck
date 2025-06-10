import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;

import '../../utils/colors.dart';

class BillCheckScreen extends StatefulWidget {
  const BillCheckScreen({super.key});

  @override
  State<BillCheckScreen> createState() => _BillCheckScreenState();
}

class _BillCheckScreenState extends State<BillCheckScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _billData;
  final _formKey = GlobalKey<FormState>();
  String _selectedLocation = "NEPALGUNJ "; // Set default value
  bool _isDisposed = false;

  // Controllers for input fields
  final TextEditingController _scNoController = TextEditingController();
  final TextEditingController _customerIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedLocation = "NEPALGUNJ "; // Set default value in initState
  }

  // NEA Office Locations with their codes
  final Map<String, int> _locations = {
    "NEPALGUNJ ": 256,
    "KATHMANDU ": 201,
    "POKHARA ": 226,
    "BIRATNAGAR ": 285,
    "BIRGUNJ ": 286,
    "BUTWAL ": 229,
    "HETAUDA ": 231,
    "DHARAN ": 212,
    "ITAHARI ": 264,
    "BHARATPUR ": 211,
    // Add more locations as needed
  };

  @override
  void dispose() {
    _isDisposed = true;
    _scNoController.dispose();
    _customerIdController.dispose();
    super.dispose();
  }

  Future<void> checkNeaBill(
    String scNo,
    String customerId,
    String location,
  ) async {
    if (_isDisposed) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final locationCode = _locations[location];
      if (locationCode == null) {
        throw Exception('Invalid location selected');
      }

      final url = Uri.parse(
        'https://www.neabilling.com/viewonline/viewonlineresult/',
      );

      // Create form data
      final formData = {
        'NEA_location': locationCode.toString(),
        'sc_no': scNo,
        'consumer_ID': customerId,
      };

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "User-Agent": "Mozilla/5.0",
          "Accept":
              "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        },
        body: formData,
      );

      // Check if widget is still mounted before proceeding
      if (_isDisposed) return;

      if (response.statusCode == 200) {
        // Parse HTML response
        final document = htmlParser.parse(response.body);

        try {
          // Check for "No Records" first
          if (response.body.contains('No Records')) {
            throw Exception('Record not found. Please check your information.');
          }

          // Parse customer name from the table structure
          String? name;
          String? amount;
          bool hasUnpaidBill = false;

          // Find customer name from the Consumer Detail section
          document.querySelectorAll('tr').forEach((row) {
            final cells = row.querySelectorAll('td');
            if (cells.length >= 2) {
              final label = cells[0].text.trim();
              if (label == 'Customer Name') {
                name = cells[1].text.trim();
              }
            }
          });

          // Find bill amount from the Bill Detail section
          document.querySelectorAll('tr').forEach((row) {
            final cells = row.querySelectorAll('td');
            if (cells.length >= 7) {
              // Bill detail rows have multiple columns
              final status = cells[1].text.trim();
              final billAmt = cells[5].text.trim(); // PAYABLE AMOUNT column

              // Check if this is a bill row and not a header
              if (status.contains('PAY ADVANCE')) {
                final amt = double.tryParse(
                      billAmt.replaceAll(RegExp(r'[^0-9.-]'), ''),
                    ) ??
                    0.0;
                if (amt > 0) {
                  amount = amt.toString();
                  hasUnpaidBill = true;
                }
              }
            }
          });

          // Validate the parsed data
          if (name?.isEmpty ?? true) {
            throw Exception('Could not find customer name in the response');
          }

          // At this point we know name is non-null
          final String validName = name!;
          final bool isPaid = !hasUnpaidBill;
          final String validAmount = amount ?? '0.0';

          if (!_isDisposed) {
            setState(() {
              _billData = {
                'name': validName,
                'amount': double.tryParse(validAmount) ?? 0.0,
                'status': isPaid ? 'Paid' : 'Unpaid',
                'scNo': scNo,
                'customerId': customerId,
                'location': location,
                'dueDate': DateTime.now().add(const Duration(days: 7)),
              };
            });

            if (mounted) {
              final message = isPaid
                  ? 'Hello $validName, your amount has been paid!'
                  : 'Hello $validName, you have to pay Rs. $validAmount';

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: isPaid ? Colors.green : Colors.orange,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          }
        } catch (e) {
          if (!_isDisposed && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
          throw Exception(e.toString());
        }
      } else {
        if (!_isDisposed) {
          setState(() {
            _billData = null;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Error: Unable to fetch bill. Please try again.',
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          _billData = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } finally {
      if (!_isDisposed) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'NEA Bill Check',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.electric_bolt_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Check Your Bill',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Enter your details below',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form Section
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(
                        controller: _scNoController,
                        label: 'SC Number',
                        hint: 'Enter your SC number',
                        icon: Icons.numbers_rounded,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter SC number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        controller: _customerIdController,
                        label: 'Customer ID',
                        hint: 'Enter your customer ID',
                        icon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter customer ID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildDropdownField(
                        value: _selectedLocation,
                        label: 'NEA Office Location',
                        hint: 'Select your NEA office location',
                        icon: Icons.location_on_outlined,
                        items: _locations.keys.map((String location) {
                          return DropdownMenuItem<String>(
                            value: location,
                            child: Text(
                              location,
                              style: const TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 15,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedLocation = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    checkNeaBill(
                                      _scNoController.text,
                                      _customerIdController.text,
                                      _selectedLocation,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Check Bill',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bill Details Section
              if (_billData != null) ...[
                const SizedBox(height: 24),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Bill Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                _billData!['status'],
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _billData!['status'].toLowerCase() == 'paid'
                                      ? Icons.check_circle_rounded
                                      : Icons.pending_rounded,
                                  color: _getStatusColor(_billData!['status']),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _billData!['status'],
                                  style: TextStyle(
                                    color: _getStatusColor(
                                      _billData!['status'],
                                    ),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildDetailRow(
                        'Customer Name',
                        _billData!['name'],
                        icon: Icons.person_rounded,
                      ),
                      _buildDetailRow(
                        'SC Number',
                        _billData!['scNo'],
                        icon: Icons.numbers_rounded,
                      ),
                      _buildDetailRow(
                        'Customer ID',
                        _billData!['customerId'],
                        icon: Icons.badge_rounded,
                      ),
                      _buildDetailRow(
                        'Location',
                        _billData!['location'],
                        icon: Icons.location_on_rounded,
                      ),
                      _buildDetailRow(
                        'Amount Due',
                        'Rs. ${_billData!['amount'].toStringAsFixed(2)}',
                        icon: Icons.payments_rounded,
                        isHighlighted: true,
                      ),
                      _buildDetailRow(
                        'Due Date',
                        '${_billData!['dueDate'].day}/${_billData!['dueDate'].month}/${_billData!['dueDate'].year}',
                        icon: Icons.event_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
            prefixIcon: Icon(icon, color: Colors.grey[400], size: 22),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[300]!, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[300]!, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
            prefixIcon: Icon(icon, color: Colors.grey[400], size: 22),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[300]!, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[300]!, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 24),
          dropdownColor: Colors.white,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a location';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlighted = false,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? AppColors.primary.withOpacity(0.1)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color:
                    isHighlighted ? AppColors.primary : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: isHighlighted
                        ? AppColors.primary
                        : const Color(0xFF1E293B),
                    fontSize: isHighlighted ? 16 : 15,
                    fontWeight:
                        isHighlighted ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
