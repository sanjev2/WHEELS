import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/color.dart';
import '../../domain/entities/car_entity.dart';
import '../providers/car_provider.dart';

class EditCarPage extends ConsumerStatefulWidget {
  const EditCarPage({super.key, required this.car});

  final CarEntity car;

  @override
  ConsumerState<EditCarPage> createState() => _EditCarPageState();
}

class _EditCarPageState extends ConsumerState<EditCarPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _makeC;
  late final TextEditingController _modelC;
  late final TextEditingController _yearC;
  late final TextEditingController _categoryC;
  late final TextEditingController _fuelC;
  late final TextEditingController _plateC;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.car;

    _makeC = TextEditingController(text: c.make);
    _modelC = TextEditingController(text: c.model);
    _yearC = TextEditingController(text: c.year.toString());
    _categoryC = TextEditingController(text: c.category);
    _fuelC = TextEditingController(text: c.fuelType);
    _plateC = TextEditingController(text: c.licensePlate);
  }

  @override
  void dispose() {
    _makeC.dispose();
    _modelC.dispose();
    _yearC.dispose();
    _categoryC.dispose();
    _fuelC.dispose();
    _plateC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final id = widget.car.id?.trim() ?? "";
    if (id.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Car ID missing")));
      return;
    }

    final year = int.tryParse(_yearC.text.trim()) ?? 0;
    if (year == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Year is invalid")));
      return;
    }

    final updated = CarEntity(
      id: id,
      make: _makeC.text.trim(),
      model: _modelC.text.trim(),
      year: year,
      category: _categoryC.text.trim(),
      fuelType: _fuelC.text.trim(),
      licensePlate: _plateC.text.trim().toUpperCase(),
      boughtDate: widget.car.boughtDate,
    );

    setState(() => _saving = true);

    try {
      final ok = await ref
          .read(carViewModelProvider.notifier)
          .updateCar(id, updated);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? "Vehicle updated" : "Update failed")),
      );

      if (ok) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Edit Vehicle",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          children: [
            _SectionCard(
              title: "Vehicle Details",
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _CleanTextField(
                      controller: _makeC,
                      label: "Make",
                      hint: "Toyota, Honda...",
                      validator: (v) =>
                          (v ?? "").trim().isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 12),
                    _CleanTextField(
                      controller: _modelC,
                      label: "Model",
                      hint: "Corolla, City...",
                      validator: (v) =>
                          (v ?? "").trim().isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 12),
                    _CleanTextField(
                      controller: _yearC,
                      label: "Year",
                      hint: "2020",
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final s = (v ?? "").trim();
                        if (s.isEmpty) return "Required";
                        final y = int.tryParse(s);
                        if (y == null || y < 1950 || y > 2100)
                          return "Invalid year";
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _CleanTextField(
                      controller: _categoryC,
                      label: "Category",
                      hint: "SUV, Sedan...",
                      validator: (v) =>
                          (v ?? "").trim().isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 12),
                    _CleanTextField(
                      controller: _fuelC,
                      label: "Fuel Type",
                      hint: "Petrol, Diesel, EV...",
                      validator: (v) =>
                          (v ?? "").trim().isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 12),
                    _CleanTextField(
                      controller: _plateC,
                      label: "License Plate",
                      hint: "BA 1 PA 1234",
                      validator: (v) =>
                          (v ?? "").trim().isEmpty ? "Required" : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        "Save Changes",
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- UI parts (matching your theme) ----

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _CleanTextField extends StatelessWidget {
  const _CleanTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSubtle,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.primaryGreen.withOpacity(0.45),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
