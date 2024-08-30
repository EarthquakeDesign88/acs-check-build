class Location {
  final int jobScheduleId;
  final int locationId;
  final String locationDescription;
  final String locationQR;
  final String zoneDescription;
  final int jobStatusId;
  final String jobStatusDescription;
  final String inspectionCompletedAt;

  Location({
    required this.jobScheduleId,
    required this.locationId,
    required this.locationDescription,
    required this.locationQR,
    required this.zoneDescription,
    required this.jobStatusId,
    required this.jobStatusDescription,
    required this.inspectionCompletedAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      jobScheduleId: json['job_schedule_id'] ?? 0,
      locationId: json['location_id'] ?? 0,
      locationDescription: json['location_description'] ?? '',
      locationQR: json['location_qr'] ?? '',
      zoneDescription: json['zone_description'] ?? '',
      jobStatusId: json['job_status_id'] ?? 0,
      jobStatusDescription: json['job_status_description'] ?? '',
      inspectionCompletedAt: json['inspection_completed_at'] ?? '',
    );
  }
}
