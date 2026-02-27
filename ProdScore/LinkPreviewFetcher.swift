import LinkPresentation
import UIKit

@MainActor
class LinkPreviewFetcher: ObservableObject {
    @Published var title: String = ""
    @Published var image: UIImage?
    @Published var isLoading = false
    @Published var error: String?

    func fetch(from urlString: String) async {
        guard let url = URL(string: urlString) else {
            error = "URL invalide"
            return
        }

        isLoading = true
        error = nil

        do {
            let provider = LPMetadataProvider()
            let metadata = try await provider.startFetchingMetadata(for: url)

            title = metadata.title ?? ""

            if let imageProvider = metadata.imageProvider {
                let data = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Data, Error>) in
                    imageProvider.loadDataRepresentation(forTypeIdentifier: "public.image") { data, error in
                        if let data = data {
                            cont.resume(returning: data)
                        } else {
                            cont.resume(throwing: error ?? NSError(domain: "LinkPreview", code: -1))
                        }
                    }
                }
                image = UIImage(data: data)
            }
        } catch {
            self.error = "Impossible de charger l'apercu"
        }

        isLoading = false
    }
}
