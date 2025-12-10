using System;
using System.Threading.Tasks;
using Volo.Abp;
using Volo.Abp.Domain.Services;

namespace ${NAMESPACE}.${MODULE_NAME}.DomainServices
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

        /// <summary>
        /// Creates a new ${ENTITY_NAME} with validation.
        /// </summary>
        /// <param name="name">The name of the ${ENTITY_NAME}.</param>
        /// <param name="description">The description.</param>
        /// <returns>The created ${ENTITY_NAME}.</returns>
        /// <exception cref="BusinessException">Thrown when a ${ENTITY_NAME} with the same name already exists.</exception>
        public async Task<${ENTITY_NAME}> CreateAsync(string name, string? description = null)
        {
            Check.NotNullOrWhiteSpace(name, nameof(name));

            // Check for duplicate name
            var existingEntity = await _${ENTITY_NAME_LOWER}Repository.FindByNameAsync(name);
            if (existingEntity != null)
            {
                throw new BusinessException(${MODULE_NAME}DomainErrorCodes.${ENTITY_NAME}AlreadyExists)
                    .WithData("name", name);
            }

            var entity = new ${ENTITY_NAME}(
                GuidGenerator.Create(),
                name
            );

            if (!string.IsNullOrWhiteSpace(description))
            {
                entity.SetDescription(description);
            }

            return entity;
        }

        /// <summary>
        /// Updates the name of a ${ENTITY_NAME} with validation.
        /// </summary>
        /// <param name="entity">The ${ENTITY_NAME} to update.</param>
        /// <param name="newName">The new name.</param>
        /// <exception cref="BusinessException">Thrown when a ${ENTITY_NAME} with the same name already exists.</exception>
        public async Task UpdateNameAsync(${ENTITY_NAME} entity, string newName)
        {
            Check.NotNull(entity, nameof(entity));
            Check.NotNullOrWhiteSpace(newName, nameof(newName));

            if (entity.Name == newName)
            {
                return;
            }

            var existingEntity = await _${ENTITY_NAME_LOWER}Repository.FindByNameAsync(newName);
            if (existingEntity != null && existingEntity.Id != entity.Id)
            {
                throw new BusinessException(${MODULE_NAME}DomainErrorCodes.${ENTITY_NAME}AlreadyExists)
                    .WithData("name", newName);
            }

            entity.SetName(newName);
        }

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

        /// <summary>
        /// Performs business validation before activating a ${ENTITY_NAME}.
        /// </summary>
        /// <param name="entity">The ${ENTITY_NAME} to activate.</param>
        /// <exception cref="BusinessException">Thrown when validation fails.</exception>
        public async Task ValidateActivationAsync(${ENTITY_NAME} entity)
        {
            Check.NotNull(entity, nameof(entity));

            // Add business rules for activation
            // For example, check if all required fields are filled

            await Task.CompletedTask;
        }
    }
}

