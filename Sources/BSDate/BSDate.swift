import Foundation

public struct BSDate: RawRepresentable, Equatable, Comparable {
  public var rawValue: String {
    willSet {
      precondition(Self.isValid(rawValue: newValue), "Invalid Date")
    }
  }

  // MARK: Initializers

  public init(year: Int, month: Int, day: Int) {
    precondition(Self.isValid(year: year, month: month, day: day), "Invalid Date")
    self.rawValue = String(format: "%04d-%02d-%02d", year, month, day)
  }

  public init?(rawValue: String) {
    guard Self.isValid(rawValue: rawValue) else { return nil }
    self.rawValue = rawValue
  }

  public init?(_ rawValue: String) {
    guard Self.isValid(rawValue: rawValue) else { return nil }
    self.rawValue = rawValue
  }

  // MARK: Computed Properties

  public var year: Int {
    return Int(rawValue.prefix(4))!
  }

  public var month: Int {
    return Int(rawValue.dropFirst(5).prefix(2))!
  }

  public var day: Int {
    return Int(rawValue.dropFirst(8).prefix(2))!
  }

  public var monthName: String {
    let monthNames = [
      "Baishakh", "Jestha", "Asar", "Shrawan", "Bhadra", "Ashoj",
      "Kartik", "Mangsir", "Poush", "Magh", "Falgun", "Chaitra"
    ]

    return monthNames[self.month - 1]
  }

  public var ad: Date {
    return Self.toAD(self)
  }

  // MARK: Comparators

