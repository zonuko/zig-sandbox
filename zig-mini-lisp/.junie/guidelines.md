# Zig Mini Lisp - Project Overview

## Introduction
Zig Mini Lisp is a minimalist Lisp interpreter implemented in the Zig programming language. This project demonstrates how to build a simple Lisp-like language interpreter while leveraging Zig's memory safety, performance, and low-level control.

## Project Architecture

### Core Components
1. **Tokenizer**: Parses Lisp syntax into tokens (numbers, symbols, parentheses)
2. **Parser**: Converts tokens into an abstract syntax tree
3. **Memory Management**: Uses a heap-based approach with classic Lisp cons cells (car/cdr pairs)
4. **Symbol Table**: Manages symbol resolution and association
5. **Evaluator**: Executes the parsed Lisp expressions

### Key Files
- `src/main.zig`: Main implementation file containing the interpreter logic with tests.
- `build.zig`: Build configuration for the project

## Building and Running

### Prerequisites
- Zig compiler (latest stable version recommended)

### Build Commands
```bash
# Build the project
zig build

# Run the application
zig build run

# Run with arguments
zig build run -- arg1 arg2

# Run tests
zig build test
```

## Features
- Basic Lisp syntax parsing
- Support for numeric literals and symbols
- Cons cell-based memory structure
- Simple symbol management

## Development Guidelines

### Code Style
- Follow the Zig style guide
- Use meaningful variable and function names
- Add comments for complex logic, especially in the parser and evaluator

### Testing
- Write unit tests for all new functionality
- Ensure tests cover edge cases in parsing and evaluation
- Run the test suite before submitting changes

### Memory Management
- Be mindful of the heap-based memory approach
- Ensure proper initialization and cleanup of memory cells
- Watch for potential memory leaks in the symbol table

## Future Enhancements
- Implement more Lisp built-in functions
- Add support for string literals
- Improve error handling and reporting
- Optimize memory usage
- Add a REPL (Read-Eval-Print Loop) interface

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License
This project is open source and available under the [MIT License](LICENSE).