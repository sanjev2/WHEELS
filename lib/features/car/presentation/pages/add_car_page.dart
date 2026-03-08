import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheels_flutter/features/car/presentation/providers/car_provider.dart';
import 'package:wheels_flutter/features/car/presentation/state/car_state.dart';
import '../../../../app/theme/color.dart';
import '../../domain/entities/car_entity.dart';

class AddCarPage extends ConsumerStatefulWidget {
  const AddCarPage({super.key});

  @override
  ConsumerState<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends ConsumerState<AddCarPage> {
  final _formKey = GlobalKey<FormState>();

  final _make = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _plate = TextEditingController();

  String _fuelType = "Petrol";
  String _category = "SUV";
  DateTime _boughtDate = DateTime.now();

  final fuelTypes = const ["Petrol", "Diesel", "Electric", "Hybrid", "CNG"];
  final categories = const ["SUV", "SEDAN", "HATCHBACK"];

  @override
  void dispose() {
    _make.dispose();
    _model.dispose();
    _year.dispose();
    _plate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(carViewModelProvider);
    final isLoading = state.status == CarStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Vehicle"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _textField(_make, "Make (e.g. Toyota)"),
                const SizedBox(height: 12),
                _textField(_model, "Model (e.g. Corolla)"),
                const SizedBox(height: 12),
                _textField(
                  _year,
                  "Year (e.g. 2020)",
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _textField(_plate, "License Plate (e.g. BA-12-PA-1234)"),
                const SizedBox(height: 12),

                _dropdown(
                  "Category",
                  _category,
                  categories,
                  (v) => setState(() => _category = v),
                ),
                const SizedBox(height: 12),
                _dropdown(
                  "Fuel Type",
                  _fuelType,
                  fuelTypes,
                  (v) => setState(() => _fuelType = v),
                ),
                const SizedBox(height: 12),

                _datePicker(context),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isLoading ? null : _save,
                    child: Text(
                      isLoading ? "Saving..." : "Save Vehicle",
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController c,
    String hint, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surfaceGreen,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    void Function(String v) onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: value,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => onChanged(v ?? value),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceGreen,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _datePicker(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 90,
          child: Text("Bought", style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime(1990),
                lastDate: DateTime.now(),
                initialDate: _boughtDate,
              );
              if (picked != null) setState(() => _boughtDate = picked);
            },
            child: Text(
              "${_boughtDate.year}-${_boughtDate.month}-${_boughtDate.day}",
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final year = int.tryParse(_year.text.trim()) ?? 0;
    if (year < 1900) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter a valid year")));
      return;
    }

    final entity = CarEntity(
      make: _make.text.trim(),
      model: _model.text.trim(),
      year: year,
      licensePlate: _plate.text.trim().toUpperCase(),
      fuelType: _fuelType,
      boughtDate: _boughtDate,
      category: _category,
    );

    final ok = await ref.read(carViewModelProvider.notifier).addCar(entity);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? "Vehicle added" : "Failed to add vehicle")),
    );

    if (ok) Navigator.pop(context, true);
  }
}
