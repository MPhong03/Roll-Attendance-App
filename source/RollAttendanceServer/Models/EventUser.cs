using System.ComponentModel.DataAnnotations;

namespace RollAttendanceServer.Models
{
    public class EventUser
    {
        [Key]
        public int Id { get; set; }
        public string EventId { get; set; }
        public Event Event { get; set; }

        public string UserId { get; set; }
        public User User { get; set; }
    }
}
