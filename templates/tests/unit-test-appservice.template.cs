using System;
using System.Threading.Tasks;
using NSubstitute;
using Shouldly;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.EventBus.Distributed;
using Xunit;
using ${NAMESPACE}.Application.${MODULE_NAME};
using ${NAMESPACE}.Application.Contracts.${MODULE_NAME}.DTOs;
using ${NAMESPACE}.Domain.${MODULE_NAME};

namespace ${NAMESPACE}.Application.Tests.${MODULE_NAME}
{
    /// <summary>
    /// Comprehensive unit tests for ${ENTITY_NAME}AppService.
    /// Tests all CRUD operations, validations, and business logic.
    /// </summary>
    public class ${ENTITY_NAME}AppServiceTests : ${MODULE_NAME}ApplicationTestBase
    {
        private readonly ${ENTITY_NAME}AppService _appService;
        private readonly I${ENTITY_NAME}Repository _repository;
        private readonly ${ENTITY_NAME}Manager _manager;
        private readonly IDistributedEventBus _eventBus;

        public ${ENTITY_NAME}AppServiceTests()
        {
            _repository = Substitute.For<I${ENTITY_NAME}Repository>();
            _manager = Substitute.For<${ENTITY_NAME}Manager>();
            _eventBus = Substitute.For<IDistributedEventBus>();
            _appService = new ${ENTITY_NAME}AppService(_repository, _manager, _eventBus);
        }

        [Fact]
        public async Task GetAsync_Should_Return_Entity_When_Exists()
        {
            // Arrange
            var id = Guid.NewGuid();
            var entity = new ${ENTITY_NAME}(id, "Test ${ENTITY_NAME}");
            _repository.GetAsync(id).Returns(Task.FromResult(entity));

            // Act
            var result = await _appService.GetAsync(id);

            // Assert
            result.ShouldNotBeNull();
            result.Name.ShouldBe("Test ${ENTITY_NAME}");
            await _repository.Received(1).GetAsync(id);
        }

        [Fact]
        public async Task GetListAsync_Should_Return_Paginated_Results()
        {
            // Arrange
            var input = new Get${ENTITY_NAME}ListInput
            {
                SkipCount = 0,
                MaxResultCount = 10
            };
            var entities = new[] { 
                new ${ENTITY_NAME}(Guid.NewGuid(), "Entity 1"),
                new ${ENTITY_NAME}(Guid.NewGuid(), "Entity 2")
            };
            _repository.GetListAsync(0, 10, null, null, null).Returns(Task.FromResult(entities.ToList()));
            _repository.GetCountAsync(null, null).Returns(Task.FromResult(2L));

            // Act
            var result = await _appService.GetListAsync(input);

            // Assert
            result.ShouldNotBeNull();
            result.Items.Count.ShouldBe(2);
            result.TotalCount.ShouldBe(2);
        }

        [Fact]
        public async Task CreateAsync_Should_Create_Entity_Successfully()
        {
            // Arrange
            var input = new Create${ENTITY_NAME}Dto
            {
                Name = "New ${ENTITY_NAME}",
                Description = "Test Description",
                IsActive = true
            };
            var entity = new ${ENTITY_NAME}(Guid.NewGuid(), input.Name);
            _manager.CreateAsync(input.Name, input.Description).Returns(Task.FromResult(entity));
            _repository.InsertAsync(Arg.Any<${ENTITY_NAME}>(), true).Returns(Task.FromResult(entity));

            // Act
            var result = await _appService.CreateAsync(input);

            // Assert
            result.ShouldNotBeNull();
            result.Name.ShouldBe(input.Name);
            await _repository.Received(1).InsertAsync(Arg.Any<${ENTITY_NAME}>(), true);
        }

        [Fact]
        public async Task UpdateAsync_Should_Update_Entity_Successfully()
        {
            // Arrange
            var id = Guid.NewGuid();
            var entity = new ${ENTITY_NAME}(id, "Original Name");
            var input = new Update${ENTITY_NAME}Dto
            {
                Name = "Updated Name",
                Description = "Updated Description"
            };
            _repository.GetAsync(id).Returns(Task.FromResult(entity));
            _repository.UpdateAsync(entity, true).Returns(Task.FromResult(entity));

            // Act
            var result = await _appService.UpdateAsync(id, input);

            // Assert
            result.ShouldNotBeNull();
            await _repository.Received(1).UpdateAsync(entity, true);
        }

        [Fact]
        public async Task DeleteAsync_Should_Delete_Entity_Successfully()
        {
            // Arrange
            var id = Guid.NewGuid();
            var entity = new ${ENTITY_NAME}(id, "Test ${ENTITY_NAME}");
            _repository.GetAsync(id).Returns(Task.FromResult(entity));
            _manager.CanDeleteAsync(entity).Returns(Task.FromResult(true));

            // Act
            await _appService.DeleteAsync(id);

            // Assert
            await _repository.Received(1).DeleteAsync(entity);
        }

        [Fact]
        public async Task GetLookupAsync_Should_Return_Active_Entities()
        {
            // Arrange
            var entities = new[] {
                new ${ENTITY_NAME}(Guid.NewGuid(), "Active 1") { IsActive = true },
                new ${ENTITY_NAME}(Guid.NewGuid(), "Active 2") { IsActive = true }
            };
            _repository.GetActiveListAsync().Returns(Task.FromResult(entities.ToList()));

            // Act
            var result = await _appService.GetLookupAsync();

            // Assert
            result.ShouldNotBeNull();
            result.Items.Count.ShouldBe(2);
        }
    }
}

