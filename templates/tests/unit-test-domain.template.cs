using System;
using System.Threading.Tasks;
using Shouldly;
using Volo.Abp;
using Xunit;

namespace ${NAMESPACE}.${MODULE_NAME}.Domain
{
    /// <summary>
    /// Unit tests for ${ENTITY_NAME} domain logic.
    /// Tests entity behavior and domain services.
    /// Follows AAA (Arrange-Act-Assert) pattern.
    /// </summary>
    public class ${ENTITY_NAME}DomainTests : ${MODULE_NAME}DomainTestBase
    {
        private readonly ${ENTITY_NAME}Manager _${ENTITY_NAME_LOWER}Manager;
        private readonly I${ENTITY_NAME}Repository _${ENTITY_NAME_LOWER}Repository;

        public ${ENTITY_NAME}DomainTests()
        {
            _${ENTITY_NAME_LOWER}Manager = GetRequiredService<${ENTITY_NAME}Manager>();
            _${ENTITY_NAME_LOWER}Repository = GetRequiredService<I${ENTITY_NAME}Repository>();
        }

        [Fact]
        public void Should_Create_${ENTITY_NAME}_Entity_With_Valid_Data()
        {
            // Arrange
            var id = Guid.NewGuid();
            var name = "Test ${ENTITY_NAME}";

            // Act
            var entity = new ${ENTITY_NAME}(id, name);

            // Assert
            entity.ShouldNotBeNull();
            entity.Id.ShouldBe(id);
            entity.Name.ShouldBe(name);
            entity.IsActive.ShouldBeTrue();
        }

        [Fact]
        public void Should_Not_Create_${ENTITY_NAME}_With_Null_Name()
        {
            // Arrange
            var id = Guid.NewGuid();

            // Act & Assert
            Should.Throw<ArgumentNullException>(() =>
            {
                var entity = new ${ENTITY_NAME}(id, null!);
            });
        }

        [Fact]
        public void Should_Not_Create_${ENTITY_NAME}_With_Empty_Name()
        {
            // Arrange
            var id = Guid.NewGuid();

            // Act & Assert
            Should.Throw<ArgumentException>(() =>
            {
                var entity = new ${ENTITY_NAME}(id, string.Empty);
            });
        }

        [Fact]
        public void Should_Set_Name_Successfully()
        {
            // Arrange
            var entity = new ${ENTITY_NAME}(Guid.NewGuid(), "Original Name");
            var newName = "Updated Name";

            // Act
            entity.SetName(newName);

            // Assert
            entity.Name.ShouldBe(newName);
        }

        [Fact]
        public void Should_Set_Description_Successfully()
        {
            // Arrange
            var entity = new ${ENTITY_NAME}(Guid.NewGuid(), "Test ${ENTITY_NAME}");
            var description = "Test description";

            // Act
            entity.SetDescription(description);

            // Assert
            entity.Description.ShouldBe(description);
        }

        [Fact]
        public void Should_Activate_${ENTITY_NAME}_Successfully()
        {
            // Arrange
            var entity = new ${ENTITY_NAME}(Guid.NewGuid(), "Test ${ENTITY_NAME}");
            entity.Deactivate();

            // Act
            entity.Activate();

            // Assert
            entity.IsActive.ShouldBeTrue();
        }

        [Fact]
        public void Should_Deactivate_${ENTITY_NAME}_Successfully()
        {
            // Arrange
            var entity = new ${ENTITY_NAME}(Guid.NewGuid(), "Test ${ENTITY_NAME}");

            // Act
            entity.Deactivate();

            // Assert
            entity.IsActive.ShouldBeFalse();
        }

        [Fact]
        public async Task Should_Create_${ENTITY_NAME}_Through_Manager_Successfully()
        {
            // Arrange
            var name = "Manager Created ${ENTITY_NAME}";
            var description = "Test description";

            // Act
            var entity = await _${ENTITY_NAME_LOWER}Manager.CreateAsync(name, description);

            // Assert
            entity.ShouldNotBeNull();
            entity.Name.ShouldBe(name);
            entity.Description.ShouldBe(description);
            entity.IsActive.ShouldBeTrue();
        }

        [Fact]
        public async Task Should_Not_Create_${ENTITY_NAME}_With_Duplicate_Name_Through_Manager()
        {
            // Arrange
            var name = "Duplicate ${ENTITY_NAME}";
            var entity1 = await _${ENTITY_NAME_LOWER}Manager.CreateAsync(name);
            await _${ENTITY_NAME_LOWER}Repository.InsertAsync(entity1);

            // Act & Assert
            await Should.ThrowAsync<BusinessException>(async () =>
            {
                await _${ENTITY_NAME_LOWER}Manager.CreateAsync(name);
            });
        }

        [Fact]
        public async Task Should_Update_Name_Through_Manager_Successfully()
        {
            // Arrange
            var entity = await _${ENTITY_NAME_LOWER}Manager.CreateAsync("Original Name");
            await _${ENTITY_NAME_LOWER}Repository.InsertAsync(entity);
            var newName = "Updated Name";

            // Act
            await _${ENTITY_NAME_LOWER}Manager.UpdateNameAsync(entity, newName);

            // Assert
            entity.Name.ShouldBe(newName);
        }

        [Fact]
        public async Task Should_Not_Update_Name_To_Duplicate_Through_Manager()
        {
            // Arrange
            var entity1 = await _${ENTITY_NAME_LOWER}Manager.CreateAsync("Entity 1");
            await _${ENTITY_NAME_LOWER}Repository.InsertAsync(entity1);
            
            var entity2 = await _${ENTITY_NAME_LOWER}Manager.CreateAsync("Entity 2");
            await _${ENTITY_NAME_LOWER}Repository.InsertAsync(entity2);

            // Act & Assert
            await Should.ThrowAsync<BusinessException>(async () =>
            {
                await _${ENTITY_NAME_LOWER}Manager.UpdateNameAsync(entity2, "Entity 1");
            });
        }

        [Fact]
        public async Task Should_Validate_Deletion_Through_Manager()
        {
            // Arrange
            var entity = await _${ENTITY_NAME_LOWER}Manager.CreateAsync("Test ${ENTITY_NAME}");
            await _${ENTITY_NAME_LOWER}Repository.InsertAsync(entity);

            // Act
            var canDelete = await _${ENTITY_NAME_LOWER}Manager.CanDeleteAsync(entity);

            // Assert
            canDelete.ShouldBeTrue();
        }

        [Fact]
        public async Task Should_Validate_Activation_Through_Manager()
        {
            // Arrange
            var entity = await _${ENTITY_NAME_LOWER}Manager.CreateAsync("Test ${ENTITY_NAME}");
            entity.Deactivate();
            await _${ENTITY_NAME_LOWER}Repository.InsertAsync(entity);

            // Act & Assert - Should not throw
            await _${ENTITY_NAME_LOWER}Manager.ValidateActivationAsync(entity);
        }
    }
}

