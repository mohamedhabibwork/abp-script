using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Volo.Abp.EntityFrameworkCore.Modeling;

namespace ${NAMESPACE}.EntityFrameworkCore.Configurations
{
    /// <summary>
    /// Entity Framework Core configuration for ${ENTITY_NAME}.
    /// Implements the Fluent API pattern for entity configuration.
    /// </summary>
    public class ${ENTITY_NAME}Configuration : IEntityTypeConfiguration<${ENTITY_NAME}>
    {
        /// <summary>
        /// Configures the ${ENTITY_NAME} entity.
        /// </summary>
        /// <param name="builder">The entity type builder.</param>
        public void Configure(EntityTypeBuilder<${ENTITY_NAME}> builder)
        {
            // Table configuration
            builder.ToTable("${ENTITY_NAME_PLURAL}");

            // Configure ABP base properties
            builder.ConfigureByConvention();

            // Primary key
            builder.HasKey(x => x.Id);

            // Properties
            builder.Property(x => x.Name)
                .IsRequired()
                .HasMaxLength(${ENTITY_NAME}Consts.MaxNameLength)
                .HasColumnName(nameof(${ENTITY_NAME}.Name));

            builder.Property(x => x.Description)
                .HasMaxLength(${ENTITY_NAME}Consts.MaxDescriptionLength)
                .HasColumnName(nameof(${ENTITY_NAME}.Description));

            builder.Property(x => x.IsActive)
                .IsRequired()
                .HasDefaultValue(true)
                .HasColumnName(nameof(${ENTITY_NAME}.IsActive));

            // Indexes
            builder.HasIndex(x => x.Name)
                .HasDatabaseName($"IX_{nameof(${ENTITY_NAME})}_{nameof(${ENTITY_NAME}.Name)}");

            builder.HasIndex(x => x.IsActive)
                .HasDatabaseName($"IX_{nameof(${ENTITY_NAME})}_{nameof(${ENTITY_NAME}.IsActive)}");

            // Audit properties (already configured by ConfigureByConvention, but can be customized)
            builder.Property(x => x.CreationTime)
                .HasColumnName(nameof(${ENTITY_NAME}.CreationTime));

            builder.Property(x => x.CreatorId)
                .HasColumnName(nameof(${ENTITY_NAME}.CreatorId));

            builder.Property(x => x.LastModificationTime)
                .HasColumnName(nameof(${ENTITY_NAME}.LastModificationTime));

            builder.Property(x => x.LastModifierId)
                .HasColumnName(nameof(${ENTITY_NAME}.LastModifierId));

            builder.Property(x => x.IsDeleted)
                .HasDefaultValue(false)
                .HasColumnName(nameof(${ENTITY_NAME}.IsDeleted));

            builder.Property(x => x.DeleterId)
                .HasColumnName(nameof(${ENTITY_NAME}.DeleterId));

            builder.Property(x => x.DeletionTime)
                .HasColumnName(nameof(${ENTITY_NAME}.DeletionTime));

            ${ADDITIONAL_CONFIGURATIONS}

            // Relationships
            ${RELATIONSHIPS}
        }
    }
}

