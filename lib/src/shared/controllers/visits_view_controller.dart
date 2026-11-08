import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'visits_view_controller.g.dart';

/// Whether the Visits tab shows past visits instead of upcoming ones.
///
/// Shared so a flow that ends in Visits, such as booking, can open it on
/// the upcoming list where the new visit is.
@Riverpod(keepAlive: true)
class VisitsShowPast extends _$VisitsShowPast {
  @override
  bool build() => false;

  void show({required bool past}) => state = past;
}
