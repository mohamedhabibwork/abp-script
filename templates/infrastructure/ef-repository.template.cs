using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Volo.Abp.Domain.Repositories.EntityFrameworkCore;
using Volo.Abp.EntityFrameworkCore;
using ${NAMESPACE}.Domain.${MODULE_NAME};

namespace ${NAMESPACE}.EntityFrameworkCore.${MODULE_NAME}.Repositories
{
    /// <summary>
    /// Entity Framework Core repository implementation for ${ENTITY_NAME}.
    /// Implements the Repository pattern with EF Core.
    /// </summary>
    public class EfCore${ENTITY_NAME}Repository : 
        EfCoreRepository<${DB_CONTEXT_NAME}, ${ENTITY_NAME}, ${ID_TYPE}>,
        I${ENTITY_NAME}Repository
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="EfCore${ENTITY_NAME}Repository"/> class.
        /// </summary>
        /// <param name="dbContextProvider">The database context provider.</param>
        public EfCore${ENTITY_NAME}Repository(
            IDbContextProvider<${DB_CONTEXT_NAME}> dbContextProvider)
            : base(dbContextProvider)
        {
        }

        ${REPOSITORY_METHODS}
    }
}

