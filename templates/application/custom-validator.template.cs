using System;
using System.Threading;
using System.Threading.Tasks;
using FluentValidation;
using FluentValidation.Validators;

namespace ${NAMESPACE}.${MODULE_NAME}.Validators
{
    /// <summary>
    /// Custom async validator for checking ${ENTITY_NAME} uniqueness.
    /// Follows the Strategy pattern for validation.
    /// </summary>
    public class Unique${ENTITY_NAME}NameValidator : AsyncPropertyValidator<string>
    {
        private readonly I${ENTITY_NAME}Repository _repository;
        private readonly Guid? _excludeId;

        /// <summary>
        /// Initializes a new instance of the <see cref="Unique${ENTITY_NAME}NameValidator"/> class.
        /// </summary>
        /// <param name="repository">The ${ENTITY_NAME} repository.</param>
        /// <param name="excludeId">ID to exclude from uniqueness check (for updates).</param>
        public Unique${ENTITY_NAME}NameValidator(
            I${ENTITY_NAME}Repository repository,
            Guid? excludeId = null)
        {
            _repository = repository;
            _excludeId = excludeId;
        }

        /// <summary>
        /// Gets the name of the validator.
        /// </summary>
        public override string Name => "Unique${ENTITY_NAME}NameValidator";

        /// <summary>
        /// Validates the property asynchronously.
        /// </summary>
        /// <param name="context">The validation context.</param>
        /// <param name="value">The value to validate.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>True if valid; otherwise, false.</returns>
        public override async Task<bool> IsValidAsync(
            ValidationContext<object> context,
            string value,
            CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return true; // Let the NotEmpty validator handle this
            }

            var exists = await _repository.ExistsByNameAsync(value, _excludeId, cancellationToken);
            return !exists;
        }

        /// <summary>
        /// Gets the default error message.
        /// </summary>
        /// <param name="errorCode">The error code.</param>
        /// <returns>The error message.</returns>
        protected override string GetDefaultMessageTemplate(string errorCode)
        {
            return "A ${ENTITY_NAME} with the name '{PropertyValue}' already exists.";
        }
    }

    /// <summary>
    /// Extension methods for ${ENTITY_NAME} validators.
    /// </summary>
    public static class ${ENTITY_NAME}ValidatorExtensions
    {
        /// <summary>
        /// Adds a unique name validator to the rule.
        /// </summary>
        /// <typeparam name="T">The type being validated.</typeparam>
        /// <param name="ruleBuilder">The rule builder.</param>
        /// <param name="repository">The repository.</param>
        /// <param name="excludeId">ID to exclude from uniqueness check.</param>
        /// <returns>The rule builder options.</returns>
        public static IRuleBuilderOptions<T, string> MustBeUnique${ENTITY_NAME}Name<T>(
            this IRuleBuilder<T, string> ruleBuilder,
            I${ENTITY_NAME}Repository repository,
            Guid? excludeId = null)
        {
            return ruleBuilder.SetAsyncValidator(new Unique${ENTITY_NAME}NameValidator(repository, excludeId));
        }
    }
}

