
import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    @Binding var userName: String // ✅ Accept userName

    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraVC = CameraViewController()
        cameraVC.userName = userName // ✅ Pass userName to CameraViewController
        return cameraVC
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        uiViewController.userName = userName // ✅ Ensure userName stays updated
    }
}
