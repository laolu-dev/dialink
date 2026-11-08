import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/app/router/routes.dart';
import 'package:dialink/src/app/theme/app_palette.dart';
import 'package:dialink/src/core/utils/extensions.dart';
import 'package:dialink/src/data/doctors/doctor_repository.dart';
import 'package:dialink/src/data/doctors/models/provider_model.dart';
import 'package:dialink/src/features/booking/widgets/slot_picker.dart';
import 'package:dialink/src/shared/utils/keyboard.dart';
import 'package:dialink/src/shared/widgets/app_surface.dart';
import 'package:dialink/src/shared/widgets/buttons.dart';
import 'package:dialink/src/shared/widgets/headers.dart';
import 'package:dialink/src/shared/widgets/initials_avatar.dart';
import 'package:dialink/src/shared/widgets/message_state.dart';
import 'package:dialink/src/shared/widgets/skeleton.dart';
import 'package:go_router/go_router.dart';

/// The Find tab. On wide screens the chosen doctor's times show beside the
/// list; on phones they open on their own screen.
class FindDoctorScreen extends ConsumerStatefulWidget {
  const FindDoctorScreen({super.key});

  @override
  ConsumerState<FindDoctorScreen> createState() => _FindDoctorScreenState();
}

class _FindDoctorScreenState extends ConsumerState<FindDoctorScreen> {
  /// Content this wide has room for the times beside the list.
  static const _twoPaneWidth = 560.0;

  final TextEditingController search = TextEditingController();
  Timer? _debounce;

  String _name = '';
  String? _specialty;
  ProviderModel? _chosen;

  @override
  void dispose() {
    _debounce?.cancel();
    search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() => _name = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final twoPane = constraints.maxWidth >= _twoPaneWidth;
          final list = _buildList(context, twoPane: twoPane);
          if (!twoPane) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: list,
              ),
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 5, child: list),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 16, 12),
                  child: AppSurface(
                    radius: 28,
                    padding: const EdgeInsets.only(top: 12),
                    child: switch (_chosen) {
                      null => const MessageState(
                        icon: Iconsax.calendar_1,
                        title: "Pick a doctor",
                        message: "Their free times will show here.",
                      ),
                      final provider => SlotPicker(
                        key: ValueKey(provider.id),
                        args: DoctorTimesArgs(provider: provider),
                      ),
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, {required bool twoPane}) {
    final p = context.palette;
    final providers = ref.watch(
      searchProvidersProvider(name: _name, specialty: _specialty),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenHeader(title: "Find a doctor"),
          16.0.verticalSpacing,
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: TextField(
                  controller: search,
                  onChanged: _onSearchChanged,
                  textInputAction: TextInputAction.search,
                  onTapOutside: (_) => closeKeyboard(),
                  style: context.textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: "Search by name",
                    prefixIcon: Icon(Iconsax.search_normal_1, size: 20),
                  ),
                ),
              ),
              _FilterButton(active: _specialty != null, onTap: _openFilters),
            ],
          ),
          12.0.verticalSpacing,
          _SpecialtyChips(
            selected: _specialty,
            onSelected: (specialty) => setState(() => _specialty = specialty),
          ),
          12.0.verticalSpacing,
          Expanded(
            child: providers.when(
              skipLoadingOnReload: false,
              data: (page) {
                final providers = page.items;
                if (providers.isEmpty) {
                  // Typed a specialty into the name search: offer it.
                  final suggestion = _specialty == null
                      ? _matchingSpecialty(_name)
                      : null;
                  if (suggestion != null) {
                    return MessageState(
                      icon: Iconsax.search_status,
                      title: "No doctors named \"$_name\"",
                      message: "Looking for a specialty instead?",
                      actionLabel: "Show $suggestion doctors",
                      onAction: () => setState(() {
                        search.clear();
                        _name = '';
                        _specialty = suggestion;
                      }),
                    );
                  }
                  return MessageState(
                    icon: Iconsax.search_status,
                    title: "No doctors match",
                    message: _specialty == null
                        ? "Try another name, or pick a specialty above."
                        : "Try another name, or show all specialties.",
                    actionLabel: _specialty == null ? null : "Show all",
                    onAction: () => setState(() => _specialty = null),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: providers.length + (page.hasMore ? 1 : 0),
                  separatorBuilder: (context, index) => 10.0.verticalSpacing,
                  itemBuilder: (context, index) {
                    if (index == providers.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          "Showing the first ${providers.length}. "
                          "Search by name or filter by specialty to narrow it down.",
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodySmall,
                        ),
                      );
                    }
                    final provider = providers[index];
                    return AppSurface(
                      padding: const EdgeInsets.all(14),
                      selected: twoPane && _chosen?.id == provider.id,
                      onTap: () => twoPane
                          ? setState(() => _chosen = provider)
                          : context.push(
                              Routes.doctor(provider.id),
                              extra: DoctorTimesArgs(provider: provider),
                            ),
                      child: Row(
                        spacing: 12,
                        children: [
                          InitialsAvatar(name: provider.name),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.name,
                                  style: context.textTheme.titleMedium,
                                ),
                                Text(
                                  [
                                    provider.specialty,
                                    if (provider.yearsExperience != null)
                                      "${provider.yearsExperience} years' experience",
                                  ].join(" · "),
                                  style: context.textTheme.bodyMedium!.copyWith(
                                    color: p.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Iconsax.arrow_right_3, color: p.muted),
                        ],
                      ),
                    );
                  },
                );
              },
              error: (error, st) => MessageState.error(
                error,
                onRetry: () => ref.invalidate(searchProvidersProvider),
              ),
              loading: () => const SkeletonList(),
            ),
          ),
        ],
      ),
    );
  }

  /// The first specialty containing [query], ignoring case, once the
  /// specialties have loaded; null for short or unmatched queries.
  String? _matchingSpecialty(String query) {
    if (query.length < 3) return null;
    final needle = query.toLowerCase();
    final specialties = ref.read(specialtiesProvider).value ?? const [];
    for (final specialty in specialties) {
      if (specialty.toLowerCase().contains(needle)) return specialty;
    }
    return null;
  }

  Future<void> _openFilters() async {
    closeKeyboard();
    // A sheet, in reach of the thumb, as both platforms expect for filters.
    final choice = await showModalBottomSheet<_Filters>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => _FilterSheet(specialty: _specialty),
    );
    if (choice != null) setState(() => _specialty = choice.specialty);
  }
}

