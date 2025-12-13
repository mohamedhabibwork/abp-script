using System;
using Volo.Abp.Application.Dtos;

namespace ${NAMESPACE}.Application.Contracts.${MODULE_NAME}.DTOs
{
    /// <summary>
    /// DTO representing a ${ENTITY_NAME} entity.
    /// </summary>
    public class ${ENTITY_NAME}Dto : AuditedEntityDto<${ID_TYPE}>
    {
        ${PROPERTIES}
        ${FOREIGN_KEY_NAMES}
    }
}