  public static func == (lhs: BSDate, rhs: BSDate) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }

  public static func < (lhs: BSDate, rhs: BSDate) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }

  // MARK: Validation

  private static func isValid(year: Int, month: Int, day: Int) -> Bool {
    return (
      Self.calendar.map(\.key).contains(year) &&
      (1...12).contains(month) &&
      day > 0 &&
      day <= Self.lastDay(year: year, month: month)!
    )
  }

  private static func isValid(rawValue: String) -> Bool {
    // must be in YYYY-MM-DD format
    guard rawValue.range(of: "^\\d{4}-\\d{2}-\\d{2}", options: .regularExpression, range: nil, locale: nil) != nil else {
      return false
    }

    return Self.isValid(
      year: Int(rawValue.prefix(4))!,
      month: Int(rawValue.dropFirst(5).prefix(2))!,
      day: Int(rawValue.dropFirst(8).prefix(2))!
    )
  }

  // MARK: Conversion

  public static func toBS(_ date: Date) -> BSDate? {
    guard date >= Self.calendarStartDate else { return nil }

    let calendar = Self.calendar.flatMap(\.value)
    let totalDifferenceInDays = Calendar.current.dateComponents([.day], from: Self.calendarStartDate, to: date).day!

    var totalDays = 0
    for (monthIndex, days) in calendar.enumerated() {
      if totalDays + days <= totalDifferenceInDays {
        totalDays += days
      } else {
        let yearIndex = monthIndex / 12
        let monthIndex = monthIndex % 12
        let differenceInDays = totalDifferenceInDays - totalDays

        let year = Self.calendar.first!.key + yearIndex
        let month = monthIndex + 1
        let day = differenceInDays + 1

        return BSDate(year: year, month: month, day: day)
      }
    }

    return nil
  }

  public static func toAD(_ bsDate: BSDate) -> Date {
    let calendar = Self.calendar.flatMap(\.value)

    let monthIndex = bsDate.month - 1 // convert month number to array index
    let yearIndex = bsDate.year - Self.calendar.first!.key // convert year number to calendar KeyValuePair index
    let months = calendar.prefix(upTo: yearIndex * 12 + monthIndex)

    let totalDays = months.reduce(bsDate.day, +)
    let differenceInDays = totalDays - 1

    return Calendar.current.date(byAdding: .day, value: differenceInDays, to: Self.calendarStartDate)!
  }

  public static func lastDay(year: Int, month: Int) -> Int? {
    let monthIndex = month - 1
    let months = Self.calendar.first { $0.key == year }?.value
    guard let months = months else { return nil }
    guard months.indices.contains(monthIndex) else { return nil }
    return months[monthIndex]
  }

  // MARK: Calendar Data
  // scrapped from https://nepalipatro.com.np

  private static var calendarStartDate: Date {
    return Calendar.current.date(from: DateComponents(year: 1893, month: 4, day: 12))! // 1950-01-01 BS
  }

  private static var calendar: KeyValuePairs = [
    1950: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
    1951: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    1952: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    1953: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    1954: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    1955: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    1956: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    1957: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    1958: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    1959: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    1960: [31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    1961: [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    1962: [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    1963: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    1964: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    1965: [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    1966: [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    1967: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    1968: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    1969: [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    1970: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    1971: [31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
    1972: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    1973: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    1974: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    1975: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    1976: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    1977: [30, 32, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
    1978: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    1979: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    1980: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    1981: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
    1982: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    1983: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    1984: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    1985: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    1986: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    1987: [31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    1988: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    1989: [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    1990: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    1991: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    1992: [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    1993: [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    1994: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    1995: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    1996: [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    1997: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    1998: [31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
    1999: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2000: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2001: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2002: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2003: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2004: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2005: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2006: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2007: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2008: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
    2009: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2010: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2011: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2012: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2013: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2014: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2015: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2016: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2017: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2018: [31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2019: [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2020: [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2021: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2022: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2023: [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2024: [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2025: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2026: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2027: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2028: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2029: [31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
    2030: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2031: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2032: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2033: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2034: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2035: [30, 32, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
    2036: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2037: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2038: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2039: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2040: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2041: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2042: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2043: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2044: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2045: [31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2046: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2047: [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2048: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2049: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2050: [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2051: [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2052: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2053: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2054: [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2055: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2056: [31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
    2057: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2058: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2059: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2060: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2061: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2062: [30, 32, 31, 32, 31, 31, 29, 30, 29, 30, 29, 31],
    2063: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2064: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2065: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2066: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
    2067: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2068: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2069: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2070: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2071: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2072: [31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2073: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2074: [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2075: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2076: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2077: [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2078: [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2079: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2080: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
    2081: [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2082: [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
    2083: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2084: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2085: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2086: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2087: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2088: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2089: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
    2090: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2091: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2092: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2093: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
    2094: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2095: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2096: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
    2097: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
    2098: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
    2099: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
    2100: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31]
  ]
}

extension BSDate {
  public struct Duration {
    public var years: Int
    public var months: Int
    public var days: Int

    public init(years: Int, months: Int, days: Int) {
      self.years = years
      self.months = months
      self.days = days
    }

    public static func zero() -> Duration {
      return Duration(years: 0, months: 0, days: 0)
    }
  }

  public static func duration(from: BSDate, to: BSDate) -> Duration {
    precondition(from <= to, "from date must be before to date.")
    var years = to.year - from.year

    var months = to.month - from.month
    if to.month < from.month {
      years = years - 1; // borrow a year
      months = to.month + 12 - from.month
    }

    var days = to.day - from.day
    if to.day < from.day {
      months = months - 1; // borrow a month

      var borrowedYear = to.year
      var borrowedMonth = to.month - 1

      if to.month == 1 {
        borrowedYear = to.year - 1
        borrowedMonth = 12
      }

      let lastDayOfPreviousMonth = Self.lastDay(year: borrowedYear, month: borrowedMonth)!
      var totalDays = to.day + lastDayOfPreviousMonth

      if from.day > totalDays { // can happen when borrowed days are not enough. eg: 2078-06-31 -> 2078-09-01
        totalDays = totalDays + (from.day - lastDayOfPreviousMonth)
      }

      days = totalDays - from.day
    }

    return Duration(years: years, months: months, days: days)
  }
}
