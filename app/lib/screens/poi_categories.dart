import 'package:candle/icons/compass.dart';
import 'package:candle/icons/poi_favorite.dart';
import 'package:candle/models/location_address.dart';
import 'package:candle/screens/compass.dart';
import 'package:candle/screens/poi_category.dart';
import 'package:candle/screens/screens.dart';
import 'package:candle/services/geocoding.dart';
import 'package:candle/services/location.dart';
import 'package:candle/utils/dialogs.dart';
import 'package:candle/widgets/appbar.dart';
import 'package:candle/widgets/tile_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class PoiCategory {
  final IconData icon;
  final String title;
  final List<String> categories;

  PoiCategory({required this.icon, required this.title, required this.categories});
}

class PoiCategoriesScreen extends StatefulWidget {
  const PoiCategoriesScreen({super.key});

  @override
  State<PoiCategoriesScreen> createState() => _ScreenState();
}

class _ScreenState extends State<PoiCategoriesScreen> {
  List<PoiCategory> categories = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    categories = [
      PoiCategory(
        icon: Icons.local_drink,
        title: l10n.poi_category_bars,
        categories: ['bar'],
      ),
      PoiCategory(
        icon: Icons.local_atm,
        title: l10n.poi_category_atms,
        categories: ['atm'],
      ),
      PoiCategory(
        icon: Icons.restaurant,
        title: l10n.poi_category_restaurants,
        categories: ['restaurant'],
      ),
      PoiCategory(
        icon: Icons.local_hospital,
        title: l10n.poi_category_hospitals,
        categories: ['hospital'],
      ),
      PoiCategory(
        icon: Icons.local_cafe,
        title: l10n.poi_category_cafes,
        categories: ['cafe'],
      ),
      PoiCategory(
        icon: Icons.directions_bus,
        title: l10n.poi_category_bus_stations,
        categories: ['bus_station', 'station'],
      ),
      PoiCategory(
        icon: Icons.local_taxi,
        title: l10n.poi_category_taxis,
        categories: ['taxi'],
      ),
      PoiCategory(
        icon: Icons.local_pharmacy,
        title: l10n.poi_category_pharmacies,
        categories: ['pharmacy'],
      ),
      PoiCategory(
        icon: Icons.hearing,
        title: l10n.poi_category_audible_signals,
        categories: ['traffic_signals'],
      ),
      PoiCategory(
        icon: Icons.wc,
        title: l10n.poi_category_public_toilets,
        categories: ['toilet'],
      ),
      // Add more categories if needed
    ];
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    ThemeData theme = Theme.of(context);

    return Scaffold(
        appBar: CandleAppBar(
          title: Text(AppLocalizations.of(context)!.explore_mainmenu),
          talkback: AppLocalizations.of(context)!.explore_mainmenu_t,
        ),
        body: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2, // Two columns
                    childAspectRatio: 0.95, // Aspect ratio of 1.0 (width == height)
                    crossAxisSpacing: 20, // Spacing in between items horizontally
                    mainAxisSpacing: 20, // Spacing in between items vertically
                    children: categories.map((category) {
                      return TileButton(
                        title: category.title,
                        talkback: '${category.title} button',
                        icon: Icon(
                          category.icon,
                          size: 50,
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (context) => PoiCategoryScreen(
                                    category: category,
                                  ),
                                ),
                              )
                              .then((value) => setState(() {}));
                        },
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}