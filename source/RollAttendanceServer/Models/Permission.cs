﻿using RollAttendanceServer.Models.Common;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Text.Json.Serialization;

namespace RollAttendanceServer.Models
{
    public class Permission : BaseEntity
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString("N").ToString().ToUpper();
        public string PermissionName { get; set; } = string.Empty;
        public string PermissionValue { get; set; } = string.Empty;
        [JsonIgnore]
        public ICollection<Role> Roles { get; set; } = new HashSet<Role>();
    }
}
