import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'di/injection.dart';
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'core/constants/strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await initializeDependencies();
  
  runApp(const NeuroLiftApp());
}

class NeuroLiftApp extends StatelessWidget {
  const NeuroLiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
      ),
      home: BlocProvider<DashboardCubit>(
        create: (context) => DashboardCubit(
          getDailyMetrics: getIt(),
          getRecentSessions: getIt(),
          firestore: FirebaseFirestore.instance,
        )..initDashboardStream(),
        child: const DashboardPage(),
      ),
    );
  }
}
