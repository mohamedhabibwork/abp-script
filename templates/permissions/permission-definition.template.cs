using Volo.Abp.Authorization.Permissions;
using Volo.Abp.Localization;

namespace ${NAMESPACE}.${MODULE_NAME}.Permissions
{
    /// <summary>
    /// Permission definition provider for ${MODULE_NAME} module.
    /// Defines hierarchical permissions following security best practices.
    /// </summary>
    public class ${MODULE_NAME}PermissionDefinitionProvider : PermissionDefinitionProvider
    {
        /// <summary>
        /// Defines the permissions for the ${MODULE_NAME} module.
        /// </summary>
        /// <param name="context">The permission definition context.</param>
        public override void Define(IPermissionDefinitionContext context)
        {
            var ${MODULE_NAME_LOWER}Group = context.AddGroup(
                ${MODULE_NAME}Permissions.GroupName,
                L("Permission:${MODULE_NAME}")
            );

            // ${ENTITY_NAME} permissions
            var ${ENTITY_NAME_LOWER}Permission = ${MODULE_NAME_LOWER}Group.AddPermission(
                ${MODULE_NAME}Permissions.${ENTITY_NAME_PLURAL}.Default,
                L("Permission:${ENTITY_NAME_PLURAL}")
            );

            ${ENTITY_NAME_LOWER}Permission.AddChild(
                ${MODULE_NAME}Permissions.${ENTITY_NAME_PLURAL}.Create,
                L("Permission:${ENTITY_NAME_PLURAL}.Create")
            );

            ${ENTITY_NAME_LOWER}Permission.AddChild(
                ${MODULE_NAME}Permissions.${ENTITY_NAME_PLURAL}.Edit,
                L("Permission:${ENTITY_NAME_PLURAL}.Edit")
            );

            ${ENTITY_NAME_LOWER}Permission.AddChild(
                ${MODULE_NAME}Permissions.${ENTITY_NAME_PLURAL}.Delete,
                L("Permission:${ENTITY_NAME_PLURAL}.Delete")
            );

            ${ADDITIONAL_PERMISSIONS}
        }

        private static LocalizableString L(string name)
        {
            return LocalizableString.Create<${MODULE_NAME}Resource>(name);
        }
    }
}

