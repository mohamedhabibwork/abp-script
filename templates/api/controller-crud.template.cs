using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Volo.Abp;
using Volo.Abp.Application.Dtos;
using Volo.Abp.AspNetCore.Mvc;

namespace ${NAMESPACE}.${MODULE_NAME}.Controllers
{
    /// <summary>
    /// REST API controller for ${ENTITY_NAME} management.
    /// Implements RESTful conventions with proper HTTP verbs and status codes.
    /// Follows Controller pattern with dependency on application service.
    /// </summary>
    [Area("${MODULE_NAME_LOWER}")]
    [RemoteService(Name = "${MODULE_NAME}")]
    [Route("api/${MODULE_NAME_LOWER}/${ENTITY_NAME_LOWER_PLURAL}")]
    public class ${ENTITY_NAME}Controller : AbpController
    {
        private readonly I${ENTITY_NAME}AppService _${ENTITY_NAME_LOWER}AppService;

        /// <summary>
        /// Initializes a new instance of the <see cref="${ENTITY_NAME}Controller"/> class.
        /// </summary>
        /// <param name="${ENTITY_NAME_LOWER}AppService">The ${ENTITY_NAME} application service.</param>
        public ${ENTITY_NAME}Controller(I${ENTITY_NAME}AppService ${ENTITY_NAME_LOWER}AppService)
        {
            _${ENTITY_NAME_LOWER}AppService = ${ENTITY_NAME_LOWER}AppService;
        }

        /// <summary>
        /// Gets a ${ENTITY_NAME} by ID.
        /// </summary>
        /// <param name="id">The ${ENTITY_NAME} ID.</param>
        /// <returns>The ${ENTITY_NAME} DTO.</returns>
        /// <response code="200">Returns the ${ENTITY_NAME}.</response>
        /// <response code="404">If the ${ENTITY_NAME} is not found.</response>
        [HttpGet("{id}")]
        [ProducesResponseType(typeof(${ENTITY_NAME}Dto), 200)]
        [ProducesResponseType(404)]
        public virtual async Task<${ENTITY_NAME}Dto> GetAsync(Guid id)
        {
            return await _${ENTITY_NAME_LOWER}AppService.GetAsync(id);
        }

        /// <summary>
        /// Gets a paginated list of ${ENTITY_NAME} entities.
        /// </summary>
        /// <param name="input">The list input parameters.</param>
        /// <returns>Paginated result of ${ENTITY_NAME} DTOs.</returns>
        /// <response code="200">Returns the list of ${ENTITY_NAME_PLURAL}.</response>
        [HttpGet]
        [ProducesResponseType(typeof(PagedResultDto<${ENTITY_NAME}Dto>), 200)]
        public virtual async Task<PagedResultDto<${ENTITY_NAME}Dto>> GetListAsync([FromQuery] Get${ENTITY_NAME}ListInput input)
        {
            return await _${ENTITY_NAME_LOWER}AppService.GetListAsync(input);
        }

        /// <summary>
        /// Creates a new ${ENTITY_NAME}.
        /// </summary>
        /// <param name="input">The create DTO.</param>
        /// <returns>The created ${ENTITY_NAME} DTO.</returns>
        /// <response code="201">Returns the newly created ${ENTITY_NAME}.</response>
        /// <response code="400">If the input is invalid.</response>
        [HttpPost]
        [ProducesResponseType(typeof(${ENTITY_NAME}Dto), 201)]
        [ProducesResponseType(400)]
        public virtual async Task<${ENTITY_NAME}Dto> CreateAsync([FromBody] Create${ENTITY_NAME}Dto input)
        {
            var result = await _${ENTITY_NAME_LOWER}AppService.CreateAsync(input);
            return result;
        }

        /// <summary>
        /// Updates an existing ${ENTITY_NAME}.
        /// </summary>
        /// <param name="id">The ${ENTITY_NAME} ID.</param>
        /// <param name="input">The update DTO.</param>
        /// <returns>The updated ${ENTITY_NAME} DTO.</returns>
        /// <response code="200">Returns the updated ${ENTITY_NAME}.</response>
        /// <response code="400">If the input is invalid.</response>
        /// <response code="404">If the ${ENTITY_NAME} is not found.</response>
        [HttpPut("{id}")]
        [ProducesResponseType(typeof(${ENTITY_NAME}Dto), 200)]
        [ProducesResponseType(400)]
        [ProducesResponseType(404)]
        public virtual async Task<${ENTITY_NAME}Dto> UpdateAsync(Guid id, [FromBody] Update${ENTITY_NAME}Dto input)
        {
            return await _${ENTITY_NAME_LOWER}AppService.UpdateAsync(id, input);
        }

        /// <summary>
        /// Deletes a ${ENTITY_NAME}.
        /// </summary>
        /// <param name="id">The ${ENTITY_NAME} ID.</param>
        /// <response code="204">If the ${ENTITY_NAME} was successfully deleted.</response>
        /// <response code="404">If the ${ENTITY_NAME} is not found.</response>
        [HttpDelete("{id}")]
        [ProducesResponseType(204)]
        [ProducesResponseType(404)]
        public virtual async Task DeleteAsync(Guid id)
        {
            await _${ENTITY_NAME_LOWER}AppService.DeleteAsync(id);
        }

        /// <summary>
        /// Gets a lookup list of ${ENTITY_NAME} entities (for dropdowns).
        /// </summary>
        /// <returns>List of ${ENTITY_NAME} lookup DTOs.</returns>
        /// <response code="200">Returns the lookup list.</response>
        [HttpGet("lookup")]
        [ProducesResponseType(typeof(ListResultDto<${ENTITY_NAME}LookupDto>), 200)]
        public virtual async Task<ListResultDto<${ENTITY_NAME}LookupDto>> GetLookupAsync()
        {
            return await _${ENTITY_NAME_LOWER}AppService.GetLookupAsync();
        }

        /// <summary>
        /// Activates a ${ENTITY_NAME}.
        /// </summary>
        /// <param name="id">The ${ENTITY_NAME} ID.</param>
        /// <response code="204">If the ${ENTITY_NAME} was successfully activated.</response>
        /// <response code="404">If the ${ENTITY_NAME} is not found.</response>
        [HttpPost("{id}/activate")]
        [ProducesResponseType(204)]
        [ProducesResponseType(404)]
        public virtual async Task ActivateAsync(Guid id)
        {
            await _${ENTITY_NAME_LOWER}AppService.ActivateAsync(id);
        }

        /// <summary>
        /// Deactivates a ${ENTITY_NAME}.
        /// </summary>
        /// <param name="id">The ${ENTITY_NAME} ID.</param>
        /// <response code="204">If the ${ENTITY_NAME} was successfully deactivated.</response>
        /// <response code="404">If the ${ENTITY_NAME} is not found.</response>
        [HttpPost("{id}/deactivate")]
        [ProducesResponseType(204)]
        [ProducesResponseType(404)]
        public virtual async Task DeactivateAsync(Guid id)
        {
            await _${ENTITY_NAME_LOWER}AppService.DeactivateAsync(id);
        }
    }
}

