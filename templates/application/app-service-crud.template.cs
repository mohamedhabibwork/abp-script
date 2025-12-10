using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.EventBus.Distributed;

namespace ${NAMESPACE}.${MODULE_NAME}.Services
{
    /// <summary>
    /// Application service for ${ENTITY_NAME} management.
    /// Implements CRUD operations with full business logic.
    /// Follows Single Responsibility and Dependency Inversion principles.
    /// </summary>
    [Authorize(${MODULE_NAME}Permissions.${ENTITY_NAME_PLURAL}.Default)]
    public class ${ENTITY_NAME}AppService : ApplicationService, I${ENTITY_NAME}AppService
    {
        private readonly I${ENTITY_NAME}Repository _${ENTITY_NAME_LOWER}Repository;
        private readonly ${ENTITY_NAME}Manager _${ENTITY_NAME_LOWER}Manager;
        private readonly IDistributedEventBus _distributedEventBus;

        /// <summary>
        /// Initializes a new instance of the <see cref="${ENTITY_NAME}AppService"/> class.
        /// </summary>
        /// <param name="${ENTITY_NAME_LOWER}Repository">The ${ENTITY_NAME} repository.</param>
        /// <param name="${ENTITY_NAME_LOWER}Manager">The ${ENTITY_NAME} domain service.</param>
        /// <param name="distributedEventBus">The distributed event bus.</param>
        public ${ENTITY_NAME}AppService(
            I${ENTITY_NAME}Repository ${ENTITY_NAME_LOWER}Repository,
            ${ENTITY_NAME}Manager ${ENTITY_NAME_LOWER}Manager,
            IDistributedEventBus distributedEventBus)
        {
            _${ENTITY_NAME_LOWER}Repository = ${ENTITY_NAME_LOWER}Repository;
            _${ENTITY_NAME_LOWER}Manager = ${ENTITY_NAME_LOWER}Manager;
            _distributedEventBus = distributedEventBus;
        }

        /// <summary>
        /// Gets a ${ENTITY_NAME} by ID.
        /// </summary>
        /// <param name="id">The ${ENTITY_NAME} ID.</param>
        /// <returns>The ${ENTITY_NAME} DTO.</returns>
        [Authorize(${MODULE_NAME}Permissions.${ENTITY_NAME_PLURAL}.Default)]
        public virtual async Task<${ENTITY_NAME}Dto> GetAsync(Guid id)
        {
            var entity = await _${ENTITY_NAME_LOWER}Repository.GetAsync(id);
            return ObjectMapper.Map<${ENTITY_NAME}, ${ENTITY_NAME}Dto>(entity);
        }

        /// <summary>
        /// Gets a paginated list of ${ENTITY_NAME} entities.
        /// </summary>
        /// <param name="input">The list input parameters.</param>
        /// <returns>Paginated result of ${ENTITY_NAME} DTOs.</returns>
        [Authorize(${MODULE_NAME}Permissions.${ENTITY_NAME_PLURAL}.Default)]
        public virtual async Task<PagedResultDto<${ENTITY_NAME}Dto>> GetListAsync(Get${ENTITY_NAME}ListInput input)
        {
            var totalCount = await _${ENTITY_NAME_LOWER}Repository.GetCountAsync(
                input.Filter,
                input.IsActive
            );

            var items = await _${ENTITY_NAME_LOWER}Repository.GetListAsync(
                input.SkipCount,
                input.MaxResultCount,
                input.Sorting,
                input.Filter,
                input.IsActive
            );

            return new PagedResultDto<${ENTITY_NAME}Dto>(
                totalCount,
                ObjectMapper.Map<List<${ENTITY_NAME}>, List<${ENTITY_NAME}Dto>>(items)
            );
        }

        /// <summary>
        /// Creates a new ${ENTITY_NAME}.
        /// </summary>
        /// <param name="input">The create DTO.</param>
        /// <returns>The created ${ENTITY_NAME} DTO.</returns>
        [Authorize(${MODULE_NAME}Permissions.${ENTITY_NAME_PLURAL}.Create)]
        public virtual async Task<${ENTITY_NAME}Dto> CreateAsync(Create${ENTITY_NAME}Dto input)
        {
            // Use domain service for business logic
            var entity = await _${ENTITY_NAME_LOWER}Manager.CreateAsync(
                input.Name,
                input.Description
            );

            entity.IsActive = input.IsActive;

            // Save to repository
            var createdEntity = await _${ENTITY_NAME_LOWER}Repository.InsertAsync(entity, autoSave: true);

            // Publish distributed event
            await _distributedEventBus.PublishAsync(
                new ${ENTITY_NAME}CreatedEto(createdEntity.Id, createdEntity.Name)
                {
                    TenantId = CurrentTenant.Id
                }
            );

            return ObjectMapper.Map<${ENTITY_NAME}, ${ENTITY_NAME}Dto>(createdEntity);
        }

