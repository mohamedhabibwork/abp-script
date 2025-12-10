using System;

namespace ${NAMESPACE}.${MODULE_NAME}.Events
{
    /// <summary>
    /// Domain event for ${ENTITY_NAME}${EVENT_NAME}.
    /// This is a local event that is raised within the domain layer.
    /// </summary>
    public class ${ENTITY_NAME}${EVENT_NAME}Event
    {
        /// <summary>
        /// Gets or sets the ID of the ${ENTITY_NAME}.
        /// </summary>
        public Guid ${ENTITY_NAME}Id { get; set; }

        /// <summary>
        /// Gets or sets the timestamp when the event occurred.
        /// </summary>
        public DateTime EventTime { get; set; }

        ${PROPERTIES}

        /// <summary>
        /// Initializes a new instance of the <see cref="${ENTITY_NAME}${EVENT_NAME}Event"/> class.
        /// </summary>
        public ${ENTITY_NAME}${EVENT_NAME}Event()
        {
            EventTime = DateTime.UtcNow;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="${ENTITY_NAME}${EVENT_NAME}Event"/> class.
        /// </summary>
        /// <param name="${ENTITY_NAME_LOWER}Id">The ${ENTITY_NAME} ID.</param>
        public ${ENTITY_NAME}${EVENT_NAME}Event(Guid ${ENTITY_NAME_LOWER}Id)
        {
            ${ENTITY_NAME}Id = ${ENTITY_NAME_LOWER}Id;
            EventTime = DateTime.UtcNow;
        }
    }
}

