import Foundation

// Define a list of commonly used commands
let commonCommands = ["ls", "cd", "mkdir", "touch", "rm", "cp", "mv"]

// Define a function to handle user input and execute commands
func executeCommand(_ command: String) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", command]
    
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    
    do {
        try process.run()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            print(output)
        }
        
        process.waitUntilExit()
    } catch {
        print("Error: \(error)")
    }
}

// Define a function to handle auto-complete
func autoComplete(_ command: String) -> String {
    for commonCommand in commonCommands {
        if command.hasPrefix(commonCommand) {
            // Return the common command plus a space
            return commonCommand + " "
        }
    }
    // Default to returning the original command
    return command
}

// Define a function to handle command history
func commandHistory(_ history: inout [String], _ command: String) -> [String] {
    // Add the command to the history
    history.append(command)
    // If the history has reached the maximum size, remove the oldest command
    if history.count > 10 {
        history.removeFirst()
    }
    // Return the updated history
    return history
}

// Define a function to generate the writing of the application name "Ishell"
func generateWriting(_ name: String, delay: TimeInterval = 0.1) {
    for letter in name {
        print(letter, terminator: "")
        Thread.sleep(forTimeInterval: delay)
    }
    print()
}

// Define a function to display the disclaimer
func displayDisclaimer() {
    print("DISCLAIMER: This application is for educational purposes only. The creator of this application does not condone or support any illegal or unethical activities. The use of this application for any dangerous or malicious purposes is strictly prohibited. The creator of this application shall not be held responsible for any damages or legal issues caused by the misuse of this application.")
}

// Define a loop to continuously prompt the user for input and execute commands
var history: [String] = []
while true {
    // Generate the writing of the application name
    generateWriting("Ishell: The first shell for iOS devices")

    // Display the disclaimer only on the first run
    if history.isEmpty {
        displayDisclaimer()
    }

    // Prompt the user for input
    print("$ ", terminator: "")
    if let command = readLine() {
        // Handle auto-complete
        let autoCompleteCommand = autoComplete(command)

        // Handle command history
        history = commandHistory(&history, autoCompleteCommand)

        // Execute the command
        executeCommand(autoCompleteCommand)
    }
}
