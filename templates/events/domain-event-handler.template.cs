using System;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Volo.Abp.DependencyInjection;
using Volo.Abp.EventBus.Distributed;

namespace ${NAMESPACE}.${MODULE_NAME}.EventHandlers
{
    /// <summary>
    /// Handles ${ENTITY_NAME}${EVENT_NAME} distributed events.
    /// This is an empty handler template - implement your business logic here.
    /// </summary>
    public class ${ENTITY_NAME}${EVENT_NAME}Handler :
        IDistributedEventHandler<${ENTITY_NAME}${EVENT_NAME}Eto>,
        ITransientDependency
    {
        private readonly ILogger<${ENTITY_NAME}${EVENT_NAME}Handler> _logger;

        /// <summary>
        /// Initializes a new instance of the <see cref="${ENTITY_NAME}${EVENT_NAME}Handler"/> class.
        /// </summary>
        /// <param name="logger">The logger.</param>
        public ${ENTITY_NAME}${EVENT_NAME}Handler(ILogger<${ENTITY_NAME}${EVENT_NAME}Handler> logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// Handles the ${ENTITY_NAME}${EVENT_NAME} event.
        /// </summary>
        /// <param name="eventData">The event data.</param>
        public async Task HandleEventAsync(${ENTITY_NAME}${EVENT_NAME}Eto eventData)
        {
            _logger.LogInformation(
                "Handling ${ENTITY_NAME}${EVENT_NAME} event for ID: {Id}, Name: {Name}",
                eventData.Id,
                eventData.Name
            );

            // TODO: Implement your business logic here
            // Examples:
            // - Send notifications
            // - Update related entities
            // - Trigger other processes
            // - Sync data to other services

            await Task.CompletedTask;
        }
    }
}

