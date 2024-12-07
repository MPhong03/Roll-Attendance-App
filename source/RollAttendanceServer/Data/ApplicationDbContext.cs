using Microsoft.EntityFrameworkCore;
using RollAttendanceServer.Models;
using RollAttendanceServer.Models.Common;

namespace RollAttendanceServer.Data
{
    public class ApplicationDbContext : DbContext
    {
        public virtual DbSet<User> Users { get; set; }
        public virtual DbSet<Permission> Permissions { get; set; }
        public virtual DbSet<Role> Roles { get; set; }
        public virtual DbSet<Admin> Admins { get; set; }
        public virtual DbSet<Organization> Organizations { get; set; }
        public virtual DbSet<Event> Events { get; set; }
        public virtual DbSet<UserOrganizationRole> UserOrganizationRoles { get; set; }
        public virtual DbSet<History> Histories { get; set; }
        public virtual DbSet<HistoryDetail> HistoryDetails { get; set; }
        public virtual DbSet<ParticipationRequest> ParticipationRequests { get; set; }
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            foreach (var entityType in modelBuilder.Model.GetEntityTypes())
            {
                if (typeof(BaseEntity).IsAssignableFrom(entityType.ClrType))
                {
                    var entity = modelBuilder.Entity(entityType.ClrType);
                    entity.Property(nameof(BaseEntity.CreatedAt)).HasDefaultValueSql("GETUTCDATE()");
                    entity.Property(nameof(BaseEntity.UpdatedAt)).HasDefaultValueSql("GETUTCDATE()");
                }
            }

            // Seed Permissions
            var permission1Id = Guid.NewGuid().ToString("N").ToUpper();
            var permission2Id = Guid.NewGuid().ToString("N").ToUpper();
            var permission3Id = Guid.NewGuid().ToString("N").ToUpper();

            modelBuilder.Entity<Permission>().HasData(
                new Permission
                {
                    Id = permission1Id,
                    PermissionName = "Organization Management",
                    PermissionValue = "organization_management"
                },
                new Permission
                {
                    Id = permission2Id,
                    PermissionName = "User Management",
                    PermissionValue = "user_management"
                },
                new Permission
                {
                    Id = permission3Id,
                    PermissionName = "Administrator",
                    PermissionValue = "all_permissions"
                }
            );

            // Seed Roles
            var role3Id = Guid.NewGuid().ToString("N").ToUpper(); // Administrator role
            modelBuilder.Entity<Role>().HasData(
                new Role
                {
                    Id = role3Id,
                    RoleName = "Administrator"
                }
            );

            // Seed Admin
            var adminId = Guid.NewGuid().ToString("N").ToUpper();
            modelBuilder.Entity<Admin>().HasData(
                new
                {
                    Id = adminId,
                    Email = "admin@gmail.com",
                    Password = BCrypt.Net.BCrypt.HashPassword("admin"),
                    Phone = "0000000000",
                    RoleId = role3Id, // Assign the Administrator role
                    IsDeleted = false
                }
            );

            // Configure many-to-many relationships between Roles and Permissions
            modelBuilder.Entity<Role>()
                .HasMany(r => r.Permissions)
                .WithMany(p => p.Roles)
                .UsingEntity<Dictionary<string, object>>(
                    "RolePermissions",
                    j => j
                        .HasOne<Permission>()
                        .WithMany()
                        .HasForeignKey("PermissionsId")
                        .HasPrincipalKey(p => p.Id),
                    j => j
                        .HasOne<Role>()
                        .WithMany()
                        .HasForeignKey("RolesId")
                        .HasPrincipalKey(r => r.Id),
                    j =>
                    {
                        j.HasData(
                            new { PermissionsId = permission3Id, RolesId = role3Id }
                        );
                    }
                );

            modelBuilder.Entity<UserOrganizationRole>()
            .HasKey(uor => new { uor.UserId, uor.OrganizationId });

            modelBuilder.Entity<UserOrganizationRole>()
                .HasOne(uor => uor.User)
                .WithMany(u => u.UserOrganizationRoles)
                .HasForeignKey(uor => uor.UserId);

            modelBuilder.Entity<UserOrganizationRole>()
                .HasOne(uor => uor.Organization)
                .WithMany(o => o.UserOrganizationRoles)
                .HasForeignKey(uor => uor.OrganizationId);

            modelBuilder.Entity<UserOrganizationRole>()
                .Property(uor => uor.Role)
                .HasConversion<int>();
        }
        public override int SaveChanges()
        {
            UpdateTimestamps();
            return base.SaveChanges();
        }
        public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            UpdateTimestamps();
            return base.SaveChangesAsync(cancellationToken);
        }
        private void UpdateTimestamps()
        {
            var now = DateTime.UtcNow;
            foreach (var entry in ChangeTracker.Entries<BaseEntity>())
            {
                switch (entry.State)
                {
                    case EntityState.Added:
                        entry.Entity.CreatedAt = now;
                        entry.Entity.UpdatedAt = now;
                        break;
                    case EntityState.Modified:
                        entry.Entity.UpdatedAt = now;
                        break;
                }
            }
        }

    }
}
