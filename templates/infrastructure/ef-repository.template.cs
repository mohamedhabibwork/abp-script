using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;
using ${NAMESPACE}.Domain.${MODULE_NAME};

namespace ${NAMESPACE}.EntityFrameworkCore.${MODULE_NAME}.Repositories
{
    /// <summary>
    /// Entity Framework Core repository implementation for ${ENTITY_NAME}.
    /// Implements the Repository pattern with EF Core.
    /// </summary>
    public class EfCore${ENTITY_NAME}Repository : 
        EfCoreRepository<${DB_CONTEXT_NAME}, ${ENTITY_NAME}, ${ID_TYPE}>,
        I${ENTITY_NAME}Repository
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="EfCore${ENTITY_NAME}Repository"/> class.
        /// </summary>
        /// <param name="dbContextProvider">The database context provider.</param>
        public EfCore${ENTITY_NAME}Repository(
            IDbContextProvider<${DB_CONTEXT_NAME}> dbContextProvider)
            : base(dbContextProvider)
        {
        }

        /// <summary>
        /// Finds a ${ENTITY_NAME} by name.
        /// </summary>
        /// <param name="name">The name to search for.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>The ${ENTITY_NAME} if found; otherwise, null.</returns>
        public virtual async Task<${ENTITY_NAME}?> FindByNameAsync(
            string name,
            CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            return await dbSet
                .Where(x => x.Name == name)
                .FirstOrDefaultAsync(GetCancellationToken(cancellationToken));
        }

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
        public virtual async Task<List<${ENTITY_NAME}>> GetListAsync(
            int skipCount = 0,
            int maxResultCount = 10,
            string? sorting = null,
            string? filter = null,
            bool? isActive = null,
            CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            
            return await dbSet
                .WhereIf(
                    !string.IsNullOrWhiteSpace(filter),
                    x => x.Name.Contains(filter!) || 
                         (x.Description != null && x.Description.Contains(filter!))
                )
                .WhereIf(isActive.HasValue, x => x.IsActive == isActive!.Value)
                .OrderBy(sorting ?? nameof(${ENTITY_NAME}.Name))
                .Skip(skipCount)
                .Take(maxResultCount)
                .ToListAsync(GetCancellationToken(cancellationToken));
        }

        /// <summary>
        /// Gets the count of ${ENTITY_NAME} entities by filter.
        /// </summary>
        /// <param name="filter">Filter text.</param>
        /// <param name="isActive">Filter by active status.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>Count of ${ENTITY_NAME} entities.</returns>
        public virtual async Task<long> GetCountAsync(
            string? filter = null,
            bool? isActive = null,
            CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            
            return await dbSet
                .WhereIf(
                    !string.IsNullOrWhiteSpace(filter),
                    x => x.Name.Contains(filter!) || 
                         (x.Description != null && x.Description.Contains(filter!))
                )
                .WhereIf(isActive.HasValue, x => x.IsActive == isActive!.Value)
                .LongCountAsync(GetCancellationToken(cancellationToken));
        }

        /// <summary>
        /// Gets all active ${ENTITY_NAME} entities.
        /// </summary>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>List of active ${ENTITY_NAME} entities.</returns>
        public virtual async Task<List<${ENTITY_NAME}>> GetActiveListAsync(
            CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            
            return await dbSet
                .Where(x => x.IsActive)
                .OrderBy(x => x.Name)
                .ToListAsync(GetCancellationToken(cancellationToken));
        }

        /// <summary>
        /// Checks if a ${ENTITY_NAME} with the given name exists.
        /// </summary>
        /// <param name="name">The name to check.</param>
        /// <param name="excludeId">ID to exclude from the check (for updates).</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>True if exists; otherwise, false.</returns>
        public virtual async Task<bool> ExistsByNameAsync(
            string name,
            ${ID_TYPE}? excludeId = null,
            CancellationToken cancellationToken = default)
        {
            var dbSet = await GetDbSetAsync();
            
            return await dbSet
                .Where(x => x.Name == name)
                .WhereIf(excludeId.HasValue, x => x.Id != excludeId!.Value)
                .AnyAsync(GetCancellationToken(cancellationToken));
        }
    }
}

