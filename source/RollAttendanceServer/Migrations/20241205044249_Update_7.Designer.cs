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
    [Migration("20241205044249_Update_7")]
    partial class Update_7
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
                            PermissionsId = "125D9635A26349DB90A8F0BB39E0A215",
                            RolesId = "79F8F7F26CE043A5877494050BC796F6"
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
                        .IsRequired()
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
                            Id = "5CE2189538D341D48328B520329EE7AE",
                            Email = "admin@gmail.com",
                            IsDeleted = false,
                            Password = "$2a$10$PtjBnVDUe4bQxzFIawQXwexxNKLzzFfxmw2tBNbv6eXIAnj3bMtnW",
                            Phone = "0000000000",
                            RoleId = "79F8F7F26CE043A5877494050BC796F6"
                        });
                });

            modelBuilder.Entity("RollAttendanceServer.Models.Event", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnType("nvarchar(450)");

                    b.Property<DateTime>("CreatedAt")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("datetime2")
                        .HasDefaultValueSql("GETUTCDATE()");

                    b.Property<string>("CurrentLocation")
                        .IsRequired()
                        .HasColumnType("nvarchar(max)");

                    b.Property<decimal>("CurrentLocationRadius")
                        .HasColumnType("decimal(18,2)");

                    b.Property<string>("CurrentQR")
                        .IsRequired()
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("Description")
                        .HasColumnType("nvarchar(max)");

                    b.Property<DateTime?>("EndTime")
                        .HasColumnType("datetime2");

                    b.Property<short>("EventStatus")
                        .HasColumnType("smallint");

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("bit");

                    b.Property<string>("Name")
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("OrganizationId")
                        .HasColumnType("nvarchar(450)");

                    b.Property<string>("OrganizerId")
                        .IsRequired()
                        .HasColumnType("nvarchar(max)");

                    b.Property<DateTime?>("StartTime")
                        .HasColumnType("datetime2");

                    b.Property<DateTime>("UpdatedAt")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("datetime2")
                        .HasDefaultValueSql("GETUTCDATE()");

                    b.HasKey("Id");

                    b.HasIndex("OrganizationId");

                    b.ToTable("Events");
                });

            modelBuilder.Entity("RollAttendanceServer.Models.History", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnType("nvarchar(450)");

                    b.Property<int>("AbsentCount")
                        .HasColumnType("int");

                    b.Property<int>("AttendanceTimes")
                        .HasColumnType("int");

                    b.Property<DateTime>("CreatedAt")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("datetime2")
                        .HasDefaultValueSql("GETUTCDATE()");

                    b.Property<DateTime?>("EndTime")
                        .HasColumnType("datetime2");

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("bit");

                    b.Property<DateTime?>("OccurDate")
                        .HasColumnType("datetime2");

                    b.Property<int>("PresentCount")
                        .HasColumnType("int");

                    b.Property<DateTime?>("StartTime")
                        .HasColumnType("datetime2");

                    b.Property<int>("TotalCount")
                        .HasColumnType("int");

                    b.Property<DateTime>("UpdatedAt")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("datetime2")
                        .HasDefaultValueSql("GETUTCDATE()");

                    b.HasKey("Id");

                    b.ToTable("Histories");
                });

            modelBuilder.Entity("RollAttendanceServer.Models.HistoryDetail", b =>
                {
                    b.Property<string>("Id")
                        .HasColumnType("nvarchar(450)");

                    b.Property<DateTime?>("AbsentTime")
                        .HasColumnType("datetime2");

                    b.Property<int>("AttendanceCount")
                        .HasColumnType("int");

                    b.Property<short>("AttendanceStatus")
                        .HasColumnType("smallint");

                    b.Property<DateTime>("CreatedAt")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("datetime2")
                        .HasDefaultValueSql("GETUTCDATE()");

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("bit");

                    b.Property<DateTime?>("LeaveTime")
                        .HasColumnType("datetime2");

                    b.Property<DateTime>("UpdatedAt")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("datetime2")
                        .HasDefaultValueSql("GETUTCDATE()");

                    b.Property<string>("UserAvatar")
                        .IsRequired()
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("UserEmail")
                        .IsRequired()
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("UserId")
                        .IsRequired()
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("UserName")
                        .IsRequired()
                        .HasColumnType("nvarchar(max)");

                    b.HasKey("Id");

                    b.ToTable("HistoryDetails");
                });

            modelBuilder.Entity("RollAttendanceServer.Models.Organization", b =>
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

                    b.Property<string>("Description")
                        .HasColumnType("nvarchar(max)");

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("bit");

                    b.Property<bool>("IsPrivate")
                        .HasColumnType("bit");

                    b.Property<string>("Name")
                        .HasColumnType("nvarchar(max)");

                    b.Property<DateTime>("UpdatedAt")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("datetime2")
                        .HasDefaultValueSql("GETUTCDATE()");

                    b.HasKey("Id");

                    b.ToTable("Organizations");
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
                            Id = "D9A4A692FEB145829512021775EDE80B",
                            CreatedAt = new DateTime(2024, 12, 5, 4, 42, 49, 209, DateTimeKind.Utc).AddTicks(7103),
                            IsDeleted = false,
                            PermissionName = "Organization Management",
                            PermissionValue = "organization_management",
                            UpdatedAt = new DateTime(2024, 12, 5, 4, 42, 49, 209, DateTimeKind.Utc).AddTicks(7106)
                        },
                        new
                        {
                            Id = "A08C2C8F2B5C4CA99FF42FF013315576",
                            CreatedAt = new DateTime(2024, 12, 5, 4, 42, 49, 209, DateTimeKind.Utc).AddTicks(7111),
                            IsDeleted = false,
                            PermissionName = "User Management",
                            PermissionValue = "user_management",
                            UpdatedAt = new DateTime(2024, 12, 5, 4, 42, 49, 209, DateTimeKind.Utc).AddTicks(7111)
                        },
                        new
                        {
                            Id = "125D9635A26349DB90A8F0BB39E0A215",
                            CreatedAt = new DateTime(2024, 12, 5, 4, 42, 49, 209, DateTimeKind.Utc).AddTicks(7115),
                            IsDeleted = false,
                            PermissionName = "Administrator",
                            PermissionValue = "all_permissions",
                            UpdatedAt = new DateTime(2024, 12, 5, 4, 42, 49, 209, DateTimeKind.Utc).AddTicks(7115)
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
                            Id = "79F8F7F26CE043A5877494050BC796F6",
                            CreatedAt = new DateTime(2024, 12, 5, 4, 42, 49, 209, DateTimeKind.Utc).AddTicks(7232),
                            IsDeleted = false,
                            RoleName = "Administrator",
                            UpdatedAt = new DateTime(2024, 12, 5, 4, 42, 49, 209, DateTimeKind.Utc).AddTicks(7233)
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

                    b.Property<string>("EventId")
                        .HasColumnType("nvarchar(450)");

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

                    b.HasIndex("EventId");

                    b.ToTable("Users");
                });

            modelBuilder.Entity("RollAttendanceServer.Models.UserOrganizationRole", b =>
                {
                    b.Property<string>("UserId")
                        .HasColumnType("nvarchar(450)");

                    b.Property<string>("OrganizationId")
                        .HasColumnType("nvarchar(450)");

                    b.Property<DateTime>("CreatedAt")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("datetime2")
                        .HasDefaultValueSql("GETUTCDATE()");

                    b.Property<bool>("IsDeleted")
                        .HasColumnType("bit");

                    b.Property<int>("Role")
                        .HasColumnType("int");

                    b.Property<DateTime>("UpdatedAt")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("datetime2")
                        .HasDefaultValueSql("GETUTCDATE()");

                    b.HasKey("UserId", "OrganizationId");

                    b.HasIndex("OrganizationId");

                    b.ToTable("UserOrganizationRoles");
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
                        .HasForeignKey("RoleId")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();

                    b.Navigation("Role");
                });

            modelBuilder.Entity("RollAttendanceServer.Models.Event", b =>
                {
                    b.HasOne("RollAttendanceServer.Models.Organization", "Organization")
                        .WithMany("Events")
                        .HasForeignKey("OrganizationId");

                    b.Navigation("Organization");
                });

            modelBuilder.Entity("RollAttendanceServer.Models.User", b =>
                {
                    b.HasOne("RollAttendanceServer.Models.Event", null)
                        .WithMany("PermitedUser")
                        .HasForeignKey("EventId");
                });

            modelBuilder.Entity("RollAttendanceServer.Models.UserOrganizationRole", b =>
                {
                    b.HasOne("RollAttendanceServer.Models.Organization", "Organization")
                        .WithMany("UserOrganizationRoles")
                        .HasForeignKey("OrganizationId")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();

                    b.HasOne("RollAttendanceServer.Models.User", "User")
                        .WithMany("UserOrganizationRoles")
                        .HasForeignKey("UserId")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();

                    b.Navigation("Organization");

                    b.Navigation("User");
                });

            modelBuilder.Entity("RollAttendanceServer.Models.Event", b =>
                {
                    b.Navigation("PermitedUser");
                });

            modelBuilder.Entity("RollAttendanceServer.Models.Organization", b =>
                {
                    b.Navigation("Events");

                    b.Navigation("UserOrganizationRoles");
                });

            modelBuilder.Entity("RollAttendanceServer.Models.User", b =>
                {
                    b.Navigation("UserOrganizationRoles");
                });
#pragma warning restore 612, 618
        }
    }
}