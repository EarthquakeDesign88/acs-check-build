class JobSchedule {
  final int jobScheduleId;
  final String jobScheduleDate;
  final int jobScheduleStatusId;
  final int jobScheduleShiftId;
  final String inspectionCompletedAt;
  final String jobStatusDescription;
  final String workShiftDescription;
  final String shiftTimeSlot;
  final String locationDescription;
  final String zoneDescription;
  final int jobAuthorityId;
  final int userId;

  JobSchedule({
    required this.jobScheduleId,
    required this.jobScheduleDate,
    required this.jobScheduleStatusId,
    required this.jobScheduleShiftId,
    required this.inspectionCompletedAt,
    required this.jobStatusDescription,
    required this.workShiftDescription,
    required this.shiftTimeSlot,
    required this.locationDescription,
    required this.zoneDescription,
    required this.jobAuthorityId,
    required this.userId,
  });

  factory JobSchedule.fromJson(Map<String, dynamic> json) {
    return JobSchedule(
      jobScheduleId: json['job_schedule_id'] ?? 0,
      jobScheduleDate: json['job_schedule_date'] ?? '',
      jobScheduleStatusId: json['job_schedule_status_id'] ?? 0,
      jobScheduleShiftId: json['job_schedule_shift_id'] ?? 0,
      inspectionCompletedAt: json['inspection_completed_at'] ?? '',
      jobStatusDescription: json['job_status_description'] ?? '',
      workShiftDescription: json['work_shift_description'] ?? '',
      shiftTimeSlot: json['shift_time_slot'] ?? '',
      locationDescription: json['location_description'] ?? '',
      zoneDescription: json['zone_description'] ?? '',
      jobAuthorityId: json['job_authority_id'] ?? 0,
      userId: json['user_id'] ?? 0
    );
  }
}
