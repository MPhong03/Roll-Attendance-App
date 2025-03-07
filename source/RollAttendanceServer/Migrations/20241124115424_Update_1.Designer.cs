﻿// <auto-generated />
using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using RollAttendanceServer.Data;

#nullable disable

namespace RollAttendanceServer.Migrations
{
    [DbContext(typeof(ApplicationDbContext))]
    [Migration("20241124115424_Update_1")]
    partial class Update_1
    {
        protected override void BuildTargetModel(ModelBuilder modelBuilder)
        {
#pragma warning disable 612, 618
            modelBuilder
                .HasAnnotation("ProductVersion", "6.0.36")
                .HasAnnotation("Relational:MaxIdentifierLength", 128);

            SqlServerModelBuilderExtensions.UseIdentityColumns(modelBuilder, 1L, 1);

            modelBuilder.Entity("RolePermissions", b =>
                {
                    b.Property<string>("PermissionsId")
                        .HasColumnType("nvarchar(450)");

                    b.Property<string>("RolesId")
                        .HasColumnType("nvarchar(450)");

                    b.HasKey("PermissionsId", "RolesId");

                    b.HasIndex("RolesId");

                    b.ToTable("RolePermissions");

                    b.HasData(
                        new
                        {
                            PermissionsId = "2D9CEABD7D2146ABAF9D0BAC0B5647A9",
                            RolesId = "A316410EF2634277A7B285D0D0BB25AC"
                        },
                        new
                        {
                            PermissionsId = "31DB31C4A3834215AAA16452D6171D02",
                            RolesId = "A316410EF2634277A7B285D0D0BB25AC"
                        },
                        new
                        {
                            PermissionsId = "9B8C5833BE0243C1B1F888DB0FB60B36",
                            RolesId = "A316410EF2634277A7B285D0D0BB25AC"
                        });
                });

            modelBuilder.Entity("RollAttendanceServer.Models.Admin", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnType("nvarchar(450)");

                    b.Property<DateTime>("CreatedAt")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("datetime2")
                        .HasDefaultValueSql("GETUTCDATE()");

                    b.Property<string>("Email")
                        .IsRequired()
                        .HasColumnType("nvarchar(max)");

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("bit");

                    b.Property<string>("Password")
                        .IsRequired()
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("Phone")
                        .IsRequired()
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("RoleId")
                        .HasColumnType("nvarchar(450)");

                    b.Property<DateTime>("UpdatedAt")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("datetime2")
                        .HasDefaultValueSql("GETUTCDATE()");

                    b.HasKey("Id");

                    b.HasIndex("RoleId");

                    b.ToTable("Admins");

                    b.HasData(
                        new
                        {
                            Id = "D0FE9050C0304DC185B212D2C6D72D19",
                            Email = "admin@gmail.com",
                            IsDeleted = false,
                            Password = "$2a$10$99vv4T7VQc/tZIe5JvWxFuZqqWxEuCXdRAt/cqwCxqUuOydxHoQ7a",
                            Phone = "0000000000",
                            RoleId = "A316410EF2634277A7B285D0D0BB25AC"
                        });
                });

