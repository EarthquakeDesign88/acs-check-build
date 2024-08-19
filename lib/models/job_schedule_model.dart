class JobSchedule {
  final int jobScheduleId;
  final String jobScheduleDate;
  final String jobStatusDescription;
  final String workShiftDescription;
  final String shiftTimeSlot;
  final String locationDescription;
  final String zoneDescription;
  final int userId;

  JobSchedule({
    required this.jobScheduleId,
    required this.jobScheduleDate,
    required this.jobStatusDescription,
    required this.workShiftDescription,
    required this.shiftTimeSlot,
    required this.locationDescription,
    required this.zoneDescription,
    required this.userId,
  });

  factory JobSchedule.fromJson(Map<String, dynamic> json) {
    return JobSchedule(
      jobScheduleId: json['job_schedule_id'],
      jobScheduleDate: json['job_schedule_date'],
      jobStatusDescription: json['job_status_description'],
      workShiftDescription: json['work_shift_description'],
      shiftTimeSlot: json['shift_time_slot'],
      locationDescription: json['location_description'],
      zoneDescription: json['zone_description'],
      userId: json['user_id']
    );
  }
}
