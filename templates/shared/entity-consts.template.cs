namespace ${NAMESPACE}.${MODULE_NAME}.Constants
{
    /// <summary>
    /// Constants for ${ENTITY_NAME} entity.
    /// </summary>
    public static class ${ENTITY_NAME}Constants
    {
        /// <summary>
        /// Default sorting for ${ENTITY_NAME} queries.
        /// </summary>
        public const string DefaultSorting = "CreationTime desc";
        
        /// <summary>
        /// Cache keys for ${ENTITY_NAME} caching.
        /// </summary>
        public static class CacheKeys
        {
            /// <summary>
            /// Cache key for all ${ENTITY_NAME} list.
            /// </summary>
            public const string ListCacheKey = "All${ENTITY_NAME}List";
            
            /// <summary>
            /// Cache key prefix for single ${ENTITY_NAME}.
            /// </summary>
            public const string SingleKey = "${ENTITY_NAME}";
        }

        /// <summary>
        /// Validation constants for ${ENTITY_NAME} properties.
        /// </summary>
        public static class ValidationConstants
        {
${VALIDATION_CONSTANTS}
        }
    }
}
