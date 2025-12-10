using System;
using Volo.Abp.Domain.Entities.Auditing;

namespace ${NAMESPACE}.${MODULE_NAME}.Entities
{
    /// <summary>
    /// Represents a ${ENTITY_NAME} entity.
    /// </summary>
    public class ${ENTITY_NAME} : FullAuditedAggregateRoot<Guid>
    {
        /// <summary>
        /// Gets or sets the name of the ${ENTITY_NAME}.
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the description of the ${ENTITY_NAME}.
        /// </summary>
        public string? Description { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether this ${ENTITY_NAME} is active.
        /// </summary>
        public bool IsActive { get; set; }

        ${PROPERTIES}

        // Navigation Properties
        ${RELATIONSHIPS}

        /// <summary>
        /// Private constructor for ORM.
        /// </summary>
        protected ${ENTITY_NAME}()
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="${ENTITY_NAME}"/> class.
        /// </summary>
        /// <param name="id">The unique identifier.</param>
        /// <param name="name">The name.</param>
        public ${ENTITY_NAME}(Guid id, string name) : base(id)
        {
            SetName(name);
            IsActive = true;
        }

        /// <summary>
        /// Sets the name with validation.
        /// </summary>
        /// <param name="name">The name to set.</param>
        /// <exception cref="ArgumentNullException">Thrown when name is null or empty.</exception>
        public ${ENTITY_NAME} SetName(string name)
        {
            Name = Check.NotNullOrWhiteSpace(name, nameof(name), ${ENTITY_NAME}Consts.MaxNameLength);
            return this;
        }

        /// <summary>
        /// Sets the description.
        /// </summary>
        /// <param name="description">The description to set.</param>
        public ${ENTITY_NAME} SetDescription(string? description)
        {
            Description = description;
            return this;
        }

        /// <summary>
        /// Activates the ${ENTITY_NAME}.
        /// </summary>
        public void Activate()
        {
            IsActive = true;
        }

        /// <summary>
        /// Deactivates the ${ENTITY_NAME}.
        /// </summary>
        public void Deactivate()
        {
            IsActive = false;
        }
    }
}

