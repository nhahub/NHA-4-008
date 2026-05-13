import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/request_model.dart';

/// Firestore collection: `requests`.
class RequestService {
  static final _db = FirebaseFirestore.instance;
  static const String collectionName = 'requests';

  /// Creates a request document; returns the new [requestId] (document id).
  static Future<String> createRequest({
    required String userId,
    required String providerId,
    required double startingPrice,
    required String label,
    required String description,
    required String location,
    required bool bookingIsScheduled,
    DateTime? scheduledAt,
    RequestStatus status = RequestStatus.waiting,
  }) async {
    final docRef = _db.collection(collectionName).doc();
    final requestId = docRef.id;

    await docRef.set({
      'requestId': requestId,
      'userId': userId,
      'provider_Id': providerId,
      'startingPrice': startingPrice,
      'label': label.trim(),
      'description': description.trim(),
      'location': location.trim(),
      'bookingIsScheduled': bookingIsScheduled,
      if (bookingIsScheduled && scheduledAt != null)
        'scheduledAt': Timestamp.fromDate(scheduledAt),
      'status': status.firestoreValue,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return requestId;
  }

  /// Live updates for all requests assigned to [providerId] (`provider_Id` in Firestore).
  static Stream<List<RequestModel>> watchRequestsForProvider(String providerId) {
    return _db
        .collection(collectionName)
        .where('provider_Id', isEqualTo: providerId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => RequestModel.fromMap(d.data(), documentId: d.id))
          .toList();
      list.sort((a, b) {
        final ta = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final tb = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return tb.compareTo(ta);
      });
      return list;
    });
  }
}
