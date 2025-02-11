import Foundation
@testable import LCLK1
import XCTest

// MARK: - PrivateKeyEncodingTests
final class PrivateKeyEncodingTests: XCTestCase {
	func testRawRoundtrip() throws {
		try doTest(
			serialize: \.rawRepresentation,
			deserialize: K1.ECDSA.PrivateKey.init(rawRepresentation:)
		)
	}

	func testx963Roundtrip() throws {
		try doTest(
			serialize: \.x963Representation,
			deserialize: K1.ECDSA.PrivateKey.init(x963Representation:)
		)
	}

	func testDERRoundtrip() throws {
		try doTest(
			serialize: \.derRepresentation,
			deserialize: K1.ECDSA.PrivateKey.init(derRepresentation:)
		)
	}

	func testPEMRoundtrip() throws {
		try doTest(
			serialize: \.pemRepresentation,
			deserialize: K1.ECDSA.PrivateKey.init(pemRepresentation:)
		)
	}
}

private extension PrivateKeyEncodingTests {
	func doTest<Enc: Equatable>(
		serialize: KeyPath<K1.ECDSA.PrivateKey, Enc>,
		deserialize: (Enc) throws -> K1.ECDSA.PrivateKey
	) throws {
		try doTestSerializationRoundtrip(
			original: K1.ECDSA.PrivateKey(),
			serialize: serialize,
			deserialize: deserialize
		)
	}
}
