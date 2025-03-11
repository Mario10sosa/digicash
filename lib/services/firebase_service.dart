import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:digicash/firebase_options.dart';

/*class FirebaseService {
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase inicializado correctamente');
    } catch (e) {
      debugPrint('Error al inicializar Firebase: $e');
      rethrow;
    }
  }
}*/

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getloand() async {
  List loand = [];
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await db.collection('loand').get().then((QuerySnapshot querySnapshotloand) {
      querySnapshotloand.docs.forEach((doc) {
        loand.add(doc.data());
      });
    });
    return loand;
  } catch (e) {
    debugPrint('Error al obtener los datos: $e');
    rethrow;
  }
}
