using System;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Shouldly;
using Volo.Abp.Application.Dtos;
using Xunit;

namespace ${NAMESPACE}.${MODULE_NAME}.Controllers
{
    /// <summary>
    /// Integration tests for ${ENTITY_NAME}Controller.
    /// Tests the full HTTP API stack including routing, model binding, and validation.
    /// </summary>
    public class ${ENTITY_NAME}ControllerTests : ${MODULE_NAME}WebTestBase
    {
        private readonly HttpClient _client;
        private const string BaseUrl = "/api/${MODULE_NAME_LOWER}/${ENTITY_NAME_LOWER_PLURAL}";

        public ${ENTITY_NAME}ControllerTests()
        {
            _client = GetRequiredService<HttpClient>();
        }

        [Fact]
        public async Task Should_Get_${ENTITY_NAME}_Successfully()
        {
            // Arrange
            var entity = await Create_Test_${ENTITY_NAME}_Async();

            // Act
            var response = await _client.GetAsync($"{BaseUrl}/{entity.Id}");

            // Assert
            response.StatusCode.ShouldBe(HttpStatusCode.OK);
            
            var content = await response.Content.ReadAsStringAsync();
            var result = JsonSerializer.Deserialize<${ENTITY_NAME}Dto>(content, JsonOptions);
            
            result.ShouldNotBeNull();
            result.Id.ShouldBe(entity.Id);
            result.Name.ShouldBe(entity.Name);
        }

        [Fact]
        public async Task Should_Return_404_For_Non_Existent_${ENTITY_NAME}()
        {
            // Arrange
            var nonExistentId = Guid.NewGuid();

            // Act
            var response = await _client.GetAsync($"{BaseUrl}/{nonExistentId}");

            // Assert
            response.StatusCode.ShouldBe(HttpStatusCode.NotFound);
        }

        [Fact]
        public async Task Should_Get_List_Of_${ENTITY_NAME_PLURAL}_Successfully()
        {
            // Arrange
            await Create_Test_${ENTITY_NAME}_Async("Test 1");
            await Create_Test_${ENTITY_NAME}_Async("Test 2");
            await Create_Test_${ENTITY_NAME}_Async("Test 3");

            // Act
            var response = await _client.GetAsync($"{BaseUrl}?MaxResultCount=10&SkipCount=0");

            // Assert
            response.StatusCode.ShouldBe(HttpStatusCode.OK);
            
            var content = await response.Content.ReadAsStringAsync();
            var result = JsonSerializer.Deserialize<PagedResultDto<${ENTITY_NAME}Dto>>(content, JsonOptions);
            
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

            var json = JsonSerializer.Serialize(createDto);
            var stringContent = new StringContent(json, Encoding.UTF8, "application/json");

            // Act
            var response = await _client.PostAsync(BaseUrl, stringContent);

            // Assert
            response.StatusCode.ShouldBe(HttpStatusCode.Created);
            
            var content = await response.Content.ReadAsStringAsync();
            var result = JsonSerializer.Deserialize<${ENTITY_NAME}Dto>(content, JsonOptions);
            
            result.ShouldNotBeNull();
            result.Id.ShouldNotBe(Guid.Empty);
            result.Name.ShouldBe(createDto.Name);
            result.Description.ShouldBe(createDto.Description);
        }

        [Fact]
        public async Task Should_Return_400_When_Creating_${ENTITY_NAME}_With_Invalid_Data()
        {
            // Arrange
            var createDto = new Create${ENTITY_NAME}Dto
            {
                Name = "", // Invalid: empty name
                Description = "Test description",
                IsActive = true
            };

            var json = JsonSerializer.Serialize(createDto);
            var stringContent = new StringContent(json, Encoding.UTF8, "application/json");

            // Act
            var response = await _client.PostAsync(BaseUrl, stringContent);

            // Assert
            response.StatusCode.ShouldBe(HttpStatusCode.BadRequest);
        }

        [Fact]
        public async Task Should_Update_${ENTITY_NAME}_Successfully()
        {
            // Arrange
            var entity = await Create_Test_${ENTITY_NAME}_Async();
            
            var updateDto = new Update${ENTITY_NAME}Dto
            {
                Name = "Updated Name",
                Description = "Updated description",
                IsActive = false
            };

            var json = JsonSerializer.Serialize(updateDto);
            var stringContent = new StringContent(json, Encoding.UTF8, "application/json");

            // Act
            var response = await _client.PutAsync($"{BaseUrl}/{entity.Id}", stringContent);

            // Assert
            response.StatusCode.ShouldBe(HttpStatusCode.OK);
            
            var content = await response.Content.ReadAsStringAsync();
            var result = JsonSerializer.Deserialize<${ENTITY_NAME}Dto>(content, JsonOptions);
            
            result.ShouldNotBeNull();
            result.Name.ShouldBe(updateDto.Name);
            result.Description.ShouldBe(updateDto.Description);
            result.IsActive.ShouldBe(updateDto.IsActive);
        }

