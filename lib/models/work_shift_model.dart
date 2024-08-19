class WorkShift {
  final int jobScheduleShiftId;
  final String workShiftDescription;
  final String shiftTimeSlot;
  final String jobScheduleDate;
  final int userId;

  WorkShift(
    {
      required this.jobScheduleShiftId,
      required this.workShiftDescription,
      required this.shiftTimeSlot,
      required this.jobScheduleDate,
      required this.userId,
    }
  );

  factory WorkShift.fromJson(Map<String, dynamic> json) {
    return WorkShift(
      jobScheduleShiftId: json['job_schedule_shift_id'],
      workShiftDescription: json['work_shift_description'],
      shiftTimeSlot: json['shift_time_slot'],
      jobScheduleDate: json['job_schedule_date'],
      userId: json['user_id']
    );
  }
}