            modelBuilder.Entity("RollAttendanceServer.Models.Permission", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnType("nvarchar(450)");

                    b.Property<DateTime>("CreatedAt")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("datetime2")
                        .HasDefaultValueSql("GETUTCDATE()");

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("bit");

                    b.Property<string>("PermissionName")
                        .IsRequired()
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("PermissionValue")
                        .IsRequired()
                        .HasColumnType("nvarchar(max)");

                    b.Property<DateTime>("UpdatedAt")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("datetime2")
                        .HasDefaultValueSql("GETUTCDATE()");

                    b.HasKey("Id");

                    b.ToTable("Permissions");

                    b.HasData(
                        new
                        {
                            Id = "2D9CEABD7D2146ABAF9D0BAC0B5647A9",
                            CreatedAt = new DateTime(2024, 11, 24, 11, 54, 23, 752, DateTimeKind.Utc).AddTicks(3660),
                            IsDeleted = false,
                            PermissionName = "Organization Management",
                            PermissionValue = "organization_management",
                            UpdatedAt = new DateTime(2024, 11, 24, 11, 54, 23, 752, DateTimeKind.Utc).AddTicks(3663)
                        },
                        new
                        {
                            Id = "31DB31C4A3834215AAA16452D6171D02",
                            CreatedAt = new DateTime(2024, 11, 24, 11, 54, 23, 752, DateTimeKind.Utc).AddTicks(3667),
                            IsDeleted = false,
                            PermissionName = "User Management",
                            PermissionValue = "user_management",
                            UpdatedAt = new DateTime(2024, 11, 24, 11, 54, 23, 752, DateTimeKind.Utc).AddTicks(3667)
                        },
                        new
                        {
                            Id = "9B8C5833BE0243C1B1F888DB0FB60B36",
                            CreatedAt = new DateTime(2024, 11, 24, 11, 54, 23, 752, DateTimeKind.Utc).AddTicks(3670),
                            IsDeleted = false,
                            PermissionName = "Administrator",
                            PermissionValue = "all_permissions",
                            UpdatedAt = new DateTime(2024, 11, 24, 11, 54, 23, 752, DateTimeKind.Utc).AddTicks(3670)
                        });
                });

            modelBuilder.Entity("RollAttendanceServer.Models.Role", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnType("nvarchar(450)");

                    b.Property<DateTime>("CreatedAt")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("datetime2")
                        .HasDefaultValueSql("GETUTCDATE()");

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("bit");

                    b.Property<string>("RoleName")
                        .IsRequired()
                        .HasColumnType("nvarchar(max)");

                    b.Property<DateTime>("UpdatedAt")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("datetime2")
                        .HasDefaultValueSql("GETUTCDATE()");

                    b.HasKey("Id");

                    b.ToTable("Roles");

                    b.HasData(
                        new
                        {
                            Id = "A316410EF2634277A7B285D0D0BB25AC",
                            CreatedAt = new DateTime(2024, 11, 24, 11, 54, 23, 752, DateTimeKind.Utc).AddTicks(3770),
                            IsDeleted = false,
                            RoleName = "Administrator",
                            UpdatedAt = new DateTime(2024, 11, 24, 11, 54, 23, 752, DateTimeKind.Utc).AddTicks(3770)
                        });
                });

            modelBuilder.Entity("RollAttendanceServer.Models.User", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnType("nvarchar(450)");

                    b.Property<string>("Address")
                        .IsRequired()
                        .HasColumnType("nvarchar(max)");

                    b.Property<DateTime>("CreatedAt")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("datetime2")
                        .HasDefaultValueSql("GETUTCDATE()");

                    b.Property<string>("Email")
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("FaceData")
                        .IsRequired()
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("Gender")
                        .IsRequired()
                        .HasColumnType("nvarchar(max)");

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("bit");

                    b.Property<string>("Uid")
                        .IsRequired()
                        .HasColumnType("nvarchar(max)");

                    b.Property<DateTime>("UpdatedAt")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("datetime2")
                        .HasDefaultValueSql("GETUTCDATE()");

                    b.HasKey("Id");

                    b.ToTable("Users");
                });

            modelBuilder.Entity("RolePermissions", b =>
                {
                    b.HasOne("RollAttendanceServer.Models.Permission", null)
                        .WithMany()
                        .HasForeignKey("PermissionsId")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();

                    b.HasOne("RollAttendanceServer.Models.Role", null)
                        .WithMany()
                        .HasForeignKey("RolesId")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();
                });

            modelBuilder.Entity("RollAttendanceServer.Models.Admin", b =>
                {
                    b.HasOne("RollAttendanceServer.Models.Role", "Role")
                        .WithMany()
                        .HasForeignKey("RoleId");

                    b.Navigation("Role");
                });
#pragma warning restore 612, 618
        }
    }
}
