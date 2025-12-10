namespace ${NAMESPACE}.${MODULE_NAME}.Permissions
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
        public static class ${ENTITY_NAME_PLURAL}
        {
            /// <summary>
            /// Default permission for viewing ${ENTITY_NAME_PLURAL}.
            /// </summary>
            public const string Default = GroupName + ".${ENTITY_NAME_PLURAL}";

            /// <summary>
            /// Permission for creating ${ENTITY_NAME_PLURAL}.
            /// </summary>
            public const string Create = Default + ".Create";

            /// <summary>
            /// Permission for editing ${ENTITY_NAME_PLURAL}.
            /// </summary>
            public const string Edit = Default + ".Edit";

            /// <summary>
            /// Permission for deleting ${ENTITY_NAME_PLURAL}.
            /// </summary>
            public const string Delete = Default + ".Delete";
        }

        ${ADDITIONAL_PERMISSION_CLASSES}
    }
}

