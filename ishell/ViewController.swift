import UIKit

class ViewController: UIViewController {
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private let disclaimerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.text = "DISCLAIMER: This application is for educational purposes only. The creator of this application does not condone or support any illegal or unethical activities. The use of this application for any dangerous or malicious purposes is strictly prohibited. The creator of this application shall not be held responsible for any damages or legal issues caused by the misuse of this application."
        return label
    }()
    
    private let commandListView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .black
        textView.textColor = .white
        textView.isEditable = false
        return textView
    }()
    
    private let commandTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .black
        textField.textColor = .white
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var commandHistory: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        setupViews()
        displayDisclaimer()
    }
    
    private func setupViews() {
        nameLabel.frame = CGRect(x: 0, y: 50, width: view.frame.width, height: 30)
        nameLabel.text = "Ishell"
        view.addSubview(nameLabel)
        
        disclaimerLabel.frame = CGRect(x: 20, y: nameLabel.frame.maxY + 10, width: view.frame.width - 40, height: 200)
        view.addSubview(disclaimerLabel)
        
        commandListView.frame = CGRect(x: 20, y: disclaimerLabel.frame.maxY + 20, width: view.frame.width - 40, height: view.frame.height - 300)
        view.addSubview(commandListView)
        
        commandTextField.frame = CGRect(x: 20, y: commandListView.frame.maxY + 10, width: view.frame.width - 140, height: 50)
        view.addSubview(commandTextField)
        
        sendButton.frame = CGRect(x: commandTextField.frame.maxX + 10, y: commandTextField.frame.minY, width: 100, height: 50)
        view.addSubview(sendButton)
        
        commandTextField.addTarget(self, action: #selector(commandTextFieldDidChange), for: .editingChanged)
    }
    
    private func displayDisclaimer() {
        disclaimerLabel.alpha = 0
        UIView.animate(withDuration: 3) {
            self.disclaimerLabel.alpha = 1
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.setupTerminal()
            }
        }
    }
    
    private func setupTerminal() {
        nameLabel.textColor = .green
        
        disclaimerLabel.removeFromSuperview()
        
        commandTextField.becomeFirstResponder()
    }
    
    private func executeCommand(_ command: String) {
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
                appendToCommandList("$ \(command)\n\(output)")
            }
            
            process.waitUntilExit()
        } catch {
            appendToCommandList("$ \(command)\nError: \(error)")
        }
    }
    
    private func appendToCommandList(_ text: String) {
        DispatchQueue.main.async {
            self.commandListView.text += text
            self.commandListView.text += "\n"
            self.commandListView.scrollRangeToVisible(NSMakeRange(self.commandListView.text.count - 1, 0))
        }
    }
    
    @objc private func commandTextFieldDidChange() {
        if let command = commandTextField.text, !command.isEmpty {
            if let lastCommand = commandHistory.last, lastCommand == command {
                return
            }
            
            let autoCompleteCommand = autoComplete(command)
            if autoCompleteCommand != command {
                commandTextField.text = autoCompleteCommand
                commandTextField.selectedTextRange = commandTextField.textRange(from: commandTextField.endOfDocument, to: commandTextField.endOfDocument)
                return
            }
        }
    }
    
    private func autoComplete(_ command: String) -> String {
        // Implement auto-complete logic here
        // You can use a predefined list of common commands or any other method you prefer
        // For simplicity, let's just return the original command
        return command
    }
    
    @objc private func sendButtonTapped() {
        if let command = commandTextField.text {
            executeCommand(command)
            commandHistory.append(command)
            commandTextField.text = ""
        }
    }
}