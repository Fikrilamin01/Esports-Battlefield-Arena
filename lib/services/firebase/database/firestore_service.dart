import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esports_battlefield_arena/services/firebase/database/database.dart';
import 'package:esports_battlefield_arena/services/firebase/firestore_config.dart';
import 'package:esports_battlefield_arena/services/firebase/firestore_utils.dart';
import 'package:esports_battlefield_arena/app/failures.dart';

class FirestoreService extends Database {
  final String addErrorMessage =
      'ERROR: There is an error occurred during add process';
  final String updateErrorMessage =
      'ERROR: There is an error occurred during update process';
  final String deleteErrorMessage =
      'ERROR: There is an error occurred during delete process';
  final String getErrorMessage =
      'ERROR: There is an error occurred during get process';
  final String getAllErrorMessage =
      'ERROR: There is an error occurred during getAll process';
  final String getByQueryErrorMessage =
      'ERROR: There is an error occurred during getByQuery process';
  final String getAllByQueryErrorMessage =
      'ERROR: There is an error occurred during getAllByQuery process';
  final String getAllByQueryListErrorMessage =
      'ERROR: There is an error occurred during getAllByQueryList process';
  final String getAllByQueryListMapErrorMessage =
      'ERROR: There is an error occurred during getAllByQueryListMap process';
  final _firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<String?> add(
      Map<String, dynamic> data, FirestoreCollections collection) async {
    try {
      //Get the collection name from the firestore configuration
      String collectionName = firestoreCollectionsName[collection]![
          FirestoreDeclration.collectionName]!;
      log('"DEBUG": collection name: $collectionName');

      //Check the data is the correct type based on the collection input by the user
      checkCollectionNameAndgetModelData(collection, data);
      log('"DEBUG": Data: $data');

      if (collection == FirestoreCollections.users ||
          collection == FirestoreCollections.player ||
          collection == FirestoreCollections.organizer) {
        log("DEBUG: userID: ${data['userId']}");
        await _firebaseFirestore
            .collection(collectionName)
            .doc(data['userId'])
            .set(data);
      } else {
        var userDocumentReference =
            await _firebaseFirestore.collection(collectionName).add(data);
        //since the id is auto generated by firebase,
        //we need to update the field of the newly
        //created document with the generated Id
        log("DEBUG: document Id: ${userDocumentReference.id}");
        _firebaseFirestore
            .collection(collectionName)
            .doc(userDocumentReference.id)
            .update({
          //The format of the code is like this:
          //Key : Value
          firestoreCollectionsName[collection]![FirestoreDeclration.id]!:
              userDocumentReference.id,
        });
        return userDocumentReference.id;
      }
    } on FirebaseException catch (e) {
      log(firestoreError(e.code).toString());
      throw firestoreError(e.code);
    } on ArgumentError catch (e) {
      Failure error = Failure("ARGUMENT_ERROR",
          message: "$addErrorMessage\nERROR MESSAGE: ${e.message}",
          location: "firestore_utils.dart");
      log(error.toString());
      throw error;
    } on Exception catch (e) {
      Failure error = Failure("UNKNOWN",
          message: "$addErrorMessage\nERROR MESSAGE: $e",
          location: "firestore_service.dart");
      log(error.toString());
      throw error;
    }
  }

  @override
  Future<void> delete(
      String documentId, FirestoreCollections collection) async {
    try {
      //Get the collection name from the firestore configuration
      String collectionName = firestoreCollectionsName[collection]![
          FirestoreDeclration.collectionName]!;
      log('"DEBUG": collection name: $collectionName');

      await _firebaseFirestore
          .collection(collectionName)
          .doc(documentId)
          .delete();
    } on FirebaseException catch (e) {
      log(firestoreError(e.code).toString());
      throw firestoreError(e.code);
    } on ArgumentError catch (e) {
      Failure error = Failure("ARGUMENT_ERROR",
          message: "$deleteErrorMessage\nERROR MESSAGE: ${e.message}",
          location: "firestore_utils.dart");
      log(error.toString());
      throw error;
    } on Exception catch (e) {
      Failure error = Failure("UNKNOWN",
          message: "$deleteErrorMessage\nERROR MESSAGE: $e",
          location: "firestore_service.dart");
      log(error.toString());
      throw error;
    }
  }

  @override
  Future<Map<String, dynamic>> get(
      String documentId, FirestoreCollections collection) async {
    try {
      //Get the collection name from the firestore configuration
      String collectionName = firestoreCollectionsName[collection]![
          FirestoreDeclration.collectionName]!;
      log('"DEBUG": collection name: $collectionName');

      var doc = await _firebaseFirestore
          .collection(collectionName)
          .doc(documentId)
          .get();

      if (!doc.exists) {
        throw Failure.notFound;
      }
      log('"DEBUG": Data: ${doc.data()}');

      return doc.data()!;
    } on FirebaseException catch (e) {
      log(firestoreError(e.code).toString());
      throw firestoreError(e.code);
    } on ArgumentError catch (e) {
      Failure error = Failure("ARGUMENT_ERROR",
          message: "$getErrorMessage\nERROR MESSAGE: ${e.message}",
          location: "firestore_utils.dart");
      log(error.toString());
      throw error;
    } on Exception catch (e) {
      Failure error = Failure("UNKNOWN",
          message: "$getErrorMessage\nERROR MESSAGE: $e",
          location: "firestore_service.dart");
      log(error.toString());
      throw error;
    }
  }

  @override
  Future<List<dynamic>> getAll(FirestoreCollections collection) async {
    try {
      //Get the collection name from the firestore configuration
      String collectionName = firestoreCollectionsName[collection]![
          FirestoreDeclration.collectionName]!;
      log('"DEBUG": collection name: $collectionName');

      List<dynamic> listData = [];
      QuerySnapshot querySnapshot =
          await _firebaseFirestore.collection(collectionName).get();
      for (var element in querySnapshot.docs) {
        listData.add(checkCollectionNameAndgetModelData(
            collection, element.data() as Map<String, dynamic>));
      }
      log('"DEBUG": Data: $listData');
      return listData;
    } on FirebaseException catch (e) {
      log(firestoreError(e.code).toString());
      throw firestoreError(e.code);
    } on ArgumentError catch (e) {
      Failure error = Failure("ARGUMENT_ERROR",
          message: "$getAllErrorMessage\nERROR MESSAGE: ${e.message}",
          location: "firestore_utils.dart");
      log(error.toString());
      throw error;
    } on Exception catch (e) {
      Failure error = Failure("UNKNOWN",
          message: "$getAllErrorMessage\nERROR MESSAGE: $e",
          location: "firestore_service.dart");
      log(error.toString());
      throw error;
    }
  }

  @override
  Future<void> update(String documentId, Map<String, dynamic> data,
      FirestoreCollections collection) async {
    try {
      //Get the collection name from the firestore configuration
      String collectionName = firestoreCollectionsName[collection]![
          FirestoreDeclration.collectionName]!;
      log('"DEBUG": collection name: $collectionName');

      //override the data with the correct type
      // checkCollectionNameAndgetModelData(collection, data);
      log('"DEBUG": Data: $data');

      await _firebaseFirestore
          .collection(collectionName)
          .doc(documentId)
          .update(data);
    } on FirebaseException catch (e) {
      log(firestoreError(e.code).toString());
      throw firestoreError(e.code);
    } on ArgumentError catch (e) {
      Failure error = Failure("ARGUMENT_ERROR",
          message: "$updateErrorMessage\nERROR MESSAGE: ${e.message}",
          location: "firestore_utils.dart");
      log(error.toString());
      throw error;
    } on Exception catch (e) {
      Failure error = Failure("UNKNOWN",
          message: "$updateErrorMessage\nERROR MESSAGE: $e",
          location: "firestore_service.dart");
      log(error.toString());
      throw error;
    }
  }

  @override
  Future<Map<String, dynamic>?> getByQuery(List<String> field,
      List<String> value, FirestoreCollections collection) async {
    try {
      //Get the collection name from the firestore configuration
      bool fieldValid = true;
      String collectionName = firestoreCollectionsName[collection]![
          FirestoreDeclration.collectionName]!;
      log('"DEBUG": collection name: $collectionName');
      Query collectionReference = _firebaseFirestore.collection(collectionName);

      for (int i = 0; i < field.length; i++) {
        fieldValid = checkCollectionNameAndgetFieldName(collection, field[i]);
        if (!fieldValid) {
          throw Failure("INVALID_FIELD",
              message:
                  "$getByQueryErrorMessage\nERROR MESSAGE: Invalid field name $field[i] in collection $collectionName",
              location: "firestore_service.dart");
        }
        collectionReference =
            collectionReference.where(field[i], isEqualTo: value[i]);
      }

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await collectionReference.get()
              as QuerySnapshot<Map<String, dynamic>>;
      if (querySnapshot.docs.isEmpty) {
        // throw Failure("NOT_FOUND",
        //     message:
        //         "$getByQueryErrorMessage\nERROR MESSAGE: document Not Found in collection $collectionName",
        //     location: "firestore_service.dart");
        return null;
      }
      return querySnapshot.docs.first.data();
      // .then((value) {
      //   if (value.docs.isEmpty) {
      //     throw Failure.notFound;
      //   }
      //   return value.docs.first.data() as Map<String, dynamic>;
      // });
    } on FirebaseException catch (e) {
      Failure error = Failure(e.code,
          message: "$getByQueryErrorMessage\nERROR MESSAGE: ${e.message}",
          location: "firestore_service.dart");
      log(firestoreError(e.code).toString());
      throw error;
    } on ArgumentError catch (e) {
      Failure error = Failure("ARGUMENT_ERROR",
          message: "$getErrorMessage\nERROR MESSAGE: ${e.message}",
          location: "firestore_utils.dart");
      log(error.toString());
      throw error;
    } on Exception catch (e) {
      Failure error = Failure("UNKNOWN",
          message: "$getErrorMessage\nERROR MESSAGE: $e",
          location: "firestore_service.dart");
      log(error.toString());
      throw error;
    } on Failure {
      rethrow;
    }
  }

