using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using Volo.Abp.Domain.Entities.Auditing;

namespace ${NAMESPACE}.${MODULE_NAME}.Entities
{
    /// <summary>
    /// Represents a ${ENTITY_NAME} aggregate root.
    /// </summary>
    public class ${ENTITY_NAME} : FullAuditedAggregateRoot<Guid>
    {
        /// <summary>
        /// Gets or sets the name of the ${ENTITY_NAME}.
        /// </summary>
        public string Name { get; private set; }

        /// <summary>
        /// Gets or sets the description of the ${ENTITY_NAME}.
        /// </summary>
        public string? Description { get; private set; }

        /// <summary>
        /// Gets or sets a value indicating whether this ${ENTITY_NAME} is active.
        /// </summary>
        public bool IsActive { get; private set; }

        ${PROPERTIES}

        /// <summary>
        /// Gets the collection of related items.
        /// </summary>
        private readonly Collection<${ENTITY_NAME}Item> _items;
        public virtual IReadOnlyCollection<${ENTITY_NAME}Item> Items => _items;

        /// <summary>
        /// Private constructor for ORM.
        /// </summary>
        protected ${ENTITY_NAME}()
        {
            _items = new Collection<${ENTITY_NAME}Item>();
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
            _items = new Collection<${ENTITY_NAME}Item>();
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
            if (IsActive)
            {
                return;
            }

            IsActive = true;
            AddLocalEvent(new ${ENTITY_NAME}ActivatedEvent(Id));
        }

        /// <summary>
        /// Deactivates the ${ENTITY_NAME}.
        /// </summary>
        public void Deactivate()
        {
            if (!IsActive)
            {
                return;
            }

            IsActive = false;
            AddLocalEvent(new ${ENTITY_NAME}DeactivatedEvent(Id));
        }

        /// <summary>
        /// Adds an item to the ${ENTITY_NAME}.
        /// </summary>
        /// <param name="item">The item to add.</param>
        public void AddItem(${ENTITY_NAME}Item item)
        {
            Check.NotNull(item, nameof(item));
            _items.Add(item);
        }

        /// <summary>
        /// Removes an item from the ${ENTITY_NAME}.
        /// </summary>
        /// <param name="itemId">The ID of the item to remove.</param>
        public void RemoveItem(Guid itemId)
        {
            var item = _items.FirstOrDefault(x => x.Id == itemId);
            if (item != null)
            {
                _items.Remove(item);
            }
        }
    }
}

