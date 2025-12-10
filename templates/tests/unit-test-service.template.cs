using System;
using System.Threading.Tasks;
using NSubstitute;
using Shouldly;
using Volo.Abp.Application.Dtos;
using Volo.Abp.EventBus.Distributed;
using Xunit;

namespace ${NAMESPACE}.${MODULE_NAME}.Services
{
    /// <summary>
    /// Unit tests for <see cref="${ENTITY_NAME}AppService"/>.
    /// Tests follow AAA (Arrange-Act-Assert) pattern.
    /// Uses NSubstitute for mocking dependencies.
    /// </summary>
    public class ${ENTITY_NAME}AppServiceTests : ${MODULE_NAME}ApplicationTestBase
    {
        private readonly I${ENTITY_NAME}AppService _${ENTITY_NAME_LOWER}AppService;
        private readonly I${ENTITY_NAME}Repository _${ENTITY_NAME_LOWER}Repository;
        private readonly ${ENTITY_NAME}Manager _${ENTITY_NAME_LOWER}Manager;

        public ${ENTITY_NAME}AppServiceTests()
        {
            _${ENTITY_NAME_LOWER}Repository = GetRequiredService<I${ENTITY_NAME}Repository>();
            _${ENTITY_NAME_LOWER}Manager = GetRequiredService<${ENTITY_NAME}Manager>();
            _${ENTITY_NAME_LOWER}AppService = GetRequiredService<I${ENTITY_NAME}AppService>();
        }

        [Fact]
        public async Task Should_Get_${ENTITY_NAME}_Successfully()
        {
            // Arrange
            var testEntity = await Create_Test_${ENTITY_NAME}_Async();

            // Act
            var result = await _${ENTITY_NAME_LOWER}AppService.GetAsync(testEntity.Id);

            // Assert
            result.ShouldNotBeNull();
            result.Id.ShouldBe(testEntity.Id);
            result.Name.ShouldBe(testEntity.Name);
            result.Description.ShouldBe(testEntity.Description);
            result.IsActive.ShouldBe(testEntity.IsActive);
        }

        [Fact]
        public async Task Should_Get_List_Of_${ENTITY_NAME_PLURAL}_Successfully()
        {
            // Arrange
            await Create_Test_${ENTITY_NAME}_Async("Test ${ENTITY_NAME} 1");
            await Create_Test_${ENTITY_NAME}_Async("Test ${ENTITY_NAME} 2");
            await Create_Test_${ENTITY_NAME}_Async("Test ${ENTITY_NAME} 3");

            // Act
            var result = await _${ENTITY_NAME_LOWER}AppService.GetListAsync(new Get${ENTITY_NAME}ListInput
            {
                MaxResultCount = 10,
                SkipCount = 0
            });

            // Assert
            result.ShouldNotBeNull();
            result.TotalCount.ShouldBeGreaterThanOrEqualTo(3);
            result.Items.ShouldNotBeEmpty();
        }

        [Fact]
        public async Task Should_Create_${ENTITY_NAME}_Successfully()
        {
            // Arrange
            var createDto = new Create${ENTITY_NAME}Dto
            {
                Name = "New Test ${ENTITY_NAME}",
                Description = "Test description",
                IsActive = true
            };

            // Act
            var result = await _${ENTITY_NAME_LOWER}AppService.CreateAsync(createDto);

            // Assert
            result.ShouldNotBeNull();
            result.Id.ShouldNotBe(Guid.Empty);
            result.Name.ShouldBe(createDto.Name);
            result.Description.ShouldBe(createDto.Description);
            result.IsActive.ShouldBe(createDto.IsActive);

            // Verify it was saved to repository
            var savedEntity = await _${ENTITY_NAME_LOWER}Repository.FindAsync(result.Id);
            savedEntity.ShouldNotBeNull();
        }

        [Fact]
        public async Task Should_Not_Create_${ENTITY_NAME}_With_Duplicate_Name()
        {
            // Arrange
            var existingEntity = await Create_Test_${ENTITY_NAME}_Async("Duplicate Name");
            
            var createDto = new Create${ENTITY_NAME}Dto
            {
                Name = "Duplicate Name",
                Description = "Test description",
                IsActive = true
            };

            // Act & Assert
            await Should.ThrowAsync<BusinessException>(async () =>
            {
                await _${ENTITY_NAME_LOWER}AppService.CreateAsync(createDto);
            });
        }

