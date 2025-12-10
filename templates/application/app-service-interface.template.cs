using System;
using System.Threading.Tasks;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;

namespace ${NAMESPACE}.${MODULE_NAME}.Services
{
    /// <summary>
    /// Application service interface for ${ENTITY_NAME} management.
    /// Follows Interface Segregation Principle (ISP).
    /// </summary>
    public interface I${ENTITY_NAME}AppService : IApplicationService
    {
        /// <summary>
        /// Gets a ${ENTITY_NAME} by ID.
        /// </summary>
        /// <param name="id">The ${ENTITY_NAME} ID.</param>
        /// <returns>The ${ENTITY_NAME} DTO.</returns>
        Task<${ENTITY_NAME}Dto> GetAsync(Guid id);

        /// <summary>
        /// Gets a paginated list of ${ENTITY_NAME} entities.
        /// </summary>
        /// <param name="input">The list input parameters.</param>
        /// <returns>Paginated result of ${ENTITY_NAME} DTOs.</returns>
        Task<PagedResultDto<${ENTITY_NAME}Dto>> GetListAsync(Get${ENTITY_NAME}ListInput input);

        /// <summary>
        /// Creates a new ${ENTITY_NAME}.
        /// </summary>
        /// <param name="input">The create DTO.</param>
        /// <returns>The created ${ENTITY_NAME} DTO.</returns>
        Task<${ENTITY_NAME}Dto> CreateAsync(Create${ENTITY_NAME}Dto input);

        /// <summary>
        /// Updates an existing ${ENTITY_NAME}.
        /// </summary>
        /// <param name="id">The ${ENTITY_NAME} ID.</param>
        /// <param name="input">The update DTO.</param>
        /// <returns>The updated ${ENTITY_NAME} DTO.</returns>
        Task<${ENTITY_NAME}Dto> UpdateAsync(Guid id, Update${ENTITY_NAME}Dto input);

        /// <summary>
        /// Deletes a ${ENTITY_NAME}.
        /// </summary>
        /// <param name="id">The ${ENTITY_NAME} ID.</param>
        Task DeleteAsync(Guid id);

        /// <summary>
        /// Gets a lookup list of ${ENTITY_NAME} entities (for dropdowns).
        /// </summary>
        /// <returns>List of ${ENTITY_NAME} lookup DTOs.</returns>
        Task<ListResultDto<${ENTITY_NAME}LookupDto>> GetLookupAsync();

        /// <summary>
        /// Activates a ${ENTITY_NAME}.
        /// </summary>
        /// <param name="id">The ${ENTITY_NAME} ID.</param>
        Task ActivateAsync(Guid id);

        /// <summary>
        /// Deactivates a ${ENTITY_NAME}.
        /// </summary>
        /// <param name="id">The ${ENTITY_NAME} ID.</param>
        Task DeactivateAsync(Guid id);
    }
}

