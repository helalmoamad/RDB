/*import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trydos/common/constant/design/assets_provider.dart';
import 'package:trydos/common/test_utils/widgets_keys.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/service/language_service.dart';

class AvailableCountriesList extends StatefulWidget {
  final bool fromHomepage;
  const AvailableCountriesList({super.key, required this.fromHomepage});

  @override
  State<AvailableCountriesList> createState() => _AvailableCountriesListState();
}

class _AvailableCountriesListState extends State<AvailableCountriesList> {
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  late HomeBloc _homeBloc;
  int? _selectedIndex;

  @override
  void initState() {
    _homeBloc = BlocProvider.of<HomeBloc>(context);
    // اختر أول دولة افتراضياً إن توفرت
    final countries =
        _homeBloc.state.getAllowedCountriesModel?.data?.countries ?? [];
    if (countries.isNotEmpty) {
      _selectedIndex = 0;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final countries =
        _homeBloc.state.getAllowedCountriesModel?.data?.countries ?? [];

    if (countries.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: 1.sw,
      height: 245,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        itemBuilder: (context, index) {
          final country = countries[index];
          final isSelected = _selectedIndex == index;
          final code = (country.iso ?? '').toUpperCase();
          final name = country.name ?? '';

          return InkWell(
            key: Key('${WidgetsKeys.countryItemKeyKey}-$index'),
            onTap: () async {
              final chosenIso = (country.iso ?? '').toLowerCase();
              _prefsRepository.setUserChoosedCountryIso(chosenIso);
              setState(() => _selectedIndex = index);
              if (widget.fromHomepage) {
                _prefsRepository.setUserCountryIsAvailable(1);
                BlocProvider.of<HomeBloc>(
                  context,
                ).add(const ClearAllAppCashEvent());
                _prefsRepository.removeBoutiqueHasPerfechedWhenOpenApp(true);
                _prefsRepository.removeMainCategoryHasPerfechedWhenOpenApp(
                  true,
                );
                _prefsRepository.removeFiveFilterHasPerfechedWhenOpenApp();
                BlocProvider.of<HomeBloc>(context).add(
                  ChangeCountryLanguageForNotificationEvent(
                    country: chosenIso,
                    languageCode: LanguageService.languageCode,
                  ),
                );
                Future.delayed(const Duration(microseconds: 500), () {
                  context.go("/");
                });
              }
            },
            child: Container(
              height: 53,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xffF8F8F8) : Colors.white,
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xff402CDD)
                      : const Color(0xffD3D3D3),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                children: [
                  SizedBox(width: 10.w),
                  SizedBox(
                    width: 25,
                    height: 25,
                    child: code.toUpperCase() == "SY"
                        ? SvgPicture.asset(AppAssets.syriaFlagSvg)
                        : CountryFlag.fromCountryCode(
                            (code.isEmpty ? 'US' : code).toUpperCase(),
                            height: 25,
                            width: 25,
                            borderRadius: 4.r,
                          ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff1D1D1D),
                        letterSpacing: 0.18,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 5),
        itemCount: countries.length,
      ),
    );
  }
}
*/
