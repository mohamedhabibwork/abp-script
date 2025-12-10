using System;
using System.Threading.Tasks;
using Volo.Abp.Data;
using Volo.Abp.DependencyInjection;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Guids;

namespace ${NAMESPACE}.${MODULE_NAME}.DataSeeders
{
    /// <summary>
    /// Data seeder for ${ENTITY_NAME} entities.
    /// Implements IDataSeedContributor for automatic seeding.
    /// Follows the Factory pattern for entity creation.
    /// </summary>
    public class ${ENTITY_NAME}DataSeeder : IDataSeedContributor, ITransientDependency
    {
        private readonly I${ENTITY_NAME}Repository _${ENTITY_NAME_LOWER}Repository;
        private readonly ${ENTITY_NAME}Manager _${ENTITY_NAME_LOWER}Manager;
        private readonly IGuidGenerator _guidGenerator;

        /// <summary>
        /// Initializes a new instance of the <see cref="${ENTITY_NAME}DataSeeder"/> class.
        /// </summary>
        /// <param name="${ENTITY_NAME_LOWER}Repository">The ${ENTITY_NAME} repository.</param>
        /// <param name="${ENTITY_NAME_LOWER}Manager">The ${ENTITY_NAME} domain service.</param>
        /// <param name="guidGenerator">The GUID generator.</param>
        public ${ENTITY_NAME}DataSeeder(
            I${ENTITY_NAME}Repository ${ENTITY_NAME_LOWER}Repository,
            ${ENTITY_NAME}Manager ${ENTITY_NAME_LOWER}Manager,
            IGuidGenerator guidGenerator)
        {
            _${ENTITY_NAME_LOWER}Repository = ${ENTITY_NAME_LOWER}Repository;
            _${ENTITY_NAME_LOWER}Manager = ${ENTITY_NAME_LOWER}Manager;
            _guidGenerator = guidGenerator;
        }

        /// <summary>
        /// Seeds the ${ENTITY_NAME} data.
        /// </summary>
        /// <param name="context">The data seed context.</param>
        public async Task SeedAsync(DataSeedContext context)
        {
            // Check if data already exists
            if (await _${ENTITY_NAME_LOWER}Repository.GetCountAsync() > 0)
            {
                return;
            }

            // Seed sample data
            await SeedSample${ENTITY_NAME_PLURAL}Async(context);
        }

        /// <summary>
        /// Seeds sample ${ENTITY_NAME} entities.
        /// </summary>
        /// <param name="context">The data seed context.</param>
        private async Task SeedSample${ENTITY_NAME_PLURAL}Async(DataSeedContext context)
        {
            // Sample 1
            var ${ENTITY_NAME_LOWER}1 = await _${ENTITY_NAME_LOWER}Manager.CreateAsync(
                "Sample ${ENTITY_NAME} 1",
                "This is a sample ${ENTITY_NAME} for testing and demonstration purposes."
            );
            await _${ENTITY_NAME_LOWER}Repository.InsertAsync(${ENTITY_NAME_LOWER}1);

            // Sample 2
            var ${ENTITY_NAME_LOWER}2 = await _${ENTITY_NAME_LOWER}Manager.CreateAsync(
                "Sample ${ENTITY_NAME} 2",
                "Another sample ${ENTITY_NAME} with different properties."
            );
            await _${ENTITY_NAME_LOWER}Repository.InsertAsync(${ENTITY_NAME_LOWER}2);

            // Sample 3 (inactive)
            var ${ENTITY_NAME_LOWER}3 = await _${ENTITY_NAME_LOWER}Manager.CreateAsync(
                "Inactive ${ENTITY_NAME}",
                "This is an inactive sample ${ENTITY_NAME}."
            );
            ${ENTITY_NAME_LOWER}3.Deactivate();
            await _${ENTITY_NAME_LOWER}Repository.InsertAsync(${ENTITY_NAME_LOWER}3);

            ${ADDITIONAL_SEED_DATA}
        }
    }
}

