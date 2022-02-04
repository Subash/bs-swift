import XCTest
@testable import BSDate

final class BSDateTests: XCTestCase {
  func testToBS() throws {
    let a = BSDate.toBS(Calendar.current.date(from: DateComponents(year: 1893, month: 4, day: 12))!)
    let b = BSDate.toBS(Calendar.current.date(from: DateComponents(year: 1893, month: 4, day: 13))!)

    let aResult = BSDate(year: 1950, month: 1, day: 1)
    let bResult = BSDate(year: 1950, month: 1, day: 2)

    XCTAssertEqual(a, aResult, "1893-04-12 AD -> 1950-01-01 BS")
    XCTAssertEqual(b, bResult, "1893-04-12 AD -> 1950-01-02 BS")
  }

  func testToAD() throws {
    let a = BSDate.toAD(BSDate(year: 1976, month: 9, day: 16))
    let b = BSDate.toAD(BSDate(year: 1976, month: 9, day: 17))
    let c = BSDate.toAD(BSDate(year: 2000, month: 1, day: 2))
    let d = BSDate.toAD(BSDate(year: 2072, month: 6, day: 3))
    let e = BSDate.toAD(BSDate(year: 2089, month: 12, day: 30))

    let aResult = Calendar.current.date(from: DateComponents(year: 1919, month: 12, day: 31))!
    let bResult = Calendar.current.date(from: DateComponents(year: 1920, month: 1, day: 1))!
    let cResult = Calendar.current.date(from: DateComponents(year: 1943, month: 4, day: 15))!
    let dResult = Calendar.current.date(from: DateComponents(year: 2015, month: 9, day: 20))!
    let eResult = Calendar.current.date(from: DateComponents(year: 2033, month: 4, day: 12))!

    XCTAssertEqual(a, aResult, "1976-09-16 BS -> 1919-12-31 AD")
    XCTAssertEqual(b, bResult, "1976-09-17 BS -> 1920-01-01 AD")
    XCTAssertEqual(c, cResult, "2000-01-02 BS -> 1943-04-15 AD")
    XCTAssertEqual(d, dResult, "2072-06-03 BS -> 2015-09-20 AD")
    XCTAssertEqual(e, eResult, "2089-12-30 BS -> 2033-04-12 AD")
  }

  func testEqual() throws {
    let a = BSDate(year: 1976, month: 9, day: 16) == BSDate(year: 1976, month: 9, day: 16)
    let b = BSDate(year: 1976, month: 9, day: 16) == BSDate(year: 1976, month: 9, day: 17)
    XCTAssertTrue(a)
    XCTAssertFalse(b)
  }
}
