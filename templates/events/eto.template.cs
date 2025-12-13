using System;
using Volo.Abp.Domain.Entities.Events.Distributed;

namespace ${NAMESPACE}.Domain.${MODULE_NAME}.Events
{
    /// <summary>
    /// Event Transfer Object for ${ENTITY_NAME}.
    /// This is used for distributed event handling across microservices.
    /// </summary>
    [Serializable]
    public class ${ENTITY_NAME}Eto : EtoBase
    {
        /// <summary>
        /// Gets or sets the ID of the ${ENTITY_NAME}.
        /// </summary>
        public ${ID_TYPE} Id { get; set; }

        ${PROPERTIES}
        ${FOREIGN_KEY_NAMES}

        /// <summary>
        /// Gets or sets the creation time.
        /// </summary>
        public DateTime CreationTime { get; set; }

        /// <summary>
        /// Gets or sets the last modification time.
        /// </summary>
        public DateTime? LastModificationTime { get; set; }
    }
}

