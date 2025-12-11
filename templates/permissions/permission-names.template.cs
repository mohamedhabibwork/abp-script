namespace ${NAMESPACE}.Permissions
{
    /// <summary>
    /// Permission names for ${MODULE_NAME} module.
    /// Defines all permission constants for authorization.
    /// </summary>
    public static class ${MODULE_NAME}Permissions
    {
        public const string GroupName = "${MODULE_NAME}";

        /// <summary>
        /// Permission names for ${ENTITY_NAME} entity.
        /// </summary>
        public static class ${ENTITY_NAME_PLURAL}
        {
            public const string Default = GroupName + ".${ENTITY_NAME_PLURAL}";
            public const string Create = Default + ".Create";
            public const string Edit = Default + ".Edit";
            public const string Delete = Default + ".Delete";
        }

        ${ADDITIONAL_ENTITY_PERMISSIONS}
    }
}

