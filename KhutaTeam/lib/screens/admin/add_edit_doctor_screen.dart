import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/cubit/doctor/doctor_cubit.dart';
import 'package:khuta/cubit/doctor/doctor_state.dart';
import 'package:khuta/models/doctor.dart';

class AddEditDoctorScreen extends StatefulWidget {
  final Doctor? doctor; // null = add new

  const AddEditDoctorScreen({super.key, this.doctor});

  @override
  State<AddEditDoctorScreen> createState() => _AddEditDoctorScreenState();
}

class _AddEditDoctorScreenState extends State<AddEditDoctorScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _specializationController;
  late final TextEditingController _experienceController;
  late final TextEditingController _bioController;
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageUrlController;

  final List<String> _selectedDays = [];
  final List<String> _timeSlots = [];
  final TextEditingController _timeSlotInput = TextEditingController();

  final List<String> _weekDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  bool get _isEditing => widget.doctor != null;

  @override
  void initState() {
    super.initState();
    final d = widget.doctor;
    _nameController = TextEditingController(text: d?.name ?? '');
    _specializationController =
        TextEditingController(text: d?.specialization ?? '');
    _experienceController =
        TextEditingController(text: d?.yearsOfExperience.toString() ?? '');
    _bioController = TextEditingController(text: d?.bio ?? '');
    _phoneController = TextEditingController(text: d?.phoneNumber ?? '');
    _whatsappController =
        TextEditingController(text: d?.whatsappNumber ?? '');
    _emailController = TextEditingController(text: d?.email ?? '');
    _addressController =
        TextEditingController(text: d?.clinicAddress ?? '');
    _priceController =
        TextEditingController(text: d?.consultationPrice.toStringAsFixed(0) ?? '');
    _imageUrlController =
        TextEditingController(text: d?.profileImageUrl ?? '');

    if (d != null) {
      _selectedDays.addAll(d.availableDays);
      _timeSlots.addAll(d.availableTimeSlots);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _timeSlotInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => DoctorCubit(),
      child: BlocConsumer<DoctorCubit, DoctorState>(
        listener: (context, state) {
          if (state.status == DoctorStatus.success) {
            Navigator.pop(context, true);
          }
          if (state.status == DoctorStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'error_occurred'.tr()),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == DoctorStatus.submitting;

          return Scaffold(
            backgroundColor: HomeScreenTheme.backgroundColor(isDark),
            appBar: AppBar(
              title: Text(_isEditing ? 'edit_doctor'.tr() : 'add_doctor'.tr()),
              backgroundColor: const Color(0xFF1A56DB),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildSection(
                    title: 'basic_info'.tr(),
                    isDark: isDark,
                    children: [
                      _buildField(_nameController, 'doctor_name'.tr(),
                          Icons.person_rounded),
                      _buildField(_specializationController,
                          'specialization'.tr(), Icons.medical_services_rounded),
                      _buildField(
                        _experienceController,
                        'years_experience'.tr(),
                        Icons.workspace_premium_rounded,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      _buildField(
                        _bioController,
                        'bio'.tr(),
                        Icons.description_rounded,
                        maxLines: 4,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'contact_info'.tr(),
                    isDark: isDark,
                    children: [
                      _buildField(_phoneController, 'phone_number'.tr(),
                          Icons.phone_rounded,
                          keyboardType: TextInputType.phone),
                      _buildField(_whatsappController,
                          'whatsapp_number'.tr(), Icons.chat_rounded,
                          keyboardType: TextInputType.phone),
                      _buildField(_emailController, 'email'.tr(),
                          Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          required: false),
                      _buildField(_addressController,
                          'clinic_address'.tr(), Icons.location_on_rounded,
                          maxLines: 2),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'pricing'.tr(),
                    isDark: isDark,
                    children: [
                      _buildField(
                        _priceController,
                        'consultation_price'.tr(),
                        Icons.attach_money_rounded,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'profile_image'.tr(),
                    isDark: isDark,
                    children: [
                      _buildField(
                        _imageUrlController,
                        'image_url'.tr(),
                        Icons.image_rounded,
                        required: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDaysSection(isDark),
                  const SizedBox(height: 16),
                  _buildTimeSlotsSection(isDark),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isLoading ? null : () => _submit(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A56DB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _isEditing
                                ? 'save_changes'.tr()
                                : 'add_doctor'.tr(),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HomeScreenTheme.cardBackground(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [HomeScreenTheme.cardShadow(isDark)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: HomeScreenTheme.primaryText(isDark),
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1A56DB)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        validator: required
            ? (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'required_field'.tr();
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildDaysSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HomeScreenTheme.cardBackground(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [HomeScreenTheme.cardShadow(isDark)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'available_days'.tr(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: HomeScreenTheme.primaryText(isDark),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _weekDays.map((day) {
              final isSelected = _selectedDays.contains(day);
              return FilterChip(
                label: Text(day),
                selected: isSelected,
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      _selectedDays.add(day);
                    } else {
                      _selectedDays.remove(day);
                    }
                  });
                },
                selectedColor: const Color(0xFF1A56DB).withValues(alpha: 0.15),
                checkmarkColor: const Color(0xFF1A56DB),
                labelStyle: TextStyle(
                  color: isSelected
                      ? const Color(0xFF1A56DB)
                      : HomeScreenTheme.primaryText(isDark),
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotsSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HomeScreenTheme.cardBackground(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [HomeScreenTheme.cardShadow(isDark)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'time_slots'.tr(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: HomeScreenTheme.primaryText(isDark),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _timeSlotInput,
                  decoration: InputDecoration(
                    hintText: 'time_slot_hint'.tr(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.access_time_rounded,
                        color: Color(0xFF1A56DB)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _addTimeSlot,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A56DB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                child: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_timeSlots.isEmpty)
            Center(
              child: Text(
                'no_time_slots'.tr(),
                style: TextStyle(
                    color: HomeScreenTheme.secondaryText(isDark)),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeSlots.map((slot) {
                return Chip(
                  label: Text(slot),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setState(() => _timeSlots.remove(slot));
                  },
                  backgroundColor:
                      const Color(0xFF1A56DB).withValues(alpha: 0.1),
                  labelStyle: const TextStyle(
                    color: Color(0xFF1A56DB),
                    fontWeight: FontWeight.w600,
                  ),
                  deleteIconColor: const Color(0xFF1A56DB),
                  side: BorderSide(
                      color: const Color(0xFF1A56DB).withValues(alpha: 0.3)),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _addTimeSlot() {
    final slot = _timeSlotInput.text.trim();
    if (slot.isNotEmpty && !_timeSlots.contains(slot)) {
      setState(() {
        _timeSlots.add(slot);
        _timeSlotInput.clear();
      });
    }
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('select_at_least_one_day'.tr()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_timeSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('add_at_least_one_slot'.tr()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final doctor = Doctor(
      id: widget.doctor?.id ?? '',
      name: _nameController.text.trim(),
      specialization: _specializationController.text.trim(),
      yearsOfExperience: int.tryParse(_experienceController.text) ?? 0,
      bio: _bioController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      whatsappNumber: _whatsappController.text.trim(),
      email: _emailController.text.trim(),
      clinicAddress: _addressController.text.trim(),
      availableDays: List.from(_selectedDays),
      availableTimeSlots: List.from(_timeSlots),
      consultationPrice:
          double.tryParse(_priceController.text) ?? 0,
      rating: widget.doctor?.rating ?? 0,
      totalRatings: widget.doctor?.totalRatings ?? 0,
      adhdCasesHandled: widget.doctor?.adhdCasesHandled ?? 0,
      profileImageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
      isActive: widget.doctor?.isActive ?? true,
      createdAt: widget.doctor?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (_isEditing) {
      context.read<DoctorCubit>().updateDoctor(doctor);
    } else {
      context.read<DoctorCubit>().addDoctor(doctor);
    }
  }
}
