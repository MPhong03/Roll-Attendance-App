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
        USER_PERMITTED_LATED = 4,

        // REQUEST
        REQUEST_WAITING = 0,
        REQUEST_APPROVED = 1,
        REQUEST_REJECTED = 2,
        REQUEST_CANCELLED = 3,

        // INVITE
        INVITION_WAITING = 0,
        INVITION_APPROVED = 1,
        INVITION_REJECTED = 2,
        INVITION_CANCELLED = 3,

        // REQUEST TYPE
        ABSENT_REQUEST = 0,
        LATE_REQUEST = 1,

        // PARTICIPATE ORGANIZATION
        USER_PENDING = 0,
        USER_JOINED = 1,
        USER_NOT_JOINED = 2,
    }
}
