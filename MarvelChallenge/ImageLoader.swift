import UIKit

protocol ImageLoading {
    @discardableResult
    func load(_ url: URL, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask?
}

final class ImageLoader: ImageLoading {
    static let shared = ImageLoader()
    private let cache = NSCache<NSURL, UIImage>()
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    @discardableResult
    func load(_ url: URL, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask? {
        if let image = cache.object(forKey: url as NSURL) {
            completion(image)
            return nil
        }
        let task = session.dataTask(with: url) { [weak self] data, _, _ in
            let image = data.flatMap(UIImage.init(data:))
            if let image = image { self?.cache.setObject(image, forKey: url as NSURL) }
            DispatchQueue.main.async { completion(image) }
        }
        task.resume()
        return task
    }
}

extension UIImageView {
    func setImage(from url: URL?, placeholder: UIImage?, loader: ImageLoading = ImageLoader.shared) {
        image = placeholder
        guard let url = url else { return }
        loader.load(url) { [weak self] image in
            self?.image = image ?? placeholder
        }
    }
}
