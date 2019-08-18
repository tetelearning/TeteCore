﻿// <auto-generated />
using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using Tete.Api.Contexts;

namespace Tete.Api.Migrations
{
    [DbContext(typeof(MainContext))]
    partial class MainContextModelSnapshot : ModelSnapshot
    {
        protected override void BuildModel(ModelBuilder modelBuilder)
        {
#pragma warning disable 612, 618
            modelBuilder
                .HasAnnotation("ProductVersion", "2.2.6-servicing-10079")
                .HasAnnotation("Relational:MaxIdentifierLength", 128)
                .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

            modelBuilder.Entity("Tete.Models.Config.Flag", b =>
                {
                    b.Property<string>("Key")
                        .ValueGeneratedOnAdd()
                        .HasMaxLength(30);

                    b.Property<DateTime>("Created");

                    b.Property<string>("Data")
                        .HasMaxLength(200);

                    b.Property<DateTime>("Modified");

                    b.Property<bool>("Value");

                    b.HasKey("Key");

                    b.ToTable("Flags");
                });

            modelBuilder.Entity("Tete.Models.Config.Setting", b =>
                {
                    b.Property<string>("Key")
                        .ValueGeneratedOnAdd()
                        .HasMaxLength(30);

                    b.Property<string>("Value")
                        .HasMaxLength(100);

                    b.HasKey("Key");

                    b.ToTable("Settings");
                });

            modelBuilder.Entity("Tete.Models.Logging.Log", b =>
                {
                    b.Property<Guid>("LogId")
                        .ValueGeneratedOnAdd();

                    b.Property<string>("Description");

                    b.Property<string>("MachineName");

                    b.Property<DateTime>("Occured");

                    b.Property<string>("StackTrace");

                    b.HasKey("LogId");

                    b.ToTable("Logs");
                });
#pragma warning restore 612, 618
        }
    }
}
