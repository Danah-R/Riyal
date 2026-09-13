import 'package:flutter/material.dart';
import '../widgets/coin_back_button.dart';

import '../data/tracked_domain.dart';
import '../theme/app_theme.dart';
import '../widgets/logo_image.dart';
import 'tracked_item_details_screen.dart';

class SelectChargeScreen extends StatelessWidget {
  const SelectChargeScreen({super.key, required this.domain});

  final TrackedDomain domain;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CoinBackButton(),
                  const Expanded(
                    child: Text(
                      'Recent transactions',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.only(left: 12, bottom: 12),
                child: Text(
                  'Tap a charge to turn it into a tracked item',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: domain.mockCharges.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final charge = domain.mockCharges[i];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => TrackedItemDetailsScreen(
                              domain: domain,
                              name: charge.matchedName ?? charge.merchant,
                              logoAsset: charge.matchedLogo,
                              icon: charge.matchedIcon,
                              iconColor: charge.matchedIconColor,
                              initialAmount: charge.amount,
                              initialCategory: charge.matchedCategory,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            LogoImage(
                              assetPath: charge.matchedLogo,
                              icon: charge.matchedIcon,
                              iconColor: charge.matchedIconColor,
                              size: 44,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    charge.matchedName ?? charge.merchant,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${charge.merchant} · ${charge.daysAgo}d ago',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'SAR ${charge.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
