using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Volo.Abp;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Application.Services;
using Volo.Abp.Caching;
using Volo.Abp.Domain.Repositories;
using ${NAMESPACE}.Application.Contracts.${MODULE_NAME};
using ${NAMESPACE}.Application.Contracts.${MODULE_NAME}.DTOs;
using ${NAMESPACE}.Domain.${MODULE_NAME}.Constants;
using ${NAMESPACE}.Domain.${MODULE_NAME};
using ${NAMESPACE}.Domain.${MODULE_NAME}.Events;
using ${NAMESPACE}.Application.Contracts.${MODULE_NAME}.Permissions;
using static ${NAMESPACE}.Application.Contracts.${MODULE_NAME}.Permissions.${MODULE_NAME}Permissions;

namespace ${NAMESPACE}.Application.${MODULE_NAME}
{
    /// <summary>
    /// Application service for ${ENTITY_NAME} management with caching and distributed events.
    /// </summary>
    [RemoteService(false)]
    [Authorize(${ENTITY_NAME}Management.Default)]
    public class ${ENTITY_NAME}AppService : 
        CrudAppService<
            ${ENTITY_NAME},
            ${ENTITY_NAME}Dto,
            ${ID_TYPE},
            SearchedPagedAndSortedResultRequestDto,
            Create${ENTITY_NAME}Dto,
            Update${ENTITY_NAME}Dto>,
        I${ENTITY_NAME}AppService
    {
        private readonly IDistributedCache<${ENTITY_NAME}Dto> _cache;
        private readonly IDistributedCache<List<${ENTITY_NAME}Dto>> _listCache;

        public ${ENTITY_NAME}AppService(
            IRepository<${ENTITY_NAME}, ${ID_TYPE}> repository,
            IDistributedCache<${ENTITY_NAME}Dto> cache,
            IDistributedCache<List<${ENTITY_NAME}Dto>> listCache)
            : base(repository)
        {
            _cache = cache;
            _listCache = listCache;

            GetPolicyName = ${ENTITY_NAME}Management.Default;
            GetListPolicyName = ${ENTITY_NAME}Management.Default;
            CreatePolicyName = ${ENTITY_NAME}Management.Create;
            UpdatePolicyName = ${ENTITY_NAME}Management.Update;
            DeletePolicyName = ${ENTITY_NAME}Management.Delete;
        }

        /// <summary>
        /// Gets a ${ENTITY_NAME} by ID with caching.
        /// </summary>
        public override async Task<${ENTITY_NAME}Dto> GetAsync(${ID_TYPE} id)
        {
            var cacheKey = $"{${ENTITY_NAME}Constants.CacheKeys.SingleKey}:{id}";
            var cachedDto = await _cache.GetAsync(cacheKey);
            
            if (cachedDto != null)
            {
                return cachedDto;
            }

            var entity = await Repository.GetAsync(id);
            var dto = ObjectMapper.Map<${ENTITY_NAME}, ${ENTITY_NAME}Dto>(entity);
            
            await _cache.SetAsync(cacheKey, dto);
            
            return dto;
        }

        /// <summary>
        /// Gets a paginated list of ${ENTITY_NAME} entities with caching.
        /// </summary>
        public override async Task<PagedResultDto<${ENTITY_NAME}Dto>> GetListAsync(SearchedPagedAndSortedResultRequestDto input)
        {
            if (input.Sorting.IsNullOrWhiteSpace())
            {
                input.Sorting = ${ENTITY_NAME}Constants.DefaultSorting;
            }

            var result = await base.GetListAsync(input);

            foreach (var dto in result.Items)
            {
                var cacheKey = $"{${ENTITY_NAME}Constants.CacheKeys.SingleKey}:{dto.Id}";
                await _cache.SetAsync(cacheKey, dto);
            }

            return result;
        }

        /// <summary>
        /// Creates a new ${ENTITY_NAME} and publishes distributed event.
        /// </summary>
        [Authorize(${ENTITY_NAME}Management.Create)]
        public override async Task<${ENTITY_NAME}Dto> CreateAsync(Create${ENTITY_NAME}Dto input)
        {
            await CheckCreatePolicyAsync();

            var entity = await MapToEntityAsync(input);

            await Repository.InsertAsync(entity, autoSave: true);

            await _listCache.RemoveAsync(${ENTITY_NAME}Constants.CacheKeys.ListCacheKey);

${PUBLISH_CREATE_EVENT}
            
            return await MapToGetOutputDtoAsync(entity);
        }

        /// <summary>
        /// Updates an existing ${ENTITY_NAME} and publishes distributed event.
        /// </summary>
        [Authorize(${ENTITY_NAME}Management.Update)]
        public override async Task<${ENTITY_NAME}Dto> UpdateAsync(${ID_TYPE} id, Update${ENTITY_NAME}Dto input)
        {
            await CheckUpdatePolicyAsync();

            var entity = await GetEntityByIdAsync(id);

            await MapToEntityAsync(input, entity);
            await Repository.UpdateAsync(entity, autoSave: true);

            await _cache.RemoveAsync($"{${ENTITY_NAME}Constants.CacheKeys.SingleKey}:{id}");
            await _listCache.RemoveAsync(${ENTITY_NAME}Constants.CacheKeys.ListCacheKey);

${PUBLISH_UPDATE_EVENT}
            
            return await MapToGetOutputDtoAsync(entity);
        }

        /// <summary>
        /// Deletes a ${ENTITY_NAME} and clears cache.
        /// </summary>
        [Authorize(${ENTITY_NAME}Management.Delete)]
        public override async Task DeleteAsync(${ID_TYPE} id)
        {
            await CheckDeletePolicyAsync();

            await Repository.DeleteAsync(id);

            await _cache.RemoveAsync($"{${ENTITY_NAME}Constants.CacheKeys.SingleKey}:{id}");
            await _listCache.RemoveAsync(${ENTITY_NAME}Constants.CacheKeys.ListCacheKey);
        }

${APPLY_DEFAULT_SORTING}

        /// <summary>
        /// Creates filtered query with search support.
        /// </summary>
        protected override async Task<IQueryable<${ENTITY_NAME}>> CreateFilteredQueryAsync(SearchedPagedAndSortedResultRequestDto input)
        {
            var data = await base.CreateFilteredQueryAsync(input);
            
${SEARCH_FILTER_LOGIC}
            
            return data;
        }
    }
}