  //This function is to find the list of document that has the same value in the field
  @override
  Future<List<Map<String, dynamic>>> getAllByQuery(List<String> field,
      List<dynamic> value, FirestoreCollections collection) async {
    try {
      bool fieldValid = true;
      //Get the collection name from the firestore configuration
      String collectionName = firestoreCollectionsName[collection]![
          FirestoreDeclration.collectionName]!;
      log('"DEBUG": collection name: $collectionName');

      Query collectionReference = _firebaseFirestore.collection(collectionName);

      //do the field checking based on the collection by call util function to verify the field
      //Throw error if the field is not valid
      for (int i = 0; i < field.length; i++) {
        fieldValid = checkCollectionNameAndgetFieldName(collection, field[i]);
        if (!fieldValid) {
          throw Failure("INVALID_FIELD",
              message:
                  "$getAllByQueryErrorMessage\nERROR MESSAGE: Invalid field name $field[i] in collection $collectionName",
              location: "firestore_service.dart");
        }
        collectionReference =
            collectionReference.where(field[i], isEqualTo: value[i]);
      }

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await collectionReference.get()
              as QuerySnapshot<Map<String, dynamic>>;
      // if (querySnapshot.docs.isEmpty) {
      //   throw Failure("NOT_FOUND",
      //       message:
      //           "$getAllByQueryErrorMessage\nERROR MESSAGE: document Not Found in collection $collectionName",
      //       location: "firestore_service.dart");
      // }
      return querySnapshot.docs.map((e) => e.data()).toList();
    } on FirebaseException catch (e) {
      log(firestoreError(e.code).toString());
      throw firestoreError(e.code);
    } on ArgumentError catch (e) {
      Failure error = Failure("ARGUMENT_ERROR",
          message: "$getAllByQueryErrorMessage\nERROR MESSAGE: ${e.message}",
          location: "firestore_utils.dart");
      log(error.toString());
      throw error;
    } on Exception catch (e) {
      Failure error = Failure("UNKNOWN",
          message: "$getAllByQueryErrorMessage\nERROR MESSAGE: $e",
          location: "firestore_service.dart");
      log(error.toString());
      throw error;
    } on Failure catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Stream<Map<String, dynamic>> streamByQuery(
      List<String> field, List<String> value, FirestoreCollections collection) {
    String collectionName = firestoreCollectionsName[collection]![
        FirestoreDeclration.collectionName]!;
    log('"DEBUG": collection name: $collectionName');
    var query = _firebaseFirestore.collection(collectionName);
    for (int i = 0; i < field.length; i++) {
      query.where(field[i], isEqualTo: value[i]);
    }
    return query.snapshots().map((event) => event.docs.first.data());
  }

  @override
  Future<List<Map<String, dynamic>>> getAllByQueryList(
      String field, String value, FirestoreCollections collection) async {
    try {
      bool fieldValid = true;
      //Get the collection name from the firestore configuration
      String collectionName = firestoreCollectionsName[collection]![
          FirestoreDeclration.collectionName]!;
      log('"DEBUG": collection name: $collectionName');

      Query collectionReference = _firebaseFirestore.collection(collectionName);

      //do the field checking based on the collection by call util function to verify the field
      //Throw error if the field is not valid
      fieldValid = checkCollectionNameAndgetFieldName(collection, field);
      if (!fieldValid) {
        throw Failure("INVALID_FIELD",
            message:
                "$getAllByQueryListErrorMessage\nERROR MESSAGE: Invalid field name $field in collection $collectionName",
            location: "firestore_service.dart");
      }

      collectionReference =
          collectionReference.where(field, arrayContains: value);

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await collectionReference.get()
              as QuerySnapshot<Map<String, dynamic>>;
      // if (querySnapshot.docs.isEmpty) {
      //   throw Failure("NOT_FOUND",
      //       message:
      //           "$getAllByQueryErrorMessage\nERROR MESSAGE: document Not Found in collection $collectionName",
      //       location: "firestore_service.dart");
      // }
      return querySnapshot.docs.map((e) => e.data()).toList();
    } on FirebaseException catch (e) {
      log(firestoreError(e.code).toString());
      throw firestoreError(e.code);
    } on ArgumentError catch (e) {
      Failure error = Failure("ARGUMENT_ERROR",
          message:
              "$getAllByQueryListErrorMessage\nERROR MESSAGE: ${e.message}",
          location: "firestore_utils.dart");
      log(error.toString());
      throw error;
    } on Exception catch (e) {
      Failure error = Failure("UNKNOWN",
          message: "$getAllByQueryListErrorMessage\nERROR MESSAGE: $e",
          location: "firestore_service.dart");
      log(error.toString());
      throw error;
    } on Failure catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
