using System;
using Volo.Abp.Application.Dtos;

namespace ${NAMESPACE}.Application.Contracts.${MODULE_NAME}.DTOs
{
    /// <summary>
    /// DTO representing a ${ENTITY_NAME} entity.
    /// </summary>
    public class ${ENTITY_NAME}Dto : FullAuditedEntityDto<Guid>
    {
        /// <summary>
        /// Gets or sets the name of the ${ENTITY_NAME}.
        /// </summary>
        public string Name { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the description of the ${ENTITY_NAME}.
        /// </summary>
        public string? Description { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether this ${ENTITY_NAME} is active.
        /// </summary>
        public bool IsActive { get; set; }

        ${PROPERTIES}
    }
}

