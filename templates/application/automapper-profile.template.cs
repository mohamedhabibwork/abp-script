using AutoMapper;

namespace ${NAMESPACE}.${MODULE_NAME}
{
    /// <summary>
    /// AutoMapper profile for ${MODULE_NAME} module.
    /// Configures entity-to-DTO mappings following the mapping pattern.
    /// </summary>
    public class ${MODULE_NAME}ApplicationAutoMapperProfile : Profile
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="${MODULE_NAME}ApplicationAutoMapperProfile"/> class.
        /// </summary>
        public ${MODULE_NAME}ApplicationAutoMapperProfile()
        {
            // ${ENTITY_NAME} mappings
            CreateMap<${ENTITY_NAME}, ${ENTITY_NAME}Dto>();
            CreateMap<${ENTITY_NAME}, ${ENTITY_NAME}LookupDto>();
            CreateMap<Create${ENTITY_NAME}Dto, ${ENTITY_NAME}>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.ExtraProperties, opt => opt.Ignore())
                .ForMember(dest => dest.ConcurrencyStamp, opt => opt.Ignore())
                .ForMember(dest => dest.CreationTime, opt => opt.Ignore())
                .ForMember(dest => dest.CreatorId, opt => opt.Ignore())
                .ForMember(dest => dest.LastModificationTime, opt => opt.Ignore())
                .ForMember(dest => dest.LastModifierId, opt => opt.Ignore())
                .ForMember(dest => dest.IsDeleted, opt => opt.Ignore())
                .ForMember(dest => dest.DeleterId, opt => opt.Ignore())
                .ForMember(dest => dest.DeletionTime, opt => opt.Ignore());

            CreateMap<Update${ENTITY_NAME}Dto, ${ENTITY_NAME}>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.ExtraProperties, opt => opt.Ignore())
                .ForMember(dest => dest.ConcurrencyStamp, opt => opt.Ignore())
                .ForMember(dest => dest.CreationTime, opt => opt.Ignore())
                .ForMember(dest => dest.CreatorId, opt => opt.Ignore())
                .ForMember(dest => dest.LastModificationTime, opt => opt.Ignore())
                .ForMember(dest => dest.LastModifierId, opt => opt.Ignore())
                .ForMember(dest => dest.IsDeleted, opt => opt.Ignore())
                .ForMember(dest => dest.DeleterId, opt => opt.Ignore())
                .ForMember(dest => dest.DeletionTime, opt => opt.Ignore());

            ${ADDITIONAL_MAPPINGS}
        }
    }
}

