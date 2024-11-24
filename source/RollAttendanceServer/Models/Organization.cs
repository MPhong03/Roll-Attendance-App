using RollAttendanceServer.Models.Common;
using System.ComponentModel.DataAnnotations;

namespace RollAttendanceServer.Models
{
    public class Organization : BaseEntity
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString("N").ToString().ToUpper();
        public string? Name { get; set; }
        public string? Description { get; set; }
        public string Address { get; set; } = string.Empty;
        public ICollection<User> Representatives { get; set; } = new List<User>();
        public ICollection<User> Organizers { get; set; } = new List<User>();
        public ICollection<User> Users { get; set; } = new List<User>();
    }
}