        /// <summary>
        /// Updates an existing ${ENTITY_NAME}.
        /// </summary>
        /// <param name="id">The ${ENTITY_NAME} ID.</param>
        /// <param name="input">The update DTO.</param>
        /// <returns>The updated ${ENTITY_NAME} DTO.</returns>
        [Authorize(${MODULE_NAME}Permissions.${ENTITY_NAME_PLURAL}.Edit)]
        public virtual async Task<${ENTITY_NAME}Dto> UpdateAsync(Guid id, Update${ENTITY_NAME}Dto input)
        {
            var entity = await _${ENTITY_NAME_LOWER}Repository.GetAsync(id);

            // Use domain service for name update with validation
            await _${ENTITY_NAME_LOWER}Manager.UpdateNameAsync(entity, input.Name);

            entity.SetDescription(input.Description);
            entity.IsActive = input.IsActive;

            // Save changes
            var updatedEntity = await _${ENTITY_NAME_LOWER}Repository.UpdateAsync(entity, autoSave: true);

            // Publish distributed event
            await _distributedEventBus.PublishAsync(
                new ${ENTITY_NAME}UpdatedEto(updatedEntity.Id, updatedEntity.Name)
                {
                    TenantId = CurrentTenant.Id
                }
            );

            return ObjectMapper.Map<${ENTITY_NAME}, ${ENTITY_NAME}Dto>(updatedEntity);
        }

        /// <summary>
        /// Deletes a ${ENTITY_NAME}.
        /// </summary>
        /// <param name="id">The ${ENTITY_NAME} ID.</param>
        [Authorize(${MODULE_NAME}Permissions.${ENTITY_NAME_PLURAL}.Delete)]
        public virtual async Task DeleteAsync(Guid id)
        {
            var entity = await _${ENTITY_NAME_LOWER}Repository.GetAsync(id);

            // Validate deletion using domain service
            var canDelete = await _${ENTITY_NAME_LOWER}Manager.CanDeleteAsync(entity);
            if (!canDelete)
            {
                throw new BusinessException(${MODULE_NAME}DomainErrorCodes.${ENTITY_NAME}CannotBeDeleted);
            }

            await _${ENTITY_NAME_LOWER}Repository.DeleteAsync(id, autoSave: true);

            // Publish distributed event
            await _distributedEventBus.PublishAsync(
                new ${ENTITY_NAME}DeletedEto(id, entity.Name)
                {
                    TenantId = CurrentTenant.Id
                }
            );
        }

        /// <summary>
        /// Gets a lookup list of ${ENTITY_NAME} entities (for dropdowns).
        /// </summary>
        /// <returns>List of ${ENTITY_NAME} lookup DTOs.</returns>
        [Authorize(${MODULE_NAME}Permissions.${ENTITY_NAME_PLURAL}.Default)]
        public virtual async Task<ListResultDto<${ENTITY_NAME}LookupDto>> GetLookupAsync()
        {
            var items = await _${ENTITY_NAME_LOWER}Repository.GetActiveListAsync();
            
            return new ListResultDto<${ENTITY_NAME}LookupDto>(
                ObjectMapper.Map<List<${ENTITY_NAME}>, List<${ENTITY_NAME}LookupDto>>(items)
            );
        }

        /// <summary>
        /// Activates a ${ENTITY_NAME}.
        /// </summary>
        /// <param name="id">The ${ENTITY_NAME} ID.</param>
        [Authorize(${MODULE_NAME}Permissions.${ENTITY_NAME_PLURAL}.Edit)]
        public virtual async Task ActivateAsync(Guid id)
        {
            var entity = await _${ENTITY_NAME_LOWER}Repository.GetAsync(id);

            // Validate activation using domain service
            await _${ENTITY_NAME_LOWER}Manager.ValidateActivationAsync(entity);

            entity.Activate();
            await _${ENTITY_NAME_LOWER}Repository.UpdateAsync(entity, autoSave: true);
        }

        /// <summary>
        /// Deactivates a ${ENTITY_NAME}.
        /// </summary>
        /// <param name="id">The ${ENTITY_NAME} ID.</param>
        [Authorize(${MODULE_NAME}Permissions.${ENTITY_NAME_PLURAL}.Edit)]
        public virtual async Task DeactivateAsync(Guid id)
        {
            var entity = await _${ENTITY_NAME_LOWER}Repository.GetAsync(id);
            entity.Deactivate();
            await _${ENTITY_NAME_LOWER}Repository.UpdateAsync(entity, autoSave: true);
        }
    }
}

