using Microsoft.Extensions.DependencyInjection;
using Volo.Abp.AspNetCore.Mvc;
using Volo.Abp.AutoMapper;
using Volo.Abp.Modularity;

namespace ${NAMESPACE}.${MODULE_NAME}
{
    /// <summary>
    /// ABP module class for ${MODULE_NAME}.
    /// Defines module dependencies and configuration.
    /// </summary>
    [DependsOn(
        typeof(AbpAspNetCoreMvcModule),
        typeof(AbpAutoMapperModule),
        typeof(${MODULE_NAME}DomainModule),
        typeof(${MODULE_NAME}ApplicationContractsModule)
    )]
    public class ${MODULE_NAME}HttpApiModule : AbpModule
    {
        /// <summary>
        /// Configures services for the ${MODULE_NAME} HTTP API module.
        /// </summary>
        /// <param name="context">The service configuration context.</param>
        public override void ConfigureServices(ServiceConfigurationContext context)
        {
            // Configure controllers
            Configure<AbpAspNetCoreMvcOptions>(options =>
            {
                options.ConventionalControllers.Create(typeof(${MODULE_NAME}HttpApiModule).Assembly);
            });
        }
    }

    /// <summary>
    /// ABP domain module class for ${MODULE_NAME}.
    /// </summary>
    [DependsOn(
        typeof(AbpDddDomainModule),
        typeof(${MODULE_NAME}DomainSharedModule)
    )]
    public class ${MODULE_NAME}DomainModule : AbpModule
    {
        /// <summary>
        /// Configures services for the ${MODULE_NAME} domain module.
        /// </summary>
        /// <param name="context">The service configuration context.</param>
        public override void ConfigureServices(ServiceConfigurationContext context)
        {
            // Domain services are registered automatically by ABP
        }
    }

    /// <summary>
    /// ABP application module class for ${MODULE_NAME}.
    /// </summary>
    [DependsOn(
        typeof(AbpDddApplicationModule),
        typeof(AbpAutoMapperModule),
        typeof(${MODULE_NAME}DomainModule),
        typeof(${MODULE_NAME}ApplicationContractsModule)
    )]
    public class ${MODULE_NAME}ApplicationModule : AbpModule
    {
        /// <summary>
        /// Configures services for the ${MODULE_NAME} application module.
        /// </summary>
        /// <param name="context">The service configuration context.</param>
        public override void ConfigureServices(ServiceConfigurationContext context)
        {
            // Configure AutoMapper
            context.Services.AddAutoMapperObjectMapper<${MODULE_NAME}ApplicationModule>();
            
            Configure<AbpAutoMapperOptions>(options =>
            {
                options.AddMaps<${MODULE_NAME}ApplicationModule>(validate: true);
            });

            // Configure FluentValidation
            context.Services.AddValidatorsFromAssembly(typeof(${MODULE_NAME}ApplicationModule).Assembly);
        }
    }

    /// <summary>
    /// ABP Entity Framework Core module class for ${MODULE_NAME}.
    /// </summary>
    [DependsOn(
        typeof(AbpEntityFrameworkCoreModule),
        typeof(${MODULE_NAME}DomainModule)
    )]
    public class ${MODULE_NAME}EntityFrameworkCoreModule : AbpModule
    {
        /// <summary>
        /// Configures services for the ${MODULE_NAME} EF Core module.
        /// </summary>
        /// <param name="context">The service configuration context.</param>
        public override void ConfigureServices(ServiceConfigurationContext context)
        {
            context.Services.AddAbpDbContext<${MODULE_NAME}DbContext>(options =>
            {
                // Add default repositories
                options.AddDefaultRepositories(includeAllEntities: true);

                // Add custom repositories
                options.AddRepository<${ENTITY_NAME}, EfCore${ENTITY_NAME}Repository>();

                ${ADDITIONAL_REPOSITORY_REGISTRATIONS}
            });

            // Configure database provider
            Configure<AbpDbContextOptions>(options =>
            {
                options.Configure<${MODULE_NAME}DbContext>(c =>
                {
                    c.UseSqlServer();
                });
            });
        }
    }

    /// <summary>
    /// ABP application contracts module class for ${MODULE_NAME}.
    /// </summary>
    [DependsOn(
        typeof(AbpDddApplicationContractsModule),
        typeof(${MODULE_NAME}DomainSharedModule)
    )]
    public class ${MODULE_NAME}ApplicationContractsModule : AbpModule
    {
    }

    /// <summary>
    /// ABP domain shared module class for ${MODULE_NAME}.
    /// </summary>
    [DependsOn(
        typeof(AbpDddDomainSharedModule)
    )]
    public class ${MODULE_NAME}DomainSharedModule : AbpModule
    {
        /// <summary>
        /// Configures services for the ${MODULE_NAME} domain shared module.
        /// </summary>
        /// <param name="context">The service configuration context.</param>
        public override void ConfigureServices(ServiceConfigurationContext context)
        {
            Configure<AbpVirtualFileSystemOptions>(options =>
            {
                options.FileSets.AddEmbedded<${MODULE_NAME}DomainSharedModule>();
            });

            Configure<AbpLocalizationOptions>(options =>
            {
                options.Resources
                    .Add<${MODULE_NAME}Resource>("en")
                    .AddVirtualJson("/Localization/${MODULE_NAME}");
            });
        }
    }
}

