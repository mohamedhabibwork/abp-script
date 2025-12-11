using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Volo.Abp.EntityFrameworkCore.Modeling;

namespace ${NAMESPACE}.EntityFrameworkCore.${MODULE_NAME}.Configurations
{
    /// <summary>
    /// Entity configuration for ${ENTITY_NAME} with audit logging support.
    /// Configures entity change tracking and audit properties.
    /// </summary>
    public class ${ENTITY_NAME}AuditConfiguration
    {
        public static void Configure(EntityTypeBuilder<${ENTITY_NAME}> builder)
        {
            // Enable change tracking for audit logging
            builder.Property(e => e.Name)
                .HasChangeTrackingEnabled(true)
                .HasComment("Entity name - tracked for audit");

            builder.Property(e => e.Description)
                .HasChangeTrackingEnabled(true)
                .HasComment("Entity description - tracked for audit");

            builder.Property(e => e.IsActive)
                .HasChangeTrackingEnabled(true)
                .HasComment("Active status - tracked for audit");

            // Configure audit properties if using audited base classes
            builder.ConfigureByConvention(); // Includes audit fields

            // Additional audit-specific indexing
            builder.HasIndex(e => e.CreationTime)
                .HasDatabaseName($"IX_${ENTITY_NAME}_CreationTime");

            builder.HasIndex(e => e.LastModificationTime)
                .HasDatabaseName($"IX_${ENTITY_NAME}_LastModificationTime");

            ${ADDITIONAL_AUDIT_CONFIGURATION}
        }
    }
}

