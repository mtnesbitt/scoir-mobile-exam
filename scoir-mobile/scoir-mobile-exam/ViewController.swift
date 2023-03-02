//
//  ViewController.swift
//  scoir-mobile-exam
//
//  Created by Martin Nesbitt on 2/28/23.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
//    private let addRandomButton: UIBarButtonItem = {
//        let button = UIButton()
//        button.setTitle("Add random", for: .normal)
//        button.setTitleColor(.blue, for: .normal)
//        return button
//    }()
//
//    private let clearButton: UIButton = {
//        let clearButton = UIButton()
//        clearButton.setTitle("Clear", for: .normal)
//        clearButton.setTitleColor(.blue, for: .normal)
//        return clearButton
//    }()
    
    @IBOutlet weak var collectionView: UICollectionView!
    var dogImageURLs: [String] = []
    
    private let text: UITextView = {
        let text = UITextView()
        text.text = "There are currently no breeds. Search above to catch some."
        text.tag = 100
        return text
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addRandomButton = UIBarButtonItem(title: "Add Random", style: .plain, target: self, action: #selector(tapRandomButton))
        let clearButton = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(tapClearAllButton))
        
        navigationItem.leftBarButtonItem = addRandomButton
        navigationItem.rightBarButtonItem = clearButton
        
        addPlaceholderText()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DogCell.self, forCellWithReuseIdentifier: "DogCell")
        collectionView.contentInset = UIEdgeInsets(top: 100, left: 10, bottom: 10, right: 10)
    }
    
    @objc func tapRandomButton() {
        getRandomDog()
    }
    
    @objc func tapClearAllButton() {
        view.subviews.forEach({ $0.removeFromSuperview() })
        self.dogImageURLs.removeAll()
        viewDidLoad()
    }
    
    @objc func deleteButtonTapped(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? DogCell,
              let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        dogImageURLs.remove(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
    }
    
    func getRandomDog() {
        removePlaceholderText()
        let url = URL(string: "https://dog.ceo/api/breeds/image/random")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error while fetching data")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                print("Error, status code: \(httpResponse.statusCode)")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let imageUrl = json["message"] as! String
                self.dogImageURLs.append(imageUrl)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } catch let error {
                print("Unexpected error: ", error.localizedDescription)
            }
        }.resume()
    }
    
    func addPlaceholderText() {
        view.addSubview(text)
        text.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        text.center = view.center
    }
    
    func removePlaceholderText() {
        let placeholderText = self.view.subviews.first { $0.tag == 100 }
        placeholderText?.removeFromSuperview()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DogCell", for: indexPath) as! DogCell
            let imageUrl = dogImageURLs[indexPath.row]
            
            let task = URLSession.shared.dataTask(with: URL(string: imageUrl)!) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error while loading image, ", error?.localizedDescription ?? "")
                    return
                }
                
                DispatchQueue.main.async {
                    cell.imageView?.image = UIImage(data: data)
                }
            }
            
            task.resume()
            cell.deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
            return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dogImageURLs.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 30) / 2
        return CGSize(width: width, height: width)
    }
}

class DogCell: UICollectionViewCell {
    var imageView: UIImageView!
    var deleteButton: UIButton!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: contentView.bounds)
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(imageView)
        
        deleteButton = {
            let deleteButton = UIButton()
            deleteButton.setTitle("X", for: .normal)
            deleteButton.setTitleColor(.black, for: .normal)
            return deleteButton
        }()
        contentView.addSubview(deleteButton)
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




