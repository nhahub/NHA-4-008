import 'package:cloud_firestore/cloud_firestore.dart';

/// Stored in Firestore collection `requests`.
///
/// Status values match Firestore strings: Waiting, Accepted, Declined,
/// Pending, Payment Required, Completed.
enum RequestStatus {
  waiting,
  accepted,
  declined,
  pending,
  paymentRequired,
  completed,
}

extension RequestStatusX on RequestStatus {
  /// Exact string written to / read from Firestore `status` field.
  String get firestoreValue {
    switch (this) {
      case RequestStatus.waiting:
        return 'Waiting';
      case RequestStatus.accepted:
        return 'Accepted';
      case RequestStatus.declined:
        return 'Declined';
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.paymentRequired:
        return 'Payment Required';
      case RequestStatus.completed:
        return 'Completed';
    }
  }

  static RequestStatus fromFirestore(String? raw) {
    switch (raw?.trim()) {
      case 'Waiting':
        return RequestStatus.waiting;
      case 'Accepted':
        return RequestStatus.accepted;
      case 'Declined':
        return RequestStatus.declined;
      case 'Pending':
        return RequestStatus.pending;
      case 'Payment Required':
        return RequestStatus.paymentRequired;
      case 'Completed':
        return RequestStatus.completed;
      default:
        return RequestStatus.waiting;
    }
  }
}

class RequestModel {
  /// Same as the Firestore document ID.
  final String requestId;
  final String userId;
  /// Provider document ID (e.g. in `electricians`, `plumbers`, or `delivery`).
  /// Stored in Firestore as `provider_Id`.
  final String providerId;
  /// Provider’s advertised starting price at booking time (EGP).
  final double startingPrice;
  final String label;
  final String description;
  final RequestStatus status;
  final DateTime? createdAt;
  /// Where the user wants the service (exact address / directions).
  final String? location;
  /// When [bookingIsScheduled] is true, when the appointment should happen.
  final DateTime? scheduledAt;
  /// `true` if the user chose a future date/time; `false` for as soon as possible.
  final bool bookingIsScheduled;

  const RequestModel({
    required this.requestId,
    required this.userId,
    required this.providerId,
    this.startingPrice = 0,
    required this.label,
    required this.description,
    required this.status,
    this.createdAt,
    this.location,
    this.scheduledAt,
    this.bookingIsScheduled = false,
  });

  factory RequestModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    DateTime? created;
    final rawCreated = map['createdAt'];
    if (rawCreated is Timestamp) {
      created = rawCreated.toDate();
    }

    DateTime? scheduled;
    final rawScheduled = map['scheduledAt'];
    if (rawScheduled is Timestamp) {
      scheduled = rawScheduled.toDate();
    }

    final loc = map['location'] as String?;
    final bookingScheduled = map['bookingIsScheduled'] as bool? ??
        (scheduled != null);

    return RequestModel(
      requestId: (map['requestId'] as String?)?.trim().isNotEmpty == true
          ? map['requestId'] as String
          : (documentId ?? ''),
      userId: (map['userId'] as String?) ?? '',
      providerId: (map['provider_Id'] as String?) ??
          (map['providerId'] as String?) ??
          '',
      startingPrice: (map['startingPrice'] as num?)?.toDouble() ?? 0,
      label: (map['label'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      status: RequestStatusX.fromFirestore(map['status'] as String?),
      createdAt: created,
      location: loc?.trim().isEmpty == true ? null : loc?.trim(),
      scheduledAt: scheduled,
      bookingIsScheduled: bookingScheduled,
    );
  }

  Map<String, dynamic> toMap() => {
        'requestId': requestId,
        'userId': userId,
        'provider_Id': providerId,
        'startingPrice': startingPrice,
        'label': label,
        'description': description,
        'status': status.firestoreValue,
        if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
        if (location != null && location!.trim().isNotEmpty)
          'location': location!.trim(),
        'bookingIsScheduled': bookingIsScheduled,
        if (scheduledAt != null)
          'scheduledAt': Timestamp.fromDate(scheduledAt!),
      };
}
