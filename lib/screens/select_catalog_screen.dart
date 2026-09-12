import 'package:flutter/material.dart';

import '../data/tracked_category.dart';
import '../data/tracked_domain.dart';
import '../theme/app_theme.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/logo_image.dart';
import 'tracked_item_details_screen.dart';

class SelectCatalogScreen extends StatefulWidget {
  const SelectCatalogScreen({super.key, required this.domain});

  final TrackedDomain domain;

  @override
  State<SelectCatalogScreen> createState() => _SelectCatalogScreenState();
}

class _SelectCatalogScreenState extends State<SelectCatalogScreen> {
  String _query = '';
  TrackedCategory? _category;

  @override
  Widget build(BuildContext context) {
    final results = widget.domain.catalog
        .where((a) => a.name.toLowerCase().contains(_query.toLowerCase()))
        .where((a) => _category == null || a.category == _category)
        .toList();

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
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.textPrimary),
                  ),
                  Expanded(
                    child: Text(
                      widget.domain.addFromScratchTitle,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => setState(() => _query = v),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              CategoryFilterBar(
                categories: widget.domain.categories,
                selected: _category,
                onChanged: (c) => setState(() => _category = c),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: results.isEmpty
                    ? const Center(
                        child: Text(
                          'No results found',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: results.length,
                        itemBuilder: (context, i) {
                          final entry = results[i];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => TrackedItemDetailsScreen(
                                    domain: widget.domain,
                                    name: entry.name,
                                    logoAsset: entry.logoAsset,
                                    icon: entry.icon,
                                    iconColor: entry.iconColor,
                                    initialCategory: entry.category,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                LogoImage(
                                  assetPath: entry.logoAsset,
                                  icon: entry.icon,
                                  iconColor: entry.iconColor,
                                  size: 56,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  entry.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
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
