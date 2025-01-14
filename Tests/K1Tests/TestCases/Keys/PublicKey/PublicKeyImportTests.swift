import Foundation
@testable import LCLK1
import XCTest

final class PublicKeyImportTests: XCTestCase {
	func testAssertImportingPublicKeyWithTooFewBytesThrowsError() throws {
		let raw = try Data(hex: "deadbeef")
		try assert(
			K1.ECDSA.PublicKey(x963Representation: raw),
			throws: K1.Error.incorrectKeySize
		)
	}

	func testAssertImportingPublicKeyWithTooManyBytesThrowsError() throws {
		let raw = Data(repeating: 0xDE, count: 66)
		try assert(
			K1.ECDSA.PublicKey(x963Representation: raw),
			throws: K1.Error.incorrectKeySize
		)
	}

	func testAssertImportingInvalidUncompressedPublicKeyThrowsError() throws {
		let raw = Data(repeating: 0x04, count: 65)
		try assert(
			K1.ECDSA.PublicKey(x963Representation: raw),
			throws: K1.Error.underlyingLibsecp256k1Error(.publicKeyParse)
		)
	}

	func testAssertImportingInvalidCompressedPublicKeyThrowsError() throws {
		let raw = Data(repeating: 0x03, count: 33)
		try assert(
			K1.ECDSA.PublicKey(compressedRepresentation: raw),
			throws: K1.Error.underlyingLibsecp256k1Error(.publicKeyParse)
		)
	}

	func testAssertImportValidPublicKeyWorks() throws {
		let raw = Data(repeating: 0x02, count: 33)
		let publicKey = try K1.ECDSA.PublicKey(compressedRepresentation: raw)
		XCTAssertEqual(publicKey.compressedRepresentation.hex, "020202020202020202020202020202020202020202020202020202020202020202")
		XCTAssertEqual(publicKey.x963Representation.hex, "040202020202020202020202020202020202020202020202020202020202020202415456f0fc01d66476251cab4525d9db70bfec652b2d8130608675674cde64b2")
	}

	func test_compress_pubkey() throws {
		let raw = Data(repeating: 0x02, count: 33)
		let publicKey = try K1.ECDSA.PublicKey(compressedRepresentation: raw)
		XCTAssertEqual(publicKey.compressedRepresentation.hex, "020202020202020202020202020202020202020202020202020202020202020202")
		XCTAssertEqual(publicKey.x963Representation.hex, "040202020202020202020202020202020202020202020202020202020202020202415456f0fc01d66476251cab4525d9db70bfec652b2d8130608675674cde64b2")
	}

	func testNotOnCurve() throws {
		/// Public key from `ecdh_secp256k1_test.json` in Wycheproof
		/// Vector id: 185
		/// With "comment" : "point is not on curve"
		/// DER => raw
		let raw = try Data(hex: "040000000000000000000000000000000000000000000000000000000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2e")

		try assert(
			K1.ECDSA.PublicKey(x963Representation: raw),
			throws: K1.Error.underlyingLibsecp256k1Error(.publicKeyParse)
		)
	}
}
