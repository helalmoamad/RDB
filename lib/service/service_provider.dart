import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos_wallet/trydos_wallet.dart';

class ServiceProvider extends StatelessWidget {
  final Widget child;
  const ServiceProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => GetIt.I<AuthBloc>()),
        BlocProvider(create: (BuildContext context) => WalletBloc()),
      ],
      child: child,
    );
  }
}