        [Fact]
        public async Task Should_Delete_${ENTITY_NAME}_Successfully()
        {
            // Arrange
            var entity = await Create_Test_${ENTITY_NAME}_Async();

            // Act
            var response = await _client.DeleteAsync($"{BaseUrl}/{entity.Id}");

            // Assert
            response.StatusCode.ShouldBe(HttpStatusCode.NoContent);

            // Verify entity is deleted
            var getResponse = await _client.GetAsync($"{BaseUrl}/{entity.Id}");
            getResponse.StatusCode.ShouldBe(HttpStatusCode.NotFound);
        }

        [Fact]
        public async Task Should_Activate_${ENTITY_NAME}_Successfully()
        {
            // Arrange
            var entity = await Create_Test_${ENTITY_NAME}_Async();

            // Act
            var response = await _client.PostAsync($"{BaseUrl}/{entity.Id}/activate", null);

            // Assert
            response.StatusCode.ShouldBe(HttpStatusCode.NoContent);

            // Verify entity is activated
            var getResponse = await _client.GetAsync($"{BaseUrl}/{entity.Id}");
            var content = await getResponse.Content.ReadAsStringAsync();
            var result = JsonSerializer.Deserialize<${ENTITY_NAME}Dto>(content, JsonOptions);
            result.IsActive.ShouldBeTrue();
        }

        [Fact]
        public async Task Should_Deactivate_${ENTITY_NAME}_Successfully()
        {
            // Arrange
            var entity = await Create_Test_${ENTITY_NAME}_Async();

            // Act
            var response = await _client.PostAsync($"{BaseUrl}/{entity.Id}/deactivate", null);

            // Assert
            response.StatusCode.ShouldBe(HttpStatusCode.NoContent);

            // Verify entity is deactivated
            var getResponse = await _client.GetAsync($"{BaseUrl}/{entity.Id}");
            var content = await getResponse.Content.ReadAsStringAsync();
            var result = JsonSerializer.Deserialize<${ENTITY_NAME}Dto>(content, JsonOptions);
            result.IsActive.ShouldBeFalse();
        }

        [Fact]
        public async Task Should_Get_Lookup_List_Successfully()
        {
            // Arrange
            await Create_Test_${ENTITY_NAME}_Async("Lookup 1");
            await Create_Test_${ENTITY_NAME}_Async("Lookup 2");

            // Act
            var response = await _client.GetAsync($"{BaseUrl}/lookup");

            // Assert
            response.StatusCode.ShouldBe(HttpStatusCode.OK);
            
            var content = await response.Content.ReadAsStringAsync();
            var result = JsonSerializer.Deserialize<ListResultDto<${ENTITY_NAME}LookupDto>>(content, JsonOptions);
            
            result.ShouldNotBeNull();
            result.Items.ShouldNotBeEmpty();
        }

        [Fact]
        public async Task Should_Filter_${ENTITY_NAME_PLURAL}_By_Name()
        {
            // Arrange
            await Create_Test_${ENTITY_NAME}_Async("FilterTest 1");
            await Create_Test_${ENTITY_NAME}_Async("FilterTest 2");
            await Create_Test_${ENTITY_NAME}_Async("Different");

            // Act
            var response = await _client.GetAsync($"{BaseUrl}?Filter=FilterTest&MaxResultCount=10");

            // Assert
            response.StatusCode.ShouldBe(HttpStatusCode.OK);
            
            var content = await response.Content.ReadAsStringAsync();
            var result = JsonSerializer.Deserialize<PagedResultDto<${ENTITY_NAME}Dto>>(content, JsonOptions);
            
            result.TotalCount.ShouldBeGreaterThanOrEqualTo(2);
        }

        #region Helper Methods

        private async Task<${ENTITY_NAME}Dto> Create_Test_${ENTITY_NAME}_Async(string name = "Test ${ENTITY_NAME}")
        {
            var createDto = new Create${ENTITY_NAME}Dto
            {
                Name = name,
                Description = $"Description for {name}",
                IsActive = true
            };

            var json = JsonSerializer.Serialize(createDto);
            var stringContent = new StringContent(json, Encoding.UTF8, "application/json");

            var response = await _client.PostAsync(BaseUrl, stringContent);
            var content = await response.Content.ReadAsStringAsync();
            
            return JsonSerializer.Deserialize<${ENTITY_NAME}Dto>(content, JsonOptions);
        }

        private static JsonSerializerOptions JsonOptions => new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true,
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        };

        #endregion
    }
}

