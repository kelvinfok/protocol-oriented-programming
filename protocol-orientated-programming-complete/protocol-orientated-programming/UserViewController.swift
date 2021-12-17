//
//  ViewController.swift
//  protocol-orientated-programming
//
//  Created by Kelvin Fok on 17/12/21.
//

import UIKit

protocol UserViewModelOutput: AnyObject {
  func updateView(imageUrl: String, email: String)
}

class UserViewModel {
  
  weak var output: UserViewModelOutput?
  private let userService: UserService
  
  init(userService: UserService) {
    self.userService = userService
  }
  
  func fetchUser() {
    userService.fetchUser { [weak self] result in
      switch result {
      case .success(let user):
        self?.output?.updateView(imageUrl: user.avatar, email: user.email)
      case .failure:
        let errorImageUrl = "https://cdn1.iconfinder.com/data/icons/user-fill-icons-set/144/User003_Error-1024.jpg"
        self?.output?.updateView(imageUrl: errorImageUrl, email: "No user found")
      }
    }
  }
  
}

class UserViewController: UIViewController, UserViewModelOutput {
    
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private let emailLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
    
  private let viewModel: UserViewModel
  
  init(viewModel: UserViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    self.viewModel.output = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    fetchUsers()
  }
  
  private func setupViews() {
    view.backgroundColor = .white
    
    view.addSubview(imageView)
    view.addSubview(emailLabel)
    
    NSLayoutConstraint.activate([
      imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      imageView.heightAnchor.constraint(equalToConstant: 100),
      imageView.widthAnchor.constraint(equalToConstant: 100),
      imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 64),
      
      emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      emailLabel.heightAnchor.constraint(equalToConstant: 56),
      emailLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4)
    ])
  }
  
  private func fetchUsers() {
    viewModel.fetchUser()
  }
  
  // MARK: - UserViewModelOutput
  func updateView(imageUrl: String, email: String) {
    let imageData = try! NSData(contentsOf: .init(string: imageUrl)!) as Data
    self.imageView.image = UIImage(data: imageData)
    self.emailLabel.text = email
  }
}

protocol UserService {
  func fetchUser(completion: @escaping (Result<User, Error>) -> Void)
}

class APIManager: UserService {
  
  func fetchUser(completion: @escaping (Result<User, Error>) -> Void) {
    
    let url = URL(string: "https://reqres.in/api/users/3")!
    
    URLSession.shared.dataTask(with: url) { data, res, error in
      guard let data = data else { return }
      DispatchQueue.main.async {
        if let user = try? JSONDecoder().decode(UserResponse.self, from: data).data {
          completion(.success(user))
        } else {
          completion(.failure(NSError()))
        }
      }
    }.resume()
  }
}

struct UserResponse: Decodable {
  let data: User
}

struct User: Decodable {
  let id: Int
  let email: String
  let avatar: String
}