        [Fact]
        public async Task Should_Update_${ENTITY_NAME}_Successfully()
        {
            // Arrange
            var testEntity = await Create_Test_${ENTITY_NAME}_Async();
            
            var updateDto = new Update${ENTITY_NAME}Dto
            {
                Name = "Updated Name",
                Description = "Updated description",
                IsActive = false
            };

            // Act
            var result = await _${ENTITY_NAME_LOWER}AppService.UpdateAsync(testEntity.Id, updateDto);

            // Assert
            result.ShouldNotBeNull();
            result.Id.ShouldBe(testEntity.Id);
            result.Name.ShouldBe(updateDto.Name);
            result.Description.ShouldBe(updateDto.Description);
            result.IsActive.ShouldBe(updateDto.IsActive);
        }

        [Fact]
        public async Task Should_Delete_${ENTITY_NAME}_Successfully()
        {
            // Arrange
            var testEntity = await Create_Test_${ENTITY_NAME}_Async();

            // Act
            await _${ENTITY_NAME_LOWER}AppService.DeleteAsync(testEntity.Id);

            // Assert
            var deletedEntity = await _${ENTITY_NAME_LOWER}Repository.FindAsync(testEntity.Id);
            deletedEntity.ShouldBeNull();
        }

        [Fact]
        public async Task Should_Activate_${ENTITY_NAME}_Successfully()
        {
            // Arrange
            var testEntity = await Create_Test_${ENTITY_NAME}_Async();
            testEntity.Deactivate();
            await _${ENTITY_NAME_LOWER}Repository.UpdateAsync(testEntity);

            // Act
            await _${ENTITY_NAME_LOWER}AppService.ActivateAsync(testEntity.Id);

            // Assert
            var activatedEntity = await _${ENTITY_NAME_LOWER}Repository.GetAsync(testEntity.Id);
            activatedEntity.IsActive.ShouldBeTrue();
        }

        [Fact]
        public async Task Should_Deactivate_${ENTITY_NAME}_Successfully()
        {
            // Arrange
            var testEntity = await Create_Test_${ENTITY_NAME}_Async();

            // Act
            await _${ENTITY_NAME_LOWER}AppService.DeactivateAsync(testEntity.Id);

            // Assert
            var deactivatedEntity = await _${ENTITY_NAME_LOWER}Repository.GetAsync(testEntity.Id);
            deactivatedEntity.IsActive.ShouldBeFalse();
        }

        [Fact]
        public async Task Should_Filter_${ENTITY_NAME_PLURAL}_By_Name()
        {
            // Arrange
            await Create_Test_${ENTITY_NAME}_Async("FilterTest 1");
            await Create_Test_${ENTITY_NAME}_Async("FilterTest 2");
            await Create_Test_${ENTITY_NAME}_Async("Different Name");

            // Act
            var result = await _${ENTITY_NAME_LOWER}AppService.GetListAsync(new Get${ENTITY_NAME}ListInput
            {
                Filter = "FilterTest",
                MaxResultCount = 10
            });

            // Assert
            result.TotalCount.ShouldBeGreaterThanOrEqualTo(2);
            result.Items.ShouldAllBe(x => x.Name.Contains("FilterTest"));
        }

        [Fact]
        public async Task Should_Get_Lookup_List_Successfully()
        {
            // Arrange
            await Create_Test_${ENTITY_NAME}_Async("Lookup Item 1");
            await Create_Test_${ENTITY_NAME}_Async("Lookup Item 2");

            // Act
            var result = await _${ENTITY_NAME_LOWER}AppService.GetLookupAsync();

            // Assert
            result.ShouldNotBeNull();
            result.Items.ShouldNotBeEmpty();
            result.Items.ShouldAllBe(x => x.IsActive);
        }

        #region Helper Methods

        private async Task<${ENTITY_NAME}> Create_Test_${ENTITY_NAME}_Async(string name = "Test ${ENTITY_NAME}")
        {
            var entity = await _${ENTITY_NAME_LOWER}Manager.CreateAsync(
                name,
                "Test description for " + name
            );

            return await _${ENTITY_NAME_LOWER}Repository.InsertAsync(entity, autoSave: true);
        }

        #endregion
    }
}

