## Overview
Everything in this project is related to game development using the Godot game engine with GDScript.

## CRITICAL REQUIREMENTS
🚨 **MANDATORY: ALL CODE MUST STRICTLY FOLLOW THE GDSCRIPT STYLE GUIDE** 🚨
- **NEVER** write or modify code without adhering to GDScript style conventions
- **ALWAYS** apply the official GDScript style guide to every single line of code
- **EVERY** variable, function, class, and file must follow GDScript naming conventions
- **ZERO EXCEPTIONS** - this is non-negotiable for this project
- **NEVER** Add extraneous comments or documentation

!Important: Always use the GDScript style guide when modifying code!
!Important: Before writing any code, mentally review GDScript style requirements!

## Generated files
Godot automatically creates all files that end with the .uid file extension.  They should never be created or edited manually.

## Formatting and Style (MANDATORY)
### GDScript Style Guide Compliance
- **PRIMARY REFERENCE**: https://docs.godotengine.org/en/4.4/tutorials/scripting/gdscript/gdscript_styleguide.html
- **MUST FOLLOW**: Every aspect of the official GDScript style guide
- **KEY REQUIREMENTS**:
  - Variables: `snake_case` (e.g., `player_health`, `max_speed`)
  - Functions: `snake_case` (e.g., `get_player_position()`, `calculate_damage()`)
  - Constants: `UPPER_SNAKE_CASE` (e.g., `MAX_HEALTH`, `DEFAULT_SPEED`)
  - Classes: `PascalCase` (e.g., `PlayerController`, `GameManager`)
  - Files: `snake_case.gd` (e.g., `player_controller.gd`, `game_manager.gd`)
  - Signals: `snake_case` (e.g., `health_changed`, `player_died`)
  - Enums: `PascalCase` with `UPPER_SNAKE_CASE` values
  - Private members: prefix with `_` (e.g., `_internal_state`, `_calculate_private()`)

### Project-Specific Style Exceptions
- Don't add class comments (deviation from style guide)

### Additional Conventions
- Alphabetize class members within their groups (signals, exported variables, regular variables, life-cycle methods, public methods, private methods, etc)

## Dictionaries
When working with dicionaries, use the following conventions:
- Prefer strongly-typed dictionaries over untyped ones. (e.g. Dictionary[String, int] instead of Dictionary)
- Prefer to use .get() and .set() methods for accessing dictionary values instead of using the [] operator.

## Testing
! Important: All tests should pass after making changes to test files !

To run the tests, use this terminal command (includes timeout to prevent hanging on syntax errors):
`.\run_tests.ps1`

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