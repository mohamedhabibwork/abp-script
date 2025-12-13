using Volo.Abp.Reflection;

namespace ${NAMESPACE}.Application.Contracts.${MODULE_NAME}.Permissions
{
    /// <summary>
    /// Permission names for ${MODULE_NAME} module.
    /// Organized hierarchically for easy management.
    /// </summary>
    public static class ${MODULE_NAME}Permissions
    {
        /// <summary>
        /// Gets the group name for ${MODULE_NAME} permissions.
        /// </summary>
        public const string GroupName = "${MODULE_NAME}";

        /// <summary>
        /// Permission names for ${ENTITY_NAME} management.
        /// </summary>
        public static class ${ENTITY_NAME}Management
        {
            /// <summary>
            /// Default permission for viewing ${ENTITY_NAME}.
            /// </summary>
            public const string Default = GroupName + ".${ENTITY_NAME}";

            /// <summary>
            /// Permission for creating ${ENTITY_NAME}.
            /// </summary>
            public const string Create = Default + ".Create";

            /// <summary>
            /// Permission for updating ${ENTITY_NAME}.
            /// </summary>
            public const string Update = Default + ".Update";

            /// <summary>
            /// Permission for deleting ${ENTITY_NAME}.
            /// </summary>
            public const string Delete = Default + ".Delete";
        }

        ${ADDITIONAL_PERMISSION_CLASSES}

        /// <summary>
        /// Gets all permission names defined in this class.
        /// </summary>
        /// <returns>Array of all permission names.</returns>
        public static string[] GetAll()
        {
            return ReflectionHelper.GetPublicConstantsRecursively(typeof(${MODULE_NAME}Permissions));
        }
    }
}

