## Overview
Everything in this project is related to game development using the Godot game engine with GDScript.

All code should follow the GDScript style guide and best practices.

!Important: Don't add extraneous comments or documentation!
!Important: Always follow the style guide!

## Generated files
Godot automatically creates all files that end with the .uid file extension.  They should never be created or edited manually.

## Formatting
- The GDScript style guide can be found at https://docs.godotengine.org/en/4.4/tutorials/scripting/gdscript/gdscript_styleguide.html
- Follow the style guide with these exceptions:
  - Don't add class comments
- In addition to the style guide, follow these conventions:
  - alphabetize class members within their groups (signals, exported variables, regular variables, life-cycle methods, public methods, private methods, etc)

## Dictionaries
When working with dicionaries, use the following conventions:
- Prefer strongly-typed dictionaries over untyped ones. (e.g. Dictionary[String, int] instead of Dictionary)
- Prefer to use .get() and .set() methods for accessing dictionary values instead of using the [] operator.

## Testing
! Important: All tests should pass after making changes to test files !

To run the tests, use this terminal command (includes timeout to prevent hanging on syntax errors):
`.\run_tests_quick.ps1`

### Test Framework
This project uses **GUT (Godot Unit Test)** for unit testing. GUT is the standard testing framework for Godot projects.

- **Documentation**: https://gut.readthedocs.io/en/latest/
- **GitHub Repository**: https://github.com/bitwes/Gut

### Test Structure
- All tests are located in the `tests/` directory
- Test files follow the naming convention `test_*.gd`
- All test classes extend `GutTest`
- Use `before_each()` and `after_each()` methods for test setup and cleanup
- Use the arrange/act/assert pattern for writing tests.  Always include a comment above each section in lowercase, e.g. `# arrange`, `# act`, `# assert`

### Test Writing Conventions
- Use descriptive test method names starting with `test_`
- Follow Arrange-Act-Assert pattern in test methods
- Use GUT's assertion methods like `assert_eq()`, `assert_true()`, `assert_null()`, etc.
- Clean up resources in `after_each()` to prevent test pollution
- Add meaningful print statements for test feedback

### Example Test Structure
```gdscript
extends GutTest

var test_node

func before_each():
    test_node = Node.new()
    add_child(test_node)

func after_each():
    if is_instance_valid(test_node):
        test_node.queue_free()

func test_example_functionality():
    # Arrange
    var expected_value = "test"
    
    # Act
    var result = some_function(expected_value)
    
    # Assert
    assert_eq(result, expected_value, "Function should return the input value")
```

### Validation
When writing new tests, always validate they work by running them via command line to ensure they pass in headless mode (important for CI/CD).