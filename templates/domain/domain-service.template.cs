using System;
using System.Threading.Tasks;
using Volo.Abp;
using Volo.Abp.Domain.Services;

namespace ${NAMESPACE}.Domain.${MODULE_NAME}.Services
{
    /// <summary>
    /// Domain service for ${ENTITY_NAME} management.
    /// Implements business logic that doesn't naturally fit within the entity.
    /// </summary>
    public class ${ENTITY_NAME}Manager : DomainService
    {
        private readonly I${ENTITY_NAME}Repository _${ENTITY_NAME_LOWER}Repository;

        /// <summary>
        /// Initializes a new instance of the <see cref="${ENTITY_NAME}Manager"/> class.
        /// </summary>
        /// <param name="${ENTITY_NAME_LOWER}Repository">The ${ENTITY_NAME} repository.</param>
        public ${ENTITY_NAME}Manager(I${ENTITY_NAME}Repository ${ENTITY_NAME_LOWER}Repository)
        {
            _${ENTITY_NAME_LOWER}Repository = ${ENTITY_NAME_LOWER}Repository;
        }

        ${CREATE_METHOD}

        ${UPDATE_NAME_METHOD}

        /// <summary>
        /// Validates whether a ${ENTITY_NAME} can be deleted.
        /// </summary>
        /// <param name="entity">The ${ENTITY_NAME} to validate.</param>
        /// <returns>True if can be deleted; otherwise, false.</returns>
        public async Task<bool> CanDeleteAsync(${ENTITY_NAME} entity)
        {
            Check.NotNull(entity, nameof(entity));

            // Add business logic to check if entity can be deleted
            // For example, check if there are related entities

            return await Task.FromResult(true);
        }

        ${VALIDATE_ACTIVATION_METHOD}
    }
}

