using Volo.Abp.Application.Dtos;

namespace ${NAMESPACE}.Application.Contracts.${MODULE_NAME}.DTOs
{
    /// <summary>
    /// Input DTO for getting a list of ${ENTITY_NAME} entities.
    /// Supports filtering, sorting, and pagination.
    /// </summary>
    public class Get${ENTITY_NAME}ListInput : PagedAndSortedResultRequestDto
    {
        /// <summary>
        /// Gets or sets the filter text for searching ${ENTITY_NAME} entities.
        /// Searches across name and other relevant fields.
        /// </summary>
        public string? Filter { get; set; }

        /// <summary>
        /// Gets or sets a value to filter by active status.
        /// Null returns all entities, true returns only active, false returns only inactive.
        /// </summary>
        public bool? IsActive { get; set; }

        ${FILTER_PROPERTIES}

        /// <summary>
        /// Initializes a new instance of the <see cref="Get${ENTITY_NAME}ListInput"/> class.
        /// </summary>
        public Get${ENTITY_NAME}ListInput()
        {
            // Default sorting by name
            Sorting = "name";
            MaxResultCount = 10;
        }
    }
}

