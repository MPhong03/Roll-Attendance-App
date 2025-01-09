enum EventStatus {
  notStarted, // 0
  inProgress, // 1
  completed, // 2
  cancelled, // 3
  postponed, // 4
}

String formatEventStatus(EventStatus status) {
  switch (status) {
    case EventStatus.notStarted:
      return "Not Started";
    case EventStatus.inProgress:
      return "In Progress";
    case EventStatus.completed:
      return "Completed";
    case EventStatus.cancelled:
      return "Cancelled";
    case EventStatus.postponed:
      return "Postponed";
    default:
      return "Unknown Status";
  }
}
