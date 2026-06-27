import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:khuta/core/theme/input_themes.dart';
import 'package:khuta/core/utils/haptic_utils.dart';
import 'package:khuta/models/child.dart';

class AddChildScreen extends StatefulWidget {
  final Function(Child) onAddChild;

  const AddChildScreen({super.key, required this.onAddChild});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _selectedAge = 6;
  String _selectedGender = 'male';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      HapticUtils.success();
      setState(() => _isLoading = true);

      final newChild = Child(
        id: '',
        name: _nameController.text.trim(),
        gender: _selectedGender,
        age: _selectedAge,
        testResults: [],
        createdAt: DateTime.now(),
      );

      widget.onAddChild(newChild);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: isDark
            ? InputThemes.darkInputTheme
            : InputThemes.lightInputTheme,
        dropdownMenuTheme: isDark
            ? InputThemes.darkDropdownTheme
            : InputThemes.lightDropdownTheme,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF1A202C)
            : const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text('add_new_child'.tr()),
          backgroundColor: isDark ? const Color(0xFF2D3748) : Colors.white,
          foregroundColor: isDark ? Colors.white : const Color(0xFF2D3748),
          elevation: 0,
          leading: IconButton(
            icon: Icon(isRTL ? Icons.arrow_forward : Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 20 : 40),
              child: Container(
                width: isMobile ? double.infinity : 600,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2D3748) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.05,
                      ),
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
                      // Header with icon
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color:
                                (isDark
                                        ? const Color(0xFF63B3ED)
                                        : const Color(0xFF4299E1))
                                    .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.child_care,
                            size: 40,
                            color: isDark
                                ? const Color(0xFF63B3ED)
                                : const Color(0xFF4299E1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'child_name'.tr(),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'name_required'.tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Gender selection with radio tiles
                      Text(
                        'gender'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildGenderOption(
                              'male',
                              Icons.boy,
                              isDark
                                  ? const Color(0xFF63B3ED)
                                  : const Color(0xFF4299E1),
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildGenderOption(
                              'female',
                              Icons.girl,
                              isDark
                                  ? const Color(0xFFF687B3)
                                  : const Color(0xFFED64A6),
                              isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Age selection
                      Text(
                        'age'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: InputThemes.getDropdownDecoration(isDark),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedAge,
                            isExpanded: true,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                            dropdownColor: isDark
                                ? const Color(0xFF2D3748)
                                : Colors.white,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF2D3748),
                              fontSize: 16,
                            ),
                            items: List.generate(12, (index) => index + 6)
                                .map(
                                  (age) => DropdownMenuItem(
                                    value: age,
                                    child: Text('$age ${'years'.tr()}'),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                HapticUtils.selectionClick();
                                setState(() => _selectedAge = value);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color(0xFF63B3ED)
                                : const Color(0xFF4299E1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'add'.tr(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(
    String gender,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    final isSelected = _selectedGender == gender;
    return InkWell(
      onTap: () {
        HapticUtils.selectionClick();
        setState(() => _selectedGender = gender);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.15 : 0.1)
              : isDark
              ? const Color(0xFF2D3748)
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? color
                : (isDark
                      ? Colors.grey.shade800
                      : Colors.grey.withValues(alpha: 0.3)),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? color
                  : (isDark ? Colors.white70 : Colors.grey),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              gender.tr(),
              style: TextStyle(
                color: isSelected
                    ? color
                    : (isDark ? Colors.white : const Color(0xFF2D3748)),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
