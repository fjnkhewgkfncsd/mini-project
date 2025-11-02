import 'dart:io';
import 'dependency_setup.dart';
import 'data_seeder.dart';
import 'menus/main_menu.dart';

void runHospitalApp() {
  print('=== 🏥 HOSPITAL MANAGEMENT SYSTEM ===');
  
  // Setup everything
  final dependencies = setupDependencies();
  seedSampleData(dependencies);
  
  // Start main menu
  MainMenu(dependencies: dependencies).show();
}