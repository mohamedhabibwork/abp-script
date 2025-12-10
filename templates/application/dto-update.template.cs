using System;
using System.ComponentModel.DataAnnotations;

namespace ${NAMESPACE}.${MODULE_NAME}.DTOs
{
    /// <summary>
    /// DTO for updating an existing ${ENTITY_NAME}.
    /// </summary>
    public class Update${ENTITY_NAME}Dto
    {
        /// <summary>
        /// Gets or sets the name of the ${ENTITY_NAME}.
        /// </summary>
        [Required]
        [StringLength(${ENTITY_NAME}Consts.MaxNameLength, MinimumLength = ${ENTITY_NAME}Consts.MinNameLength)]
        public string Name { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the description of the ${ENTITY_NAME}.
        /// </summary>
        [StringLength(${ENTITY_NAME}Consts.MaxDescriptionLength)]
        public string? Description { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether this ${ENTITY_NAME} is active.
        /// </summary>
        public bool IsActive { get; set; }

        ${PROPERTIES}
    }
}