/// What the filter sheet returns; a null specialty means any.
typedef _Filters = ({String? specialty});

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: active ? "Filters, 1 on" : "Filters",
      child: ExcludeSemantics(
        child: Badge(
          isLabelVisible: active,
          backgroundColor: p.accent,
          smallSize: 10,
          child: AppSurface(
            radius: 14,
            padding: const EdgeInsets.all(15),
            color: active ? p.tint : null,
            borderColor: active ? p.primary : null,
            onTap: onTap,
            child: Icon(Iconsax.setting_4, size: 22, color: p.primary),
          ),
        ),
      ),
    );
  }
}

/// Specialties as one-tap filters under the search, so patients who know
/// what kind of doctor they need don't have to open the filter sheet.
class _SpecialtyChips extends ConsumerStatefulWidget {
  const _SpecialtyChips({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  ConsumerState<_SpecialtyChips> createState() => _SpecialtyChipsState();
}

class _SpecialtyChipsState extends ConsumerState<_SpecialtyChips> {
  final _scroll = ScrollController();

  @override
  void didUpdateWidget(_SpecialtyChips old) {
    super.didUpdateWidget(old);
    // The chosen chip moves to the front; bring the front back into view.
    if (old.selected != widget.selected && _scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : Durations.medium2,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final onSelected = widget.onSelected;
    final specialties = ref.watch(specialtiesProvider);
    return switch (specialties) {
      AsyncData(:final value) => SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 8,
          children: [
            _Chip(
              label: "All",
              selected: selected == null,
              onTap: () => onSelected(null),
            ),
            // The chosen one comes first, so it's always in view.
            for (final specialty in [
              ?selected,
              ...value.where((s) => s != selected),
            ])
              _Chip(
                label: specialty,
                selected: specialty == selected,
                onTap: () =>
                    onSelected(specialty == selected ? null : specialty),
              ),
          ],
        ),
      ),
      // The filter sheet still offers them, with its own retry.
      AsyncError() => const SizedBox.shrink(),
      _ => const Shimmer(
        child: Row(
          spacing: 8,
          children: [
            SkeletonBox(width: 56, height: 48, radius: 99),
            SkeletonBox(width: 120, height: 48, radius: 99),
            SkeletonBox(width: 104, height: 48, radius: 99),
          ],
        ),
      ),
    };
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      label: label == "All" ? "All specialties" : label,
      excludeSemantics: true,
      child: ConstrainedBox(
        // 48 dp, the larger of the two platforms' minimum targets.
        constraints: const BoxConstraints(minHeight: 48),
        child: AppSurface(
          radius: 99,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: selected ? p.primary : null,
          borderColor: selected ? p.primary : null,
          onTap: onTap,
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: context.textTheme.labelLarge!.copyWith(
                color: selected ? p.onPrimary : p.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet({required this.specialty});

  final String? specialty;

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late String? _specialty = widget.specialty;

  @override
  Widget build(BuildContext context) {
    final specialties = ref.watch(specialtiesProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text("Filter doctors", style: context.textTheme.titleLarge),
          ),
          16.0.verticalSpacing,
          const SectionLabel("Specialty"),
          Flexible(
            child: switch (specialties) {
              AsyncData(:final value) => RadioGroup<String>(
                groupValue: _specialty ?? '',
                onChanged: (value) => setState(
                  () => _specialty = value == null || value.isEmpty
                      ? null
                      : value,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final specialty in ['', ...value])
                      RadioListTile<String>(
                        value: specialty,
                        title: Text(specialty.isEmpty ? "Any" : specialty),
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
              AsyncError(:final error) => MessageState.error(
                error,
                onRetry: () => ref.invalidate(specialtiesProvider),
              ),
              _ => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Shimmer(
                  child: Column(
                    spacing: 18,
                    children: [
                      SkeletonBox(height: 18),
                      SkeletonBox(height: 18),
                      SkeletonBox(height: 18),
                    ],
                  ),
                ),
              ),
            },
          ),
          12.0.verticalSpacing,
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: SecondaryButton(
                  label: "Clear",
                  onPressed: () => Navigator.pop(context, (specialty: null)),
                ),
              ),
              Expanded(
                child: PrimaryButton(
                  label: "Show doctors",
                  onPressed: () =>
                      Navigator.pop(context, (specialty: _specialty)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
