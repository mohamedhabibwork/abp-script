using System.Threading.Tasks;
using FluentValidation.TestHelper;
using Xunit;
using ${NAMESPACE}.Application.${MODULE_NAME}.Validators;
using ${NAMESPACE}.Application.Contracts.${MODULE_NAME}.DTOs;
using ${NAMESPACE}.Domain.${MODULE_NAME};
using NSubstitute;

namespace ${NAMESPACE}.Application.Tests.${MODULE_NAME}
{
    /// <summary>
    /// Unit tests for ${ENTITY_NAME} validators.
    /// Tests all validation rules including async validations.
    /// </summary>
    public class ${ENTITY_NAME}ValidatorTests : ${MODULE_NAME}ApplicationTestBase
    {
        private readonly Create${ENTITY_NAME}DtoAdvancedValidator _createValidator;
        private readonly Update${ENTITY_NAME}DtoAdvancedValidator _updateValidator;
        private readonly I${ENTITY_NAME}Repository _repository;

        public ${ENTITY_NAME}ValidatorTests()
        {
            _repository = Substitute.For<I${ENTITY_NAME}Repository>();
            _createValidator = new Create${ENTITY_NAME}DtoAdvancedValidator(_repository);
            _updateValidator = new Update${ENTITY_NAME}DtoAdvancedValidator(_repository);
        }

        [Fact]
        public async Task Should_Have_Error_When_Name_Is_Empty()
        {
            // Arrange
            var dto = new Create${ENTITY_NAME}Dto { Name = string.Empty };

            // Act
            var result = await _createValidator.TestValidateAsync(dto);

            // Assert
            result.ShouldHaveValidationErrorFor(x => x.Name);
        }

        [Fact]
        public async Task Should_Have_Error_When_Name_Is_Too_Short()
        {
            // Arrange
            var dto = new Create${ENTITY_NAME}Dto { Name = "A" };

            // Act
            var result = await _createValidator.TestValidateAsync(dto);

            // Assert
            result.ShouldHaveValidationErrorFor(x => x.Name);
        }

        [Fact]
        public async Task Should_Have_Error_When_Name_Is_Too_Long()
        {
            // Arrange
            var dto = new Create${ENTITY_NAME}Dto { Name = new string('A', 201) };

            // Act
            var result = await _createValidator.TestValidateAsync(dto);

            // Assert
            result.ShouldHaveValidationErrorFor(x => x.Name);
        }

        [Fact]
        public async Task Should_Have_Error_When_Name_Contains_Invalid_Characters()
        {
            // Arrange
            var dto = new Create${ENTITY_NAME}Dto { Name = "Invalid@Name!" };

            // Act
            var result = await _createValidator.TestValidateAsync(dto);

            // Assert
            result.ShouldHaveValidationErrorFor(x => x.Name);
        }

        [Fact]
        public async Task Should_Have_Error_When_Name_Already_Exists()
        {
            // Arrange
            var dto = new Create${ENTITY_NAME}Dto { Name = "Existing Name" };
            _repository.ExistsByNameAsync("Existing Name").Returns(Task.FromResult(true));

            // Act
            var result = await _createValidator.TestValidateAsync(dto);

            // Assert
            result.ShouldHaveValidationErrorFor(x => x.Name);
        }

        [Fact]
        public async Task Should_Not_Have_Error_When_Valid()
        {
            // Arrange
            var dto = new Create${ENTITY_NAME}Dto 
            { 
                Name = "Valid Name",
                Description = "Valid Description"
            };
            _repository.ExistsByNameAsync("Valid Name").Returns(Task.FromResult(false));

            // Act
            var result = await _createValidator.TestValidateAsync(dto);

            // Assert
            result.ShouldNotHaveAnyValidationErrors();
        }
    }
}

