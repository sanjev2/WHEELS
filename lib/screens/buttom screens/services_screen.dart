import 'package:flutter/material.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Services'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildServiceCard(
              context: context,
              theme: theme,
              title: 'Basic Service',
              warranty: '1000 Kms or 1 Month Warranty',
              duration: 'Takes 4 hours',
              interval: 'Every 5000 Kms or 3 Months',
              price: 'Rs. 3219',
              imageUrl:
                  'https://media.istockphoto.com/id/467923700/photo/mechanic-using-tablet-on-car.jpg?s=612x612&w=0&k=20&c=6ySE_u8zJoNEEZ_wUOKwtZmyk9hnlCPBWnXSVy8qjiM=',
            ),
            const SizedBox(height: 20),
            _buildServiceCard(
              context: context,
              theme: theme,
              title: 'Comprehensive Service',
              warranty: '2000 Kms or 2 Month Warranty',
              duration: 'Takes 5 hours',
              interval: 'Every 10000 Kms or 6 Months',
              price: 'Rs. 5499',
              originalPrice: 'Rs. 5499',
              imageUrl:
                  'https://media.istockphoto.com/id/467923700/photo/mechanic-using-tablet-on-car.jpg?s=612x612&w=0&k=20&c=6ySE_u8zJoNEEZ_wUOKwtZmyk9hnlCPBWnXSVy8qjiM=',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required String warranty,
    required String duration,
    required String interval,
    required String price,
    String? promoText,
    String? originalPrice,
    String? discountedPrice,
    required String imageUrl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Image.network(
                  imageUrl,
                  width: 130,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 130,
                      height: 150,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.build,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              // Service Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildBulletPoint(warranty),
                      const SizedBox(height: 6),
                      _buildBulletPoint(duration),
                      const SizedBox(height: 6),
                      _buildBulletPoint(interval),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            price,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              _showOilSelectionBottomSheet(
                                context,
                                title,
                                price,
                              );
                            },
                            icon: const Icon(Icons.shopping_cart, size: 16),
                            label: const Text('Add to Cart'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: theme.colorScheme.primary,
                              side: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Promo text
          if (promoText != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                promoText,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          if (discountedPrice != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  if (originalPrice != null)
                    Text(
                      originalPrice,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      discountedPrice,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6, right: 8),
          child: Icon(Icons.circle, size: 6, color: Colors.black54),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  void _showOilSelectionBottomSheet(
    BuildContext context,
    String serviceTitle,
    String basePrice,
  ) {
    String selectedOil = 'Mobil 5W40';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              serviceTitle,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Select Engine oil',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 28),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // Oil Options List
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildOilOption(
                            context: context,
                            isSelected: selectedOil == 'Mobil 5W40',
                            title: 'Synthetic Oil',
                            subtitle: 'Mobil 5W40',
                            description:
                                'Exceptional Performance Boost & More Fuel Economy',
                            onTap: () {
                              setState(() {
                                selectedOil = 'Mobil 5W40';
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildOilOption(
                            context: context,
                            isSelected: selectedOil == 'Mobilii OW40',
                            title: 'Fully Synthetic',
                            subtitle: 'Mobilii OW40',
                            description:
                                'Best for Daily Commutes & Engine Protection',
                            onTap: () {
                              setState(() {
                                selectedOil = 'Mobilii OW40';
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildOilOption(
                            context: context,
                            isSelected: selectedOil == 'Mobilii OW30',
                            title: 'Hybrid',
                            subtitle: 'Mobilii OW30',
                            description:
                                'Ideal for Mixed Driving Conditions & Performance',
                            onTap: () {
                              setState(() {
                                selectedOil = 'Mobilii OW30';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              basePrice,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showAddonsSelectionBottomSheet(
                              context,
                              serviceTitle,
                              basePrice,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddonsSelectionBottomSheet(
    BuildContext context,
    String serviceTitle,
    String basePrice,
  ) {
    Set<String> selectedAddons = {};
    int basePriceValue = int.parse(basePrice.replaceAll(RegExp(r'[^0-9]'), ''));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Calculate total with selected addons
            int addonTotal = 0;
            if (selectedAddons.contains('Wheel Alignment')) addonTotal += 500;
            if (selectedAddons.contains('Tyre Rotation')) addonTotal += 500;
            if (selectedAddons.contains('Engine Tuning')) addonTotal += 1500;
            int totalPrice = basePriceValue + addonTotal;

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, size: 28),
                              onPressed: () {
                                Navigator.pop(context);
                                _showOilSelectionBottomSheet(
                                  context,
                                  serviceTitle,
                                  basePrice,
                                );
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Available Addons',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Boost up your package',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 28),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // Addons Options List
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildAddonOption(
                            context: context,
                            isSelected: selectedAddons.contains(
                              'Wheel Alignment',
                            ),
                            title: 'Wheel Alignment',
                            price: 'Rs. 500',
                            description:
                                'Upgrade your service with optional add-ons',
                            onTap: () {
                              setState(() {
                                if (selectedAddons.contains(
                                  'Wheel Alignment',
                                )) {
                                  selectedAddons.remove('Wheel Alignment');
                                } else {
                                  selectedAddons.add('Wheel Alignment');
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildAddonOption(
                            context: context,
                            isSelected: selectedAddons.contains(
                              'Tyre Rotation',
                            ),
                            title: 'Tyre Rotation',
                            price: 'Rs. 500',
                            description:
                                'Upgrade your service with optional add-ons',
                            onTap: () {
                              setState(() {
                                if (selectedAddons.contains('Tyre Rotation')) {
                                  selectedAddons.remove('Tyre Rotation');
                                } else {
                                  selectedAddons.add('Tyre Rotation');
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildAddonOption(
                            context: context,
                            isSelected: selectedAddons.contains(
                              'Engine Tuning',
                            ),
                            title: 'Engine Tuning',
                            price: 'Rs. 1500',
                            description:
                                'Upgrade your service with optional add-ons',
                            onTap: () {
                              setState(() {
                                if (selectedAddons.contains('Engine Tuning')) {
                                  selectedAddons.remove('Engine Tuning');
                                } else {
                                  selectedAddons.add('Engine Tuning');
                                }
                              });
                            },
                          ),

                          const SizedBox(height: 12),
                          _buildAddonOption(
                            context: context,
                            isSelected: selectedAddons.contains('EGR Cleaning'),
                            title: 'EGR Cleaning',
                            price: 'Rs. 1000',
                            description:
                                'Upgrade your service with optional add-ons',
                            onTap: () {
                              setState(() {
                                if (selectedAddons.contains('EGR Cleaning')) {
                                  selectedAddons.remove('EGR Cleaning');
                                } else {
                                  selectedAddons.add('EGR Cleaning');
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildAddonOption(
                            context: context,
                            isSelected: selectedAddons.contains(
                              'Interior Cleaning',
                            ),
                            title: 'Interior Cleaning',
                            price: 'Rs. 1000',
                            description:
                                'Upgrade your service with optional add-ons',
                            onTap: () {
                              setState(() {
                                if (selectedAddons.contains(
                                  'Interior Cleaning',
                                )) {
                                  selectedAddons.remove('Interior Cleaning');
                                } else {
                                  selectedAddons.add('Interior Cleaning');
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              'Rs. $totalPrice',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showGarageSelectionBottomSheet(
                              context,
                              serviceTitle,
                              totalPrice,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showGarageSelectionBottomSheet(
    BuildContext context,
    String serviceTitle,
    int totalPrice,
  ) {
    String? selectedGarage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, size: 28),
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Select Providers',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Select one of the garages below for your service',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 28),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // Garage Options List
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildGarageOption(
                            context: context,
                            isSelected: selectedGarage == 'John Doe\'s Garage',
                            name: 'John Doe\'s Garage',
                            location: 'Kalanki, Kathmandu',
                            distance: '15 KM',
                            rating: '4.9',
                            imageUrl:
                                'https://media.istockphoto.com/id/467923700/photo/mechanic-using-tablet-on-car.jpg?s=612x612&w=0&k=20&c=6ySE_u8zJoNEEZ_wUOKwtZmyk9hnlCPBWnXSVy8qjiM=',
                            onTap: () {
                              setState(() {
                                selectedGarage = 'John Doe\'s Garage';
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildGarageOption(
                            context: context,
                            isSelected: selectedGarage == 'Emily\'s Workshop',
                            name: 'Emily\'s Workshop',
                            location: 'Thamel, Kathmandu',
                            distance: '8 KM',
                            rating: '4.5',
                            imageUrl:
                                'https://media.istockphoto.com/id/467923700/photo/mechanic-using-tablet-on-car.jpg?s=612x612&w=0&k=20&c=6ySE_u8zJoNEEZ_wUOKwtZmyk9hnlCPBWnXSVy8qjiM=',
                            onTap: () {
                              setState(() {
                                selectedGarage = 'Emily\'s Workshop';
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildGarageOption(
                            context: context,
                            isSelected:
                                selectedGarage == 'Michael\'s Auto Repair',
                            name: 'Michael\'s Auto Repair',
                            location: 'Pulchowk, Lalitpur',
                            distance: '12 KM',
                            rating: '4.7',
                            imageUrl:
                                'https://media.istockphoto.com/id/467923700/photo/mechanic-using-tablet-on-car.jpg?s=612x612&w=0&k=20&c=6ySE_u8zJoNEEZ_wUOKwtZmyk9hnlCPBWnXSVy8qjiM=',
                            onTap: () {
                              setState(() {
                                selectedGarage = 'Michael\'s Auto Repair';
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildGarageOption(
                            context: context,
                            isSelected: selectedGarage == 'Sarah\'s Car Care',
                            name: 'Sarah\'s Car Care',
                            location: 'Baluwatar, Kathmandu',
                            distance: '10 KM',
                            rating: '',
                            isNew: true,
                            imageUrl:
                                'https://media.istockphoto.com/id/467923700/photo/mechanic-using-tablet-on-car.jpg?s=612x612&w=0&k=20&c=6ySE_u8zJoNEEZ_wUOKwtZmyk9hnlCPBWnXSVy8qjiM=',
                            onTap: () {
                              setState(() {
                                selectedGarage = 'Sarah\'s Car Care';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              'Rs. $totalPrice',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: selectedGarage != null
                              ? () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Proceeding to payment for $selectedGarage - Rs. $totalPrice',
                                      ),
                                      backgroundColor: const Color(0xFF4CAF50),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Make Payment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOilOption({
    required BuildContext context,
    required bool isSelected,
    required String title,
    required String subtitle,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4CAF50)
                      : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddonOption({
    required BuildContext context,
    required bool isSelected,
    required String title,
    required String price,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4CAF50)
                      : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGarageOption({
    required BuildContext context,
    required bool isSelected,
    required String name,
    required String location,
    required String distance,
    required String rating,
    required String imageUrl,
    required VoidCallback onTap,
    bool isNew = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.garage,
                      size: 35,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.navigation, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        distance,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 12),
                      if (rating.isNotEmpty) ...[
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                      if (isNew) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'New',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4CAF50)
                      : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
