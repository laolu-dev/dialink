import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'package:dialink/src/app/router/routes.dart';
import 'package:dialink/src/app/theme/app_palette.dart';
import 'package:dialink/src/core/network/result.dart';
import 'package:dialink/src/core/utils/extensions.dart';
import 'package:dialink/src/core/utils/time.dart';
import 'package:dialink/src/data/doctors/doctor_repository.dart';
import 'package:dialink/src/data/doctors/models/provider_model.dart';
import 'package:dialink/src/shared/controllers/appointments_controller.dart';
import 'package:dialink/src/shared/controllers/session_controller.dart';
import 'package:dialink/src/shared/utils/keyboard.dart';
import 'package:dialink/src/shared/utils/toasts.dart';
import 'package:dialink/src/shared/widgets/app_surface.dart';
import 'package:dialink/src/shared/widgets/app_text_field.dart';
import 'package:dialink/src/shared/widgets/buttons.dart';
import 'package:dialink/src/shared/widgets/headers.dart';
import 'package:dialink/src/shared/widgets/initials_avatar.dart';
import 'package:dialink/src/shared/widgets/message_state.dart';
import 'package:dialink/src/shared/widgets/notice_banner.dart';
import 'package:dialink/src/shared/widgets/skeleton.dart';
import 'package:go_router/go_router.dart';

/// Picks a free slot with a provider, a week at a time, in the provider's
/// zone. On wide screens it sits beside the doctor list.
class SlotPicker extends ConsumerStatefulWidget {
  const SlotPicker({super.key, required this.args});

  final DoctorTimesArgs args;

  @override
  ConsumerState<SlotPicker> createState() => _SlotPickerState();
}

class _SlotPickerState extends ConsumerState<SlotPicker> {
  /// Bookings can be made up to 90 days ahead.
  static const _maxDaysAhead = 90;

  final TextEditingController reason = TextEditingController();

  late final DateTime _today = AppTime.todayIn(widget.args.provider.timeZone);
  late DateTime _weekStart = _today;
  DateTime? _day;
  SlotModel? _selected;

  ProviderModel get _provider => widget.args.provider;
  bool get _isReschedule => widget.args.reschedule != null;

  AvailabilityProvider get _slotsProvider => availabilityProvider(
    providerId: _provider.id,
    timeZone: _provider.timeZone,
    from: _weekStart,
  );

  @override
  void dispose() {
    reason.dispose();
    closeKeyboard();
    super.dispose();
  }

