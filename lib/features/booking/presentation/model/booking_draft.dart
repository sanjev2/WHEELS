class BookingDraft {
  final String carId;
  final String category;

  final String packageId;
  final String packageTitle;
  final int basePrice;
  final int? durationMins;

  final String? selectedOilType;
  final List<String> selectedAddons;

  final String? providerId;
  final String? providerName;

  const BookingDraft({
    required this.carId,
    required this.category,
    required this.packageId,
    required this.packageTitle,
    required this.basePrice,
    required this.durationMins,
    required this.selectedOilType,
    required this.selectedAddons,
    required this.providerId,
    required this.providerName,
  });

  int get totalPrice => basePrice;

  BookingDraft copyWith({
    String? selectedOilType,
    List<String>? selectedAddons,
    String? providerId,
    String? providerName,
  }) {
    return BookingDraft(
      carId: carId,
      category: category,
      packageId: packageId,
      packageTitle: packageTitle,
      basePrice: basePrice,
      durationMins: durationMins,
      selectedOilType: selectedOilType ?? this.selectedOilType,
      selectedAddons: selectedAddons ?? this.selectedAddons,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
    );
  }
}
