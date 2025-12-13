using System;
using Volo.Abp.Domain.Entities;
using Volo.Abp.Domain.Entities.Auditing;
${DATA_ANNOTATIONS_USING}
${SOFT_DELETE_USING}
using ${NAMESPACE}.Domain.${MODULE_NAME}.Events;
using ${NAMESPACE}.Domain.${MODULE_NAME}.Constants;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace ${NAMESPACE}.Domain.${MODULE_NAME}
{
    /// <summary>
    /// Represents a ${ENTITY_NAME} entity.
    /// </summary>
    public class ${ENTITY_NAME} : ${BASE_CLASS}
    {
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
        ${CONSTRUCTOR_PARAMS}
        public ${ENTITY_NAME}(${ID_TYPE} id${CONSTRUCTOR_SIGNATURE})${BASE_CLASS_CONSTRUCTOR}
        {
            ${ID_ASSIGNMENT}${PROPERTY_SETTERS}
        }

        ${SETTER_METHODS}

        ${PUBLISH_EVENT_METHOD}

        ${VALUE_OBJECT_METHODS}

        /// <summary>
        /// Updates the ${ENTITY_NAME} with new values.
        /// </summary>
        ${UPDATE_METHOD_PARAMS}
        public void Update(${UPDATE_METHOD_SIGNATURE})
        {
            ${UPDATE_SETTERS}
        }
    }
}

