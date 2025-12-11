using Microsoft.EntityFrameworkCore;
using Volo.Abp.Data;
using Volo.Abp.EntityFrameworkCore;

namespace ${NAMESPACE}.EntityFrameworkCore
{
    /// <summary>
    /// Database context for ${MODULE_NAME} module.
    /// Implements the Unit of Work pattern through EF Core.
    /// </summary>
    [ConnectionStringName("${MODULE_NAME}")]
    public class ${DB_CONTEXT_NAME} : AbpDbContext<${DB_CONTEXT_NAME}>
    {
        /// <summary>
        /// Gets or sets the ${ENTITY_NAME_PLURAL} DbSet.
        /// </summary>
        public DbSet<${ENTITY_NAME}> ${ENTITY_NAME_PLURAL} { get; set; }

        ${ADDITIONAL_DBSETS}

        /// <summary>
        /// Initializes a new instance of the <see cref="${DB_CONTEXT_NAME}"/> class.
        /// </summary>
        /// <param name="options">The database context options.</param>
        public ${DB_CONTEXT_NAME}(DbContextOptions<${DB_CONTEXT_NAME}> options)
            : base(options)
        {
        }

        /// <summary>
        /// Configures the model using Fluent API.
        /// </summary>
        /// <param name="builder">The model builder.</param>
        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            // Configure ${MODULE_NAME} module entities
            builder.Configure${MODULE_NAME}();
        }
    }
}

