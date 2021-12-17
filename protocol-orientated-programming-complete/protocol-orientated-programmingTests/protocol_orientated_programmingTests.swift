//
//  protocol_orientated_programmingTests.swift
//  protocol-orientated-programmingTests
//
//  Created by Kelvin Fok on 18/12/21.
//

import XCTest
@testable import protocol_orientated_programming

class protocol_orientated_programmingTests: XCTestCase {
  
  private var sut: UserViewModel!
  private var userService: MockUserService!
  private var output: MockUserViewModelOutput!
  
  override func setUpWithError() throws {
    output = MockUserViewModelOutput()
    userService = MockUserService()
    sut = UserViewModel(userService: userService)
    sut.output = output
    try super.setUpWithError()
  }
  
  override func tearDownWithError() throws {
    sut = nil
    userService = nil
    try super.tearDownWithError()
  }
  
  func testUpdateView_onAPISuccess_showsImageAndEmail() {
    // given
    let user = User(id: 1, email: "me@gmail.com", avatar: "https://www.picsum.com/2")
    userService.fetchUserMockResult = .success(user)
    // when
    sut.fetchUser()
    // then
    XCTAssertEqual(output.updateViewArray.count, 1)
    XCTAssertEqual(output.updateViewArray[0].email, "me@gmail.com")
    XCTAssertEqual(output.updateViewArray[0].imageUrl, "https://www.picsum.com/2")
  }
  
  func testUpdateView_onAPIFailure_showsErrorImageAndDefaultNoUserFoundText() {
    // given
    userService.fetchUserMockResult = .failure(NSError())
    // when
    sut.fetchUser()
    // then
    XCTAssertEqual(output.updateViewArray.count, 1)
    XCTAssertEqual(output.updateViewArray[0].email, "No user found")
    XCTAssertEqual(output.updateViewArray[0].imageUrl, "https://www.picsum.com/2")

  }
  
}

class MockUserService: UserService {
  var fetchUserMockResult: Result<User, Error>?
  func fetchUser(completion: @escaping (Result<User, Error>) -> Void) {
    if let result = fetchUserMockResult {
      completion(result)
    }
  }
}

class MockUserViewModelOutput: UserViewModelOutput {
  var updateViewArray: [(imageUrl: String, email: String)] = []
  func updateView(imageUrl: String, email: String) {
    updateViewArray.append((imageUrl, email))
  }
}
