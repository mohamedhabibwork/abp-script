using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Volo.Abp.Domain.Repositories;

namespace ${NAMESPACE}.${MODULE_NAME}.Repositories
{
    /// <summary>
    /// Repository interface for <see cref="${ENTITY_NAME}"/>.
    /// </summary>
    public interface I${ENTITY_NAME}Repository : IRepository<${ENTITY_NAME}, Guid>
    {
        /// <summary>
        /// Finds a ${ENTITY_NAME} by name.
        /// </summary>
        /// <param name="name">The name to search for.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>The ${ENTITY_NAME} if found; otherwise, null.</returns>
        Task<${ENTITY_NAME}?> FindByNameAsync(
            string name,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Gets a list of ${ENTITY_NAME} entities by filter.
        /// </summary>
        /// <param name="skipCount">Number of items to skip.</param>
        /// <param name="maxResultCount">Maximum number of items to return.</param>
        /// <param name="sorting">Sorting expression.</param>
        /// <param name="filter">Filter text.</param>
        /// <param name="isActive">Filter by active status.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>List of ${ENTITY_NAME} entities.</returns>
        Task<List<${ENTITY_NAME}>> GetListAsync(
            int skipCount = 0,
            int maxResultCount = 10,
            string? sorting = null,
            string? filter = null,
            bool? isActive = null,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Gets the count of ${ENTITY_NAME} entities by filter.
        /// </summary>
        /// <param name="filter">Filter text.</param>
        /// <param name="isActive">Filter by active status.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>Count of ${ENTITY_NAME} entities.</returns>
        Task<long> GetCountAsync(
            string? filter = null,
            bool? isActive = null,
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Gets all active ${ENTITY_NAME} entities.
        /// </summary>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>List of active ${ENTITY_NAME} entities.</returns>
        Task<List<${ENTITY_NAME}>> GetActiveListAsync(
            CancellationToken cancellationToken = default);

        /// <summary>
        /// Checks if a ${ENTITY_NAME} with the given name exists.
        /// </summary>
        /// <param name="name">The name to check.</param>
        /// <param name="excludeId">ID to exclude from the check (for updates).</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>True if exists; otherwise, false.</returns>
        Task<bool> ExistsByNameAsync(
            string name,
            Guid? excludeId = null,
            CancellationToken cancellationToken = default);
    }
}

