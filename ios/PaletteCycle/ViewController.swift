import UIKit

class ViewController: UIViewController, PaletteCycleEngineDelegate, ImageLoadedListener {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionPicker: UIPickerView!
    @IBOutlet weak var imagePicker: UIPickerView!
    @IBOutlet weak var playPauseButton: UIButton!
    
    private let engine = PaletteCycleEngine()
    private let imageLoader = ImageLoader()
    private var collections: [ImageCollection] = []
    private var selectedCollection: ImageCollection?
    private var isPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        engine.delegate = self
        imageLoader.addListener(self)
        
        loadCollections()
        
        // Start with the first collection
        if !collections.isEmpty {
            selectCollection(at: 0)
        }
    }
    
    private func setupUI() {
        title = "Palette Cycle"
        
        // Configure image view
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        
        // Configure pickers
        collectionPicker.delegate = self
        collectionPicker.dataSource = self
        imagePicker.delegate = self
        imagePicker.dataSource = self
        
        // Configure play/pause button
        playPauseButton.setTitle("▶️ Play", for: .normal)
        playPauseButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        
        // Add settings button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Settings",
            style: .plain,
            target: self,
            action: #selector(showSettings)
        )
    }
    
    private func loadCollections() {
        collections = imageLoader.getImageCollections() + imageLoader.getTimelineCollections()
        
        DispatchQueue.main.async {
            self.collectionPicker.reloadAllComponents()
        }
    }
    
    private func selectCollection(at index: Int) {
        guard index < collections.count else { return }
        
        selectedCollection = collections[index]
        
        DispatchQueue.main.async {
            self.imagePicker.reloadAllComponents()
            if let collection = self.selectedCollection, !collection.images.isEmpty {
                self.imagePicker.selectRow(0, inComponent: 0, animated: true)
                self.selectImage(at: 0)
            }
        }
    }
    
    private func selectImage(at index: Int) {
        guard let collection = selectedCollection,
              index < collection.images.count else { return }
        
        let image = collection.images[index]
        imageLoader.loadImage(image) { [weak self] imageJson in
            guard let self = self, let imageJson = imageJson else { return }
            
            DispatchQueue.main.async {
                self.engine.setImage(imageJson)
                if self.isPlaying {
                    self.engine.start()
                }
            }
        }
    }
    
    @objc private func togglePlayPause() {
        isPlaying.toggle()
        
        if isPlaying {
            engine.start()
            playPauseButton.setTitle("⏸️ Pause", for: .normal)
        } else {
            engine.stop()
            playPauseButton.setTitle("▶️ Play", for: .normal)
        }
    }
    
    @objc private func showSettings() {
        let alert = UIAlertController(title: "Settings", message: "Palette Cycle Settings", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Preload Images", style: .default) { _ in
            self.imageLoader.preloadImages()
        })
        
        alert.addAction(UIAlertAction(title: "About", style: .default) { _ in
            self.showAbout()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showAbout() {
        let alert = UIAlertController(
            title: "About Palette Cycle",
            message: """
            Features include:
            
            • Over 20 images that match the current time of day
            • 7 collections that change images based on the time of day  
            • Over 35 standalone animated images, as well as several still images
            • Pan and zoom to show only part of an image
            • Enable parallax to use the whole image
            • Download only the images you use
            
            Art created by Mark Ferrari. Code based on Joseph Huckaby's website code (including his blendshift technology).
            
            iOS version by PiousDeer.
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - PaletteCycleEngineDelegate
    
    func paletteCycleEngineDidUpdate(_ engine: PaletteCycleEngine) {
        if let bitmap = engine.getCurrentBitmap() {
            DispatchQueue.main.async {
                self.imageView.image = bitmap
            }
        }
    }
    
    // MARK: - ImageLoadedListener
    
    func imageLoadComplete(image: ImageInfo) {
        print("Image loaded: \(image.name)")
    }
}

// MARK: - UIPickerViewDataSource & Delegate

// MARK: - UIPickerViewDataSource & Delegate

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == collectionPicker {
            return collections.count
        } else if pickerView == imagePicker {
            return selectedCollection?.images.count ?? 0
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == collectionPicker {
            return collections[row].name
        } else if pickerView == imagePicker {
            return selectedCollection?.images[row].name ?? ""
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == collectionPicker {
            selectCollection(at: row)
        } else if pickerView == imagePicker {
            selectImage(at: row)
        }
    }
}