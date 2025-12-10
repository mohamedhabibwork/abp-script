using System;

namespace ${NAMESPACE}.${MODULE_NAME}.Events
{
    /// <summary>
    /// Event Transfer Object for ${ENTITY_NAME}${EVENT_NAME} event.
    /// This is used for distributed event handling across microservices.
    /// </summary>
    [Serializable]
    public class ${ENTITY_NAME}${EVENT_NAME}Eto
    {
        /// <summary>
        /// Gets or sets the ID of the ${ENTITY_NAME}.
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// Gets or sets the name of the ${ENTITY_NAME}.
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the timestamp when the event occurred.
        /// </summary>
        public DateTime EventTime { get; set; }

        /// <summary>
        /// Gets or sets the tenant ID (for multi-tenant applications).
        /// </summary>
        public Guid? TenantId { get; set; }

        ${PROPERTIES}

        /// <summary>
        /// Initializes a new instance of the <see cref="${ENTITY_NAME}${EVENT_NAME}Eto"/> class.
        /// </summary>
        public ${ENTITY_NAME}${EVENT_NAME}Eto()
        {
            EventTime = DateTime.UtcNow;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="${ENTITY_NAME}${EVENT_NAME}Eto"/> class.
        /// </summary>
        /// <param name="id">The ${ENTITY_NAME} ID.</param>
        /// <param name="name">The ${ENTITY_NAME} name.</param>
        public ${ENTITY_NAME}${EVENT_NAME}Eto(Guid id, string name)
        {
            Id = id;
            Name = name;
            EventTime = DateTime.UtcNow;
        }
    }
}

