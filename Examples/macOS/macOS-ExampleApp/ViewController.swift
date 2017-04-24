

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let x = NSBox(frame: NSRect(x: 10, y: 10, width: 100, height: 100))
        x.fillColor = NSColor.red
        
        self.view.addSubview(x)

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
        
    }

    

}

