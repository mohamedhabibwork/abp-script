using System;
using Volo.Abp.Application.Dtos;

namespace ${NAMESPACE}.Application.Contracts.${MODULE_NAME}.DTOs
{
    /// <summary>
    /// Lookup DTO for ${ENTITY_NAME}.
    /// Used in dropdowns and selection lists.
    /// </summary>
    public class ${ENTITY_NAME}LookupDto : EntityDto<Guid>
    {
        /// <summary>
        /// Gets or sets the name of the ${ENTITY_NAME}.
        /// </summary>
        public string Name { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets a value indicating whether this ${ENTITY_NAME} is active.
        /// </summary>
        public bool IsActive { get; set; }
    }
}

