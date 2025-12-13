using ${NAMESPACE}.Domain.${MODULE_NAME}.Localization;
using Volo.Abp.Authorization.Permissions;
using Volo.Abp.Localization;
using ${NAMESPACE}.Application.Contracts.${MODULE_NAME}.Permissions;

namespace ${NAMESPACE}.${MODULE_NAME}.Permissions
{
    /// <summary>
    /// Permission definition provider for ${MODULE_NAME} module.
    /// Defines all permissions and their localization keys.
    /// </summary>
    public class ${MODULE_NAME}PermissionDefinitionProvider : PermissionDefinitionProvider
    {
        private static LocalizableString L(string name)
        {
            return LocalizableString.Create<${MODULE_NAME}Resource>(name);
        }

        public override void Define(IPermissionDefinitionContext context)
        {
            var ${MODULE_NAME_LOWER}Group = context.AddGroup(${MODULE_NAME}Permissions.GroupName, L("Permission:${MODULE_NAME}"));

            // ${ENTITY_NAME} permissions
            var ${ENTITY_NAME_LOWER}Permission = ${MODULE_NAME_LOWER}Group.AddPermission(
                ${MODULE_NAME}Permissions.${ENTITY_NAME}Management.Default, 
                L("Permission:${ENTITY_NAME}"));
            ${ENTITY_NAME_LOWER}Permission.AddChild(
                ${MODULE_NAME}Permissions.${ENTITY_NAME}Management.Create, 
                L("Permission:${ENTITY_NAME}.Create"));
            ${ENTITY_NAME_LOWER}Permission.AddChild(
                ${MODULE_NAME}Permissions.${ENTITY_NAME}Management.Update, 
                L("Permission:${ENTITY_NAME}.Update"));
            ${ENTITY_NAME_LOWER}Permission.AddChild(
                ${MODULE_NAME}Permissions.${ENTITY_NAME}Management.Delete, 
                L("Permission:${ENTITY_NAME}.Delete"));

            ${ADDITIONAL_PERMISSION_DEFINITIONS}
        }
    }
}

