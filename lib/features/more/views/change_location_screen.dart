import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosques_app/core/constants/app_colors.dart';
import 'package:mosques_app/core/data/cities_data.dart';
import 'package:mosques_app/features/onboarding/viewmodels/onboarding_cubit.dart';
import 'package:mosques_app/features/onboarding/viewmodels/onboarding_state.dart';

class ChangeLocationScreen extends StatelessWidget {
  const ChangeLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit()..initFromCache(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingDone) {
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        context.locale;
        final cubit = context.read<OnboardingCubit>();

        final CountryModel? country = switch (state) {
          OnboardingCountryPicked(:final country) => country,
          OnboardingCityPicked(:final country) => country,
          _ => null,
        };
        final CityModel? city =
            state is OnboardingCityPicked ? state.city : null;
        final isSaving = state is OnboardingSaving;

        return Scaffold(
          backgroundColor: AppColor.surfaceDim,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColor.onSurface,
                size: 20.sp,
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            title: Text(
              'change_location'.tr(),
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                color: AppColor.onSurface,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 32.h),

                  Text(
                    'change_location_subtitle'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      color: AppColor.textSecondary,
                      fontSize: 14.sp,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // ── Country selector ────────────────────────────────────────
                  _SelectorTile(
                    icon: Icons.public_rounded,
                    placeholder: 'select_country'.tr(),
                    value: country?.name,
                    valueAr: country?.nameAr,
                    enabled: !isSaving,
                    onTap: () async {
                      final picked = await _showSearchSheet<CountryModel>(
                        context: context,
                        title: 'select_country'.tr(),
                        hint: 'search_country'.tr(),
                        items: kCountries,
                        labelOf: (c) => c.name,
                        labelArOf: (c) => c.nameAr,
                      );
                      if (picked != null && context.mounted) {
                        cubit.pickCountry(picked);
                      }
                    },
                  ),
                  SizedBox(height: 12.h),

                  // ── City selector ────────────────────────────────────────────
                  _SelectorTile(
                    icon: Icons.location_city_rounded,
                    placeholder: 'select_city'.tr(),
                    value: city?.name,
                    valueAr: city?.nameAr,
                    enabled: country != null && !isSaving,
                    onTap: country == null
                        ? null
                        : () async {
                            final picked = await _showSearchSheet<CityModel>(
                              context: context,
                              title: 'select_city'.tr(),
                              hint: 'search_city'.tr(),
                              items: country.cities,
                              labelOf: (c) => c.name,
                              labelArOf: (c) => c.nameAr,
                            );
                            if (picked != null && context.mounted) {
                              cubit.pickCity(picked);
                            }
                          },
                  ),

                  const Spacer(),

                  // ── GPS note ────────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.gps_fixed_rounded,
                        color: AppColor.textSecondary,
                        size: 14.sp,
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          'onboarding_gps_note'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColor.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // ── Save button ─────────────────────────────────────────────
                  ElevatedButton(
                    onPressed: city != null && !isSaving
                        ? () => cubit.confirm()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor1,
                      disabledBackgroundColor: AppColor.surfaceContainerHigh,
                      foregroundColor: AppColor.onPrimary,
                      disabledForegroundColor: AppColor.textSecondary,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    child: isSaving
                        ? SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColor.onPrimary,
                            ),
                          )
                        : Text(
                            'save_location'.tr(),
                            style: TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<T?> _showSearchSheet<T>({
    required BuildContext context,
    required String title,
    required String hint,
    required List<T> items,
    required String Function(T) labelOf,
    required String Function(T) labelArOf,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchSheet<T>(
        title: title,
        hint: hint,
        items: items,
        labelOf: labelOf,
        labelArOf: labelArOf,
      ),
    );
  }
}

class _SelectorTile extends StatelessWidget {
  final IconData icon;
  final String placeholder;
  final String? value;
  final String? valueAr;
  final bool enabled;
  final VoidCallback? onTap;

  const _SelectorTile({
    required this.icon,
    required this.placeholder,
    required this.enabled,
    this.value,
    this.valueAr,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocaleAr = context.locale.languageCode == 'ar';
    final displayValue = isLocaleAr ? (valueAr ?? value) : value;
    final hasValue = value != null;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColor.surfaceContainer,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: hasValue
                  ? AppColor.primaryColor1.withValues(alpha: 0.5)
                  : AppColor.outlineVariant,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: hasValue ? AppColor.primaryColor1 : AppColor.textSecondary,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  displayValue ?? placeholder,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    color: hasValue ? AppColor.onSurface : AppColor.textSecondary,
                    fontSize: 15.sp,
                    fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColor.textSecondary,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchSheet<T> extends StatefulWidget {
  final String title;
  final String hint;
  final List<T> items;
  final String Function(T) labelOf;
  final String Function(T) labelArOf;

  const _SearchSheet({
    required this.title,
    required this.hint,
    required this.items,
    required this.labelOf,
    required this.labelArOf,
  });

  @override
  State<_SearchSheet<T>> createState() => _SearchSheetState<T>();
}

class _SearchSheetState<T> extends State<_SearchSheet<T>> {
  late List<T> _filtered;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQuery(String q) {
    final query = q.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? widget.items
          : widget.items.where((item) {
              return widget.labelOf(item).toLowerCase().contains(query) ||
                  widget.labelArOf(item).contains(query);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColor.surfaceContainer,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColor.outlineVariant,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    color: AppColor.onSurface,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: TextField(
                  controller: _controller,
                  onChanged: _onQuery,
                  autofocus: true,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    color: AppColor.onSurface,
                    fontSize: 15.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                      color: AppColor.textSecondary,
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColor.textSecondary,
                      size: 20.sp,
                    ),
                    filled: true,
                    fillColor: AppColor.surfaceContainerHigh,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) {
                    final item = _filtered[i];
                    final isAr = context.locale.languageCode == 'ar';
                    return ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
                      title: Text(
                        isAr ? widget.labelArOf(item) : widget.labelOf(item),
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          color: AppColor.onSurface,
                          fontSize: 15.sp,
                        ),
                      ),
                      subtitle: isAr
                          ? null
                          : Text(
                              widget.labelArOf(item),
                              style: TextStyle(
                                color: AppColor.textSecondary,
                                fontSize: 12.sp,
                              ),
                            ),
                      onTap: () => Navigator.of(context).pop(item),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
