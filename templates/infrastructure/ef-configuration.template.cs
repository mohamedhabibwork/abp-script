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

            ${PROPERTY_CONFIGURATIONS}

            ${INDEXES}

            ${ADDITIONAL_CONFIGURATIONS}

            // Relationships
            ${RELATIONSHIPS}
        }
    }
}

