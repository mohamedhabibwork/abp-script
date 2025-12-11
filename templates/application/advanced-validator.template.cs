using System;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using FluentValidation;
using ${NAMESPACE}.Application.Contracts.${MODULE_NAME}.DTOs;
using ${NAMESPACE}.Domain.${MODULE_NAME};

namespace ${NAMESPACE}.Application.${MODULE_NAME}.Validators
{
    /// <summary>
    /// Advanced validator for <see cref="Create${ENTITY_NAME}Dto"/> with custom rules.
    /// Implements FluentValidation with async validation and custom business rules.
    /// </summary>
    public class Create${ENTITY_NAME}DtoAdvancedValidator : AbstractValidator<Create${ENTITY_NAME}Dto>
    {
        private readonly I${ENTITY_NAME}Repository _${ENTITY_NAME_LOWER}Repository;

        /// <summary>
        /// Initializes a new instance of the <see cref="Create${ENTITY_NAME}DtoAdvancedValidator"/> class.
        /// </summary>
        public Create${ENTITY_NAME}DtoAdvancedValidator(I${ENTITY_NAME}Repository ${ENTITY_NAME_LOWER}Repository)
        {
            _${ENTITY_NAME_LOWER}Repository = ${ENTITY_NAME_LOWER}Repository;

            // Name validation with regex
            RuleFor(x => x.Name)
                .NotEmpty()
                .WithMessage("${MODULE_NAME}:Validation:${ENTITY_NAME}:NameRequired")
                .Length(${ENTITY_NAME}Consts.MinNameLength, ${ENTITY_NAME}Consts.MaxNameLength)
                .WithMessage("${MODULE_NAME}:Validation:${ENTITY_NAME}:NameLength")
                .Matches(@"^[a-zA-Z0-9\s\-_]+$")
                .WithMessage("Name can only contain letters, numbers, spaces, hyphens, and underscores")
                .MustAsync(BeUniqueNameAsync)
                .WithMessage("${MODULE_NAME}:Validation:${ENTITY_NAME}:AlreadyExists");

            // Description validation
            RuleFor(x => x.Description)
                .MaximumLength(${ENTITY_NAME}Consts.MaxDescriptionLength)
                .WithMessage("${MODULE_NAME}:Validation:${ENTITY_NAME}:DescriptionLength")
                .When(x => !string.IsNullOrEmpty(x.Description));

            ${ADDITIONAL_VALIDATION_RULES}
        }

        /// <summary>
        /// Validates that the ${ENTITY_NAME} name is unique.
        /// </summary>
        private async Task<bool> BeUniqueNameAsync(string name, CancellationToken cancellationToken)
        {
            var exists = await _${ENTITY_NAME_LOWER}Repository.ExistsByNameAsync(name, cancellationToken: cancellationToken);
            return !exists;
        }
    }

    /// <summary>
    /// Advanced validator for <see cref="Update${ENTITY_NAME}Dto"/> with custom rules.
    /// </summary>
    public class Update${ENTITY_NAME}DtoAdvancedValidator : AbstractValidator<Update${ENTITY_NAME}Dto>
    {
        private readonly I${ENTITY_NAME}Repository _${ENTITY_NAME_LOWER}Repository;

        /// <summary>
        /// Initializes a new instance of the <see cref="Update${ENTITY_NAME}DtoAdvancedValidator"/> class.
        /// </summary>
        public Update${ENTITY_NAME}DtoAdvancedValidator(I${ENTITY_NAME}Repository ${ENTITY_NAME_LOWER}Repository)
        {
            _${ENTITY_NAME_LOWER}Repository = ${ENTITY_NAME_LOWER}Repository;

            // Name validation with regex
            RuleFor(x => x.Name)
                .NotEmpty()
                .WithMessage("${MODULE_NAME}:Validation:${ENTITY_NAME}:NameRequired")
                .Length(${ENTITY_NAME}Consts.MinNameLength, ${ENTITY_NAME}Consts.MaxNameLength)
                .WithMessage("${MODULE_NAME}:Validation:${ENTITY_NAME}:NameLength")
                .Matches(@"^[a-zA-Z0-9\s\-_]+$")
                .WithMessage("Name can only contain letters, numbers, spaces, hyphens, and underscores");

            // Description validation
            RuleFor(x => x.Description)
                .MaximumLength(${ENTITY_NAME}Consts.MaxDescriptionLength)
                .WithMessage("${MODULE_NAME}:Validation:${ENTITY_NAME}:DescriptionLength")
                .When(x => !string.IsNullOrEmpty(x.Description));

            ${ADDITIONAL_VALIDATION_RULES}
        }
    }

    ${CUSTOM_VALIDATORS}
}

