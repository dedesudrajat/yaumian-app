import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yaumian_app/models/amalan.dart';
import 'package:yaumian_app/models/kategori.dart';
import 'package:yaumian_app/models/achievement.dart';
import 'package:yaumian_app/models/statistics_data.dart';
import 'package:yaumian_app/models/group.dart';

class FirebaseService {
  // Firebase instances
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Collections references
  static final CollectionReference _amalanCollection = _firestore.collection(
    'amalans',
  );
  static final CollectionReference _kategoriCollection = _firestore.collection(
    'kategoris',
  );
  static final CollectionReference _achievementCollection = _firestore
      .collection('achievements');
  static final CollectionReference _userStatsCollection = _firestore.collection(
    'userStats',
  );
  static final CollectionReference _groupCollection = _firestore.collection(
    'groups',
  );

  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  // Authentication methods
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  static Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print('Error signing in anonymously: $e');
      return null;
    }
  }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User canceled the sign-in flow
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final userCredential = await _auth.signInWithCredential(credential);

      // Simpan data profil dari Google ke Firestore
      if (userCredential.user != null) {
        final user = userCredential.user!;
        await _firestore.collection('users').doc(user.uid).set({
          'displayName': user.displayName,
          'email': user.email,
          'photoURL': user.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
          'provider': 'google',
        }, SetOptions(merge: true));
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  static Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in with email and password: $e');
      return null;
    }
  }

  static Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error creating user with email and password: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // User profile methods
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);

        // Simpan data profil ke Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'displayName': displayName ?? user.displayName,
          'email': user.email,
          'photoURL': photoURL ?? user.photoURL,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  // Amalan methods
  static Future<void> addAmalan(Amalan amalan) async {
    try {
      await _amalanCollection.add(amalan.toMap());
    } catch (e) {
      print('Error adding amalan: $e');
    }
  }

  static Future<void> updateAmalan(String id, Amalan amalan) async {
    try {
      await _amalanCollection.doc(id).update(amalan.toMap());
    } catch (e) {
      print('Error updating amalan: $e');
    }
  }

  static Future<void> deleteAmalan(String id) async {
    try {
      await _amalanCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting amalan: $e');
    }
  }

  static Stream<QuerySnapshot> getAmalans() {
    return _amalanCollection.snapshots();
  }

  // Kategori methods
  static Future<void> addKategori(Kategori kategori) async {
    try {
      await _kategoriCollection.add(kategori.toMap());
    } catch (e) {
      print('Error adding kategori: $e');
    }
  }

  static Future<void> updateKategori(String id, Kategori kategori) async {
    try {
      await _kategoriCollection.doc(id).update(kategori.toMap());
    } catch (e) {
      print('Error updating kategori: $e');
    }
  }

  static Future<void> deleteKategori(String id) async {
    try {
      await _kategoriCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting kategori: $e');
    }
  }

  static Stream<QuerySnapshot> getKategoris() {
    return _kategoriCollection.snapshots();
  }

  // Achievement methods
  static Future<void> addAchievement(Achievement achievement) async {
    try {
      await _achievementCollection.add(achievement.toMap());
    } catch (e) {
      print('Error adding achievement: $e');
    }
  }

  static Future<void> updateAchievement(
    String id,
    Achievement achievement,
  ) async {
    try {
      await _achievementCollection.doc(id).update(achievement.toMap());
    } catch (e) {
      print('Error updating achievement: $e');
    }
  }

  static Future<void> deleteAchievement(String id) async {
    try {
      await _achievementCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting achievement: $e');
    }
  }

  static Stream<QuerySnapshot> getAchievements() {
    return _achievementCollection.snapshots();
  }

  // Statistics methods
  static Future<void> updateUserStats(StatisticsData stats) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _userStatsCollection.doc(user.uid).set(stats.toMap());
      }
    } catch (e) {
      print('Error updating user stats: $e');
    }
  }

  static Future<StatisticsData?> getUserStats() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _userStatsCollection.doc(user.uid).get();
        if (doc.exists) {
          return StatisticsData.fromMap(doc.data() as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      print('Error getting user stats: $e');
      return null;
    }
  }

  // Group methods
  static Future<void> createGroup(Group group) async {
    try {
      await _groupCollection.add(group.toMap());
    } catch (e) {
      print('Error creating group: $e');
    }
  }

  static Future<void> updateGroup(String id, Group group) async {
    try {
      await _groupCollection.doc(id).update(group.toMap());
    } catch (e) {
      print('Error updating group: $e');
    }
  }

  static Future<void> deleteGroup(String id) async {
    try {
      await _groupCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting group: $e');
    }
  }

  static Stream<QuerySnapshot> getGroups() {
    return _groupCollection.snapshots();
  }
}
