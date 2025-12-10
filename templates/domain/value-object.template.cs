using System;
using System.Collections.Generic;
using Volo.Abp.Domain.Values;

namespace ${NAMESPACE}.${MODULE_NAME}.ValueObjects
{
    /// <summary>
    /// Represents a ${VALUE_OBJECT_NAME} value object.
    /// </summary>
    public class ${VALUE_OBJECT_NAME} : ValueObject
    {
        /// <summary>
        /// Gets the value.
        /// </summary>
        public string Value { get; private set; }

        ${PROPERTIES}

        /// <summary>
        /// Private constructor for ORM.
        /// </summary>
        protected ${VALUE_OBJECT_NAME}()
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="${VALUE_OBJECT_NAME}"/> class.
        /// </summary>
        /// <param name="value">The value.</param>
        public ${VALUE_OBJECT_NAME}(string value)
        {
            Value = Check.NotNullOrWhiteSpace(value, nameof(value));
            Validate();
        }

        /// <summary>
        /// Validates the value object.
        /// </summary>
        /// <exception cref="ArgumentException">Thrown when validation fails.</exception>
        private void Validate()
        {
            // Add custom validation logic here
            if (string.IsNullOrWhiteSpace(Value))
            {
                throw new ArgumentException("Value cannot be null or empty.", nameof(Value));
            }

            ${VALIDATION_LOGIC}
        }

        /// <summary>
        /// Gets the atomic values for comparison.
        /// </summary>
        /// <returns>The atomic values.</returns>
        protected override IEnumerable<object> GetAtomicValues()
        {
            yield return Value;
            ${ATOMIC_VALUES}
        }

        /// <summary>
        /// Returns a string representation of the value object.
        /// </summary>
        /// <returns>A string representation.</returns>
        public override string ToString()
        {
            return Value;
        }
    }
}

