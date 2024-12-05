namespace RollAttendanceServer.Data.Enum
{
    public enum Status
    {
        // EVENT STATUS
        EVENT_NOT_STARTED = 0,
        EVENT_IN_PROGRESS = 1,
        EVENT_COMPLETED = 2,
        EVENT_CANCELLED = 3,
        EVENT_POSTPONED = 4,

        // ATTENDANCE STATUS
        USER_PRESENTED = 0,
        USER_ABSENTED = 1,
        USER_PERMITTED_ABSENTED = 2,
        USER_LATED = 3,
    }
}
