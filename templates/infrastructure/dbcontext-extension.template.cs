using Microsoft.EntityFrameworkCore;
using Volo.Abp;
using Volo.Abp.EntityFrameworkCore.Modeling;

namespace ${NAMESPACE}.EntityFrameworkCore
{
    /// <summary>
    /// Extension methods for configuring ${MODULE_NAME} entities in DbContext.
    /// </summary>
    public static class ${MODULE_NAME}DbContextModelCreatingExtensions
    {
        /// <summary>
        /// Configures the ${MODULE_NAME} module entities.
        /// </summary>
        /// <param name="builder">The model builder.</param>
        public static void Configure${MODULE_NAME}(this ModelBuilder builder)
        {
            Check.NotNull(builder, nameof(builder));

            // Apply entity configurations
            builder.ApplyConfiguration(new ${ENTITY_NAME}Configuration());

            ${ADDITIONAL_CONFIGURATIONS}
        }
    }
}

