using System;
using System.Threading.Tasks;
using NSubstitute;
using Shouldly;
using Volo.Abp;
using Xunit;
using ${NAMESPACE}.Domain.${MODULE_NAME};
using ${NAMESPACE}.Domain.${MODULE_NAME}.Services;

namespace ${NAMESPACE}.Domain.Tests.${MODULE_NAME}
{
    /// <summary>
    /// Unit tests for ${ENTITY_NAME}Manager domain service.
    /// Tests business logic and domain rules.
    /// </summary>
    public class ${ENTITY_NAME}ManagerTests : ${MODULE_NAME}DomainTestBase
    {
        private readonly ${ENTITY_NAME}Manager _manager;
        private readonly I${ENTITY_NAME}Repository _repository;

        public ${ENTITY_NAME}ManagerTests()
        {
            _repository = Substitute.For<I${ENTITY_NAME}Repository>();
            _manager = new ${ENTITY_NAME}Manager(_repository);
        }

        [Fact]
        public async Task CreateAsync_Should_Create_Entity_When_Name_Is_Unique()
        {
            // Arrange
            var name = "Unique Name";
            _repository.FindByNameAsync(name).Returns(Task.FromResult<${ENTITY_NAME}>(null));

            // Act
            var result = await _manager.CreateAsync(name, "Description");

            // Assert
            result.ShouldNotBeNull();
            result.Name.ShouldBe(name);
        }

        [Fact]
        public async Task CreateAsync_Should_Throw_When_Name_Already_Exists()
        {
            // Arrange
            var name = "Existing Name";
            var existingEntity = new ${ENTITY_NAME}(Guid.NewGuid(), name);
            _repository.FindByNameAsync(name).Returns(Task.FromResult(existingEntity));

            // Act & Assert
            await Should.ThrowAsync<BusinessException>(async () =>
            {
                await _manager.CreateAsync(name, "Description");
            });
        }

        [Fact]
        public async Task UpdateNameAsync_Should_Update_When_New_Name_Is_Unique()
        {
            // Arrange
            var entity = new ${ENTITY_NAME}(Guid.NewGuid(), "Old Name");
            var newName = "New Name";
            _repository.FindByNameAsync(newName).Returns(Task.FromResult<${ENTITY_NAME}>(null));

            // Act
            await _manager.UpdateNameAsync(entity, newName);

            // Assert
            entity.Name.ShouldBe(newName);
        }

        [Fact]
        public async Task UpdateNameAsync_Should_Throw_When_Name_Already_Exists()
        {
            // Arrange
            var entity = new ${ENTITY_NAME}(Guid.NewGuid(), "Old Name");
            var newName = "Existing Name";
            var existingEntity = new ${ENTITY_NAME}(Guid.NewGuid(), newName);
            _repository.FindByNameAsync(newName).Returns(Task.FromResult(existingEntity));

            // Act & Assert
            await Should.ThrowAsync<BusinessException>(async () =>
            {
                await _manager.UpdateNameAsync(entity, newName);
            });
        }

        [Fact]
        public async Task CanDeleteAsync_Should_Return_True_When_Allowed()
        {
            // Arrange
            var entity = new ${ENTITY_NAME}(Guid.NewGuid(), "Test Name");

            // Act
            var result = await _manager.CanDeleteAsync(entity);

            // Assert
            result.ShouldBeTrue();
        }
    }
}

