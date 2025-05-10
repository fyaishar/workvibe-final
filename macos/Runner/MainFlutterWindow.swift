import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    
    // Configure window to have no title bar but keep traffic light controls
    self.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
    self.titlebarAppearsTransparent = true
    self.titleVisibility = .hidden
    self.isMovableByWindowBackground = true
    
    // Set default window padding to accommodate traffic lights
    flutterViewController.view.wantsLayer = true
    flutterViewController.view.layer?.position.y = 12 // Adjust this value if needed
    
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
