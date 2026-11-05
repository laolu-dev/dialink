import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import 'package:dialink/src/app/router/app_router.dart';
import 'package:dialink/src/app/router/routes.dart';
import 'package:dialink/src/app/theme/app_palette.dart';
import 'package:dialink/src/core/utils/extensions.dart';
import 'package:dialink/src/data/doctors/doctor_repository.dart';
import 'package:dialink/src/data/doctors/models/provider_model.dart';
import 'package:dialink/src/features/booking/views/doctor_times_screen.dart';
import 'package:dialink/src/features/booking/widgets/slot_picker.dart';
import 'package:dialink/src/shared/utils/keyboard.dart';
import 'package:dialink/src/shared/widgets/app_surface.dart';
import 'package:dialink/src/shared/widgets/headers.dart';
import 'package:dialink/src/shared/widgets/initials_avatar.dart';
import 'package:dialink/src/shared/widgets/message_state.dart';
import 'package:dialink/src/shared/widgets/skeleton.dart';

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
          if (_specialty case final specialty?) ...[
            10.0.verticalSpacing,
            Align(
              alignment: Alignment.centerLeft,
              child: _ActiveFilter(
                label: specialty,
                onClear: () => setState(() => _specialty = null),
              ),
            ),
          ],
          12.0.verticalSpacing,
          Expanded(
            child: providers.when(
              skipLoadingOnReload: false,
              data: (page) {
                final providers = page.items;
                if (providers.isEmpty) {
                  return MessageState(
                    icon: Iconsax.search_status,
                    title: "No doctors match",
                    message: _specialty == null
                        ? "Try another name."
                        : "Try another name or specialty.",
                    actionLabel: _specialty == null ? null : "Clear filter",
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
                          : context.router.pushNamed(
                              RouteName.providerSlots,
                              arguments: DoctorTimesArgs(provider: provider),
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

  Future<void> _openFilters() async {
    closeKeyboard();
    final choice = await showDialog<_Filters>(
      context: context,
      builder: (context) => _FilterDialog(specialty: _specialty),
    );
    if (choice != null) setState(() => _specialty = choice.specialty);
  }
}

/// What the filter dialog returns; a null specialty means any.
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

/// The filter that is on, with a way to clear it without opening the dialog.
class _ActiveFilter extends StatelessWidget {
  const _ActiveFilter({required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: "$label filter. Clear",
      child: ExcludeSemantics(
        child: AppSurface(
          radius: 99,
          padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
          color: p.tint,
          borderColor: p.primary,
          onTap: onClear,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Text(
                label,
                style: context.textTheme.labelLarge!.copyWith(color: p.primary),
              ),
              Icon(Iconsax.close_circle, size: 18, color: p.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterDialog extends ConsumerStatefulWidget {
  const _FilterDialog({required this.specialty});

  final String? specialty;

  @override
  ConsumerState<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends ConsumerState<_FilterDialog> {
  late String? _specialty = widget.specialty;

  @override
  Widget build(BuildContext context) {
    final specialties = ref.watch(specialtiesProvider);

    return AlertDialog(
      title: const Text("Filter doctors"),
      contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SectionLabel("Specialty"),
            ),
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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                        ),
                    ],
                  ),
                ),
                AsyncError(:final error) => MessageState.error(
                  error,
                  onRetry: () => ref.invalidate(specialtiesProvider),
                ),
                _ => const Padding(
                  padding: EdgeInsets.all(12),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, (specialty: null)),
          child: const Text("Clear"),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, (specialty: _specialty)),
          child: const Text("Show doctors"),
        ),
      ],
    );
  }
}
