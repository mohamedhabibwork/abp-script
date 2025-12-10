using System;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Volo.Abp.DependencyInjection;
using Volo.Abp.EventBus;

namespace ${NAMESPACE}.${MODULE_NAME}.EventHandlers
{
    /// <summary>
    /// Handles ${ENTITY_NAME}${EVENT_NAME} local events.
    /// Local events are handled within the same application instance.
    /// This is an empty handler template - implement your business logic here.
    /// </summary>
    public class ${ENTITY_NAME}${EVENT_NAME}LocalHandler :
        ILocalEventHandler<${ENTITY_NAME}${EVENT_NAME}Event>,
        ITransientDependency
    {
        private readonly ILogger<${ENTITY_NAME}${EVENT_NAME}LocalHandler> _logger;

        /// <summary>
        /// Initializes a new instance of the <see cref="${ENTITY_NAME}${EVENT_NAME}LocalHandler"/> class.
        /// </summary>
        /// <param name="logger">The logger.</param>
        public ${ENTITY_NAME}${EVENT_NAME}LocalHandler(ILogger<${ENTITY_NAME}${EVENT_NAME}LocalHandler> logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// Handles the ${ENTITY_NAME}${EVENT_NAME} local event.
        /// </summary>
        /// <param name="eventData">The event data.</param>
        public async Task HandleEventAsync(${ENTITY_NAME}${EVENT_NAME}Event eventData)
        {
            _logger.LogInformation(
                "Handling local ${ENTITY_NAME}${EVENT_NAME} event for ID: {Id}",
                eventData.${ENTITY_NAME}Id
            );

            // TODO: Implement your business logic here
            // Examples:
            // - Update cache
            // - Log audit information
            // - Trigger domain events
            // - Update aggregates

            await Task.CompletedTask;
        }
    }
}