  void _moveWeek(int weeks) {
    setState(() {
      _weekStart = _weekStart.add(Duration(days: 7 * weeks));
      _day = null;
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final user = ref.watch(sessionProvider).value;
    final canBook = user?.emailVerified ?? false;
    final busy = ref.watch(appointmentControllerProvider).isLoading;
    final slots = ref.watch(_slotsProvider);

    final weekEnd = _weekStart.add(const Duration(days: 6));
    final canGoBack = _weekStart.isAfter(_today);
    final canGoForward = weekEnd.difference(_today).inDays < _maxDaysAhead - 1;

    // Fetch the next week while this one is read, so swiping on is instant.
    if (canGoForward && slots.hasValue) {
      ref.listen(
        availabilityProvider(
          providerId: _provider.id,
          timeZone: _provider.timeZone,
          from: _weekStart.add(const Duration(days: 7)),
        ),
        (_, _) {},
      );
    }

    final byDay = {
      for (final day in slots.value ?? const <SlotDay>[]) day.date: day.slots,
    };
    final day = byDay.containsKey(_day)
        ? _day
        : (byDay.keys.isEmpty ? null : byDay.keys.first);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            children: [
              Row(
                spacing: 12,
                children: [
                  InitialsAvatar(name: _provider.name, size: 52),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _provider.name,
                          style: context.textTheme.titleLarge,
                        ),
                        Text(
                          "${_provider.specialty} · times in ${_provider.timeZone}",
                          style: context.textTheme.bodyMedium!.copyWith(
                            color: p.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_isReschedule) ...[
                12.0.verticalSpacing,
                Text(
                  "Now: ${AppTime.dateTime(widget.args.reschedule!.startTime, _provider.timeZone)}",
                  style: context.textTheme.bodyMedium,
                ),
              ],
              if (!canBook && !_isReschedule) ...[
                16.0.verticalSpacing,
                NoticeBanner(
                  icon: Iconsax.sms_notification,
                  title: "Confirm your email to book",
                  message: "You can look at times in the meantime.",
                  onTap: () => context.push(Routes.verifyEmail),
                ),
              ],
              16.0.verticalSpacing,
              Text(
                "${DateFormat('d MMM').format(_weekStart)} – ${DateFormat('d MMM').format(weekEnd)}",
                style: context.textTheme.titleMedium,
              ),
              Text(
                "Swipe the days for other weeks",
                style: context.textTheme.bodySmall,
              ),
              10.0.verticalSpacing,
              // Swiping changes the week, in easy reach of the thumb; screen
              // readers get the same through custom actions.
              Semantics(
                customSemanticsActions: {
                  if (canGoBack)
                    const CustomSemanticsAction(label: "Previous week"): () =>
                        _moveWeek(-1),
                  if (canGoForward)
                    const CustomSemanticsAction(label: "Next week"): () =>
                        _moveWeek(1),
                },
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    final velocity = details.primaryVelocity ?? 0;
                    if (velocity < -200 && canGoForward) _moveWeek(1);
                    if (velocity > 200 && canGoBack) _moveWeek(-1);
                  },
                  child: Row(
                    spacing: 6,
                    children: [
                      for (var i = 0; i < 7; i++)
                        Expanded(
                          child: _DayTile(
                            date: _weekStart.add(Duration(days: i)),
                            selected: _weekStart.add(Duration(days: i)) == day,
                            available: byDay.containsKey(
                              _weekStart.add(Duration(days: i)),
                            ),
                            onTap: () => setState(() {
                              _day = _weekStart.add(Duration(days: i));
                              _selected = null;
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              20.0.verticalSpacing,
              switch (slots) {
                AsyncError(:final error) => MessageState.error(
                  error,
                  onRetry: () => ref.invalidate(_slotsProvider),
                ),
                AsyncData() when day == null => MessageState(
                  icon: Iconsax.calendar_remove,
                  title: "No free times this week",
                  message: canGoForward ? "Try the next week." : null,
                  actionLabel: canGoForward ? "Next week" : null,
                  onAction: () => _moveWeek(1),
                ),
                AsyncData() => _buildTimes(context, byDay[day]!),
                _ => const _TimesSkeleton(),
              },
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: PrimaryButton(
            loading: busy,
            label: switch (_selected) {
              null => "Pick a time",
              final slot =>
                "${_isReschedule ? "Move to" : "Book"} ${DateFormat('EEE d MMM, HH:mm').format(AppTime.inZone(slot.startTime, _provider.timeZone))}",
            },
            onPressed: _selected != null && (canBook || _isReschedule)
                ? _review
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTimes(BuildContext context, List<SlotModel> slots) {
    final groups = <String, List<SlotModel>>{};
    for (final slot in slots) {
      final hour = AppTime.inZone(slot.startTime, _provider.timeZone).hour;
      final group = hour < 12
          ? "Morning"
          : hour < 17
          ? "Afternoon"
          : "Evening";
      groups.putIfAbsent(group, () => []).add(slot);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 420 ? 4 : 3;
        final width = (constraints.maxWidth - 8 * (columns - 1)) / columns;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final MapEntry(key: label, value: times)
                in groups.entries) ...[
              SectionLabel(label),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final slot in times)
                    SizedBox(
                      width: width,
                      child: _TimeTile(
                        label: AppTime.time(slot.startTime, _provider.timeZone),
                        selected: _selected?.startTime == slot.startTime,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selected = slot);
                        },
                      ),
                    ),
                ],
              ),
              16.0.verticalSpacing,
            ],
          ],
        );
      },
    );
  }

  /// Shows what will be booked, with the optional reason, before booking.
  Future<void> _review() async {
    final slot = _selected!;
    final when = AppTime.dateTime(slot.startTime, _provider.timeZone);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheet) => _ReviewSheet(
        title: _isReschedule ? "Move your visit?" : "Book this visit?",
        doctor: "${_provider.name} · ${_provider.specialty}",
        when: when,
        before: _isReschedule
            ? AppTime.dateTime(
                widget.args.reschedule!.startTime,
                _provider.timeZone,
              )
            : null,
        reason: _isReschedule ? null : reason,
        confirmLabel: _isReschedule ? "Move visit" : "Confirm booking",
        onConfirm: () async {
          final booked = await _submit();
          if (booked && sheet.mounted) Navigator.of(sheet).pop();
        },
      ),
    );
  }

  /// Returns whether it was booked or moved.
  Future<bool> _submit() async {
    closeKeyboard();
    final notifier = ref.read(appointmentControllerProvider.notifier);
    final slot = _selected!;
    final slotsProvider = _slotsProvider;

    final result = _isReschedule
        ? await notifier.rescheduleAppointment(
            appointment: widget.args.reschedule!,
            provider: _provider,
            slot: slot,
          )
        : await notifier.createAppointment(
            provider: _provider,
            slot: slot,
            reason: reason.text.trim(),
          );

    switch (result) {
      case Success(:final value):
        Toasts.success(value);
        if (!mounted) return true;
        context.go(Routes.visits);
        return true;
      case Failure(:final value):
        Toasts.error(value.message);
        if (!mounted) return false;
        switch (value.type) {
          case 'slot-unavailable' ||
              'outside-schedule' ||
              'too-soon' ||
              'start-in-past':
            setState(() => _selected = null);
            ref.invalidate(slotsProvider);
          case 'email-not-verified':
            ref.read(sessionProvider.notifier).reload();
            context.push(Routes.verifyEmail);
        }
        return false;
    }
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.date,
    required this.selected,
    required this.available,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final bool available;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = selected ? p.onPrimary : (available ? p.text : p.muted);

    return Semantics(
      button: true,
      selected: selected,
      enabled: available,
      label:
          "${DateFormat('EEEE d MMMM').format(date)}${available ? "" : ", no free times"}",
      excludeSemantics: true,
      child: Opacity(
        opacity: available || selected ? 1 : .45,
        child: AppSurface(
          radius: 14,
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: selected ? p.primary : null,
          borderColor: selected ? p.primary : null,
          onTap: available ? onTap : null,
          child: Column(
            children: [
              Text(
                DateFormat('EEE').format(date),
                maxLines: 1,
                style: context.textTheme.labelSmall!.copyWith(color: fg),
              ),
              Text(
                "${date.day}",
                style: context.textTheme.titleMedium!.copyWith(color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
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
      child: AppSurface(
        radius: 14,
        padding: const EdgeInsets.symmetric(vertical: 13),
        color: selected ? p.primary : null,
        borderColor: selected ? p.primary : null,
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4,
          children: [
            if (selected)
              Icon(Iconsax.tick_circle, size: 16, color: p.onPrimary),
            Text(
              label,
              style: context.textTheme.titleSmall!.copyWith(
                color: selected ? p.onPrimary : p.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewSheet extends ConsumerWidget {
  const _ReviewSheet({
    required this.title,
    required this.doctor,
    required this.when,
    required this.confirmLabel,
    required this.onConfirm,
    this.before,
    this.reason,
  });

  final String title;
  final String doctor;
  final String when;

  /// The current time, when moving a visit.
  final String? before;

  /// Asked for when booking, not when moving.
  final TextEditingController? reason;
  final String confirmLabel;
  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final busy = ref.watch(appointmentControllerProvider).isLoading;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        12 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: context.textTheme.titleLarge),
            ),
            16.0.verticalSpacing,
            _SheetDetail(icon: Iconsax.user, text: doctor),
            if (before != null)
              _SheetDetail(icon: Iconsax.calendar_remove, text: "From $before"),
            _SheetDetail(
              icon: Iconsax.calendar_tick,
              text: before != null ? "To $when" : when,
              strong: true,
            ),
            if (reason != null) ...[
              12.0.verticalSpacing,
              AppTextField(
                label: "Reason for visit (optional)",
                hint: "What you'd like to see the doctor about",
                controller: reason!,
                maxLines: 3,
                maxLength: 1000,
              ),
            ] else
              16.0.verticalSpacing,
            Text(
              "The doctor confirms the time. You can cancel any time before.",
              style: context.textTheme.bodySmall!.copyWith(color: p.muted),
            ),
            16.0.verticalSpacing,
            PrimaryButton(
              label: confirmLabel,
              loading: busy,
              onPressed: onConfirm,
            ),
            TextButton(
              onPressed: busy ? null : () => Navigator.of(context).pop(),
              child: const Text("Go back"),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetDetail extends StatelessWidget {
  const _SheetDetail({
    required this.icon,
    required this.text,
    this.strong = false,
  });

  final IconData icon;
  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        spacing: 10,
        children: [
          Icon(icon, size: 20, color: context.palette.primary),
          Expanded(
            child: Text(
              text,
              style: strong
                  ? context.textTheme.titleMedium
                  : context.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

/// The shape of the times grid while it loads.
class _TimesSkeleton extends StatelessWidget {
  const _TimesSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 420 ? 4 : 3;
        final width = (constraints.maxWidth - 8 * (columns - 1)) / columns;
        Widget tiles(int count) => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < count; i++)
              SkeletonBox(width: width, height: 46, radius: 14),
          ],
        );

        return Shimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              const SkeletonBox(width: 80),
              tiles(columns),
              4.0.verticalSpacing,
              const SkeletonBox(width: 96),
              tiles(columns * 2),
            ],
          ),
        );
      },
    );
  }
}
