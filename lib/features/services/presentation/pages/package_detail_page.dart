import 'package:flutter/material.dart';
import 'package:wheels_flutter/app/theme/color.dart';
import 'package:wheels_flutter/features/services/domain/entities/package_entity.dart';

class PackageDetailPage extends StatelessWidget {
  final PackageEntity package;

  const PackageDetailPage({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(package.title),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F7F7),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (package.description != null &&
                    package.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    package.description!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  "₹ ${package.price}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (package.durationMins != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    "Duration: ${package.durationMins} mins",
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _card(
            title: "Engine Oil Types",
            child: Text(
              package.engineOilTypes.isEmpty
                  ? "—"
                  : package.engineOilTypes.join(", "),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          _card(
            title: "Included Services",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: package.services.isEmpty
                  ? [const Text("—")]
                  : package.services
                        .map(
                          (s) => Text(
                            "• $s",
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        )
                        .toList(),
            ),
          ),
          const SizedBox(height: 12),
          _card(
            title: "Add-ons",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: package.addons.isEmpty
                  ? [const Text("—")]
                  : package.addons
                        .map(
                          (a) => Text(
                            "• $a",
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        )
                        .toList(),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Next: Booking screen will open here"),
                  ),
                );
              },
              child: const Text(
                "Book Now",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({String? title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight.withOpacity(0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
          ],
          child,
        ],
      ),
    );
  }
}
