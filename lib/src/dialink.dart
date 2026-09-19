import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import 'config/config.dart';

class Dialink extends StatelessWidget {
  const Dialink({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        title: 'Dialink',
        theme: appTheme,
        navigatorKey: AppRouter.instance.routerKey,
        onGenerateRoute: (settings) => AppRouter.instance.routes(settings),
      ),
    );
  }
}
