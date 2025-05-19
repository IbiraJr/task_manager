import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/features/task/task_injection_container.dart';
import 'package:task_manager/config/firebase_options.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  //Modules
  await initializeTaskInjectionContainer(sl);
}
