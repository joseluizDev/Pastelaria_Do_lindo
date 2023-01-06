import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  static final Database instance = Database();
  static late FirebaseFirestore db;

  static init() async {
    db = FirebaseFirestore.instance;
    db.settings = const Settings(persistenceEnabled: true);
    db.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}
