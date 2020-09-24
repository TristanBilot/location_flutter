import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../stores/repository.dart';
import '../models/user.dart';
import '../stores/store.dart';

class UserRepository {
  final _geo = Geoflutterfire();
  final _firestore = FirebaseFirestore.instance;
  final _repo = Repository();

  /*
  ^ FUNCTION
  * Insert a new user in the firestore if it does not exists
  * Change the values if the user already exists.
  * Insert the last_name, first_name and position with the key 'email'
  * of the user, the picture is sent to the storage
  */
  Future<void> insertOrUpdateUser(User user) async {
    // final locationData = await LocationController.getLocation();
    // GeoFirePoint geoPoint = _geo.point(latitude: locationData.latitude, longitude: locationData.longitude);
    final GeoFirePoint geoPoint = Store.parisGeoPosition;
    await _firestore.collection('locations').doc(user.email).set({
      'last_name': user.lastName,
      'first_name': user.firstName,
      'position': geoPoint.data, // should be replaced in prod
    });
    File userPicture = await _repo.urlToFile(user.pictureURL);
    return await _repo.uploadFile(
        userPicture, user.email + Store.defaultProfilePictureExtension);
  }

  /*
  ^ PRIVATE FUNCTION
  * This method is only for testing purpose, to insert mock data to the firestore db 
  */
  Future<void> _putLocationToFireStore() async {
    // final locationData = await LocationController.getLocation();
    // GeoFirePoint geoPoint = _geo.point(latitude: locationData.latitude, longitude: locationData.longitude);
    GeoFirePoint paris13 = _geo.point(latitude: 48.825194, longitude: 2.347420);
    GeoFirePoint paris13_2 =
        _geo.point(latitude: 48.824710, longitude: 2.348482);

    _firestore.collection('locations').doc('camille@hotmail.fr').set({
      'email': 'kendall@hotmail.fr',
      'firstName': 'Kendall',
      'lastName': 'Jenner',
      'position': paris13.data
    });
    _firestore.collection('locations').doc('bilot.tristan@hotmail.fr').set({
      'email': 'camille@hotmail.fr',
      'firstName': 'Camille',
      'lastName': 'Houly',
      'position': paris13_2.data
    });
  }
}
