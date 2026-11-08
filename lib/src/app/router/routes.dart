import 'package:dialink/src/data/appointments/models/appointment_model.dart';
import 'package:dialink/src/data/doctors/models/provider_model.dart';

/// Every screen's location. Screens navigate with these and go_router, e.g.
/// `context.push(Routes.verifyEmail)`.
abstract final class Routes {
  /// Restoring a saved session, or showing why it couldn't be.
  static const splash = '/splash';

  // Signed out.
  static const welcome = '/welcome';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';

  /// Open signed in too, from changing a password.
  static const forgotPassword = '/forgot-password';

  // The tabs.
  static const home = '/home';
  static const find = '/find';
  static const visits = '/visits';
  static const account = '/account';

  // Signed in, over the tabs.
  static const verifyEmail = '/verify-email';
  static const details = '/account/details';
  static const appearance = '/account/appearance';
  static const changePassword = '/account/change-password';

  /// A doctor's free times. Pass `DoctorTimesArgs` as `extra` when the
  /// doctor is already loaded, or to reschedule.
  static String doctor(String id) => '/doctors/$id';

  /// After a booking or move is sent. Takes `BookedArgs` as `extra`.
  static const booked = '/booked';
}

/// What [Routes.doctor] takes as `extra`.
class DoctorTimesArgs {
  const DoctorTimesArgs({required this.provider, this.reschedule});

  final ProviderModel provider;

  /// When set, picking a slot moves this appointment instead of booking.
  final AppointmentModel? reschedule;
}

/// What [Routes.booked] takes as `extra`: the request that was just sent.
class BookedArgs {
  const BookedArgs({
    required this.provider,
    required this.when,
    this.reason,
    this.moved = false,
  });

  final ProviderModel provider;

  /// The requested time, already formatted in the doctor's zone.
  final String when;

  /// The patient's note, if they wrote one.
  final String? reason;

  /// A visit was moved rather than booked.
  final bool moved;
}
