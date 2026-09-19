import 'package:dialink/src/config/router/route_names.dart';
import 'package:dialink/src/core/core.dart';
import 'package:dialink/src/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Column(
        children: [
          Center(
            child: Text(
              "Dialink",
              style: context.textTheme.displayLarge!.copyWith(
                fontFamily: AppConstants.instance.cooperBtFont,
              ),
            ),
          ),
          24.0.verticalSpacing,
          Text(
            "Book appointments with a doctor",
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge!.copyWith(),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => context.router.pushNamed(RouteName.signup),
                child: Text("Create account"),
              ),
              TextButton.icon(
                onPressed: () => context.router.pushNamed(RouteName.login),
                label: Text("Login"),
                iconAlignment: IconAlignment.end,
                icon: Icon(Iconsax.login, color: AppColors.white),
              ),
            ],
          ),
          32.0.verticalSpacing,
        ],
      ),
    );
  }
}
