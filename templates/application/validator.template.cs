using FluentValidation;
using ${NAMESPACE}.Application.Contracts.${MODULE_NAME}.DTOs;
using ${NAMESPACE}.Domain.${MODULE_NAME}.Constants;

namespace ${NAMESPACE}.Application.${MODULE_NAME}.Validators
{
    /// <summary>
    /// Validator for <see cref="Create${ENTITY_NAME}Dto"/>.
    /// Implements FluentValidation rules for creating a ${ENTITY_NAME}.
    /// </summary>
    public class Create${ENTITY_NAME}DtoValidator : AbstractValidator<Create${ENTITY_NAME}Dto>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="Create${ENTITY_NAME}DtoValidator"/> class.
        /// </summary>
        public Create${ENTITY_NAME}DtoValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty()
                .WithMessage("Name is required.")
                .Length(${ENTITY_NAME}Constants.ValidationConstants.MinNameLength, ${ENTITY_NAME}Constants.ValidationConstants.MaxNameLength)
                .WithMessage($"Name must be between {${ENTITY_NAME}Consts.MinNameLength} and {${ENTITY_NAME}Consts.MaxNameLength} characters.")
                .Matches("^[a-zA-Z0-9\\s-_]+$")
                .WithMessage("Name can only contain letters, numbers, spaces, hyphens, and underscores.");

            RuleFor(x => x.Description)
                .MaximumLength(${ENTITY_NAME}Constants.ValidationConstants.MaxDescriptionLength)
                .WithMessage($"Description cannot exceed {${ENTITY_NAME}Consts.MaxDescriptionLength} characters.")
                .When(x => !string.IsNullOrEmpty(x.Description));

            ${VALIDATION_RULES}
        }
    }

    /// <summary>
    /// Validator for <see cref="Update${ENTITY_NAME}Dto"/>.
    /// Implements FluentValidation rules for updating a ${ENTITY_NAME}.
    /// </summary>
    public class Update${ENTITY_NAME}DtoValidator : AbstractValidator<Update${ENTITY_NAME}Dto>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="Update${ENTITY_NAME}DtoValidator"/> class.
        /// </summary>
        public Update${ENTITY_NAME}DtoValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty()
                .WithMessage("Name is required.")
                .Length(${ENTITY_NAME}Constants.ValidationConstants.MinNameLength, ${ENTITY_NAME}Constants.ValidationConstants.MaxNameLength)
                .WithMessage($"Name must be between {${ENTITY_NAME}Consts.MinNameLength} and {${ENTITY_NAME}Consts.MaxNameLength} characters.")
                .Matches("^[a-zA-Z0-9\\s-_]+$")
                .WithMessage("Name can only contain letters, numbers, spaces, hyphens, and underscores.");

            RuleFor(x => x.Description)
                .MaximumLength(${ENTITY_NAME}Constants.ValidationConstants.MaxDescriptionLength)
                .WithMessage($"Description cannot exceed {${ENTITY_NAME}Consts.MaxDescriptionLength} characters.")
                .When(x => !string.IsNullOrEmpty(x.Description));

            ${VALIDATION_RULES}
        }
    }
}

