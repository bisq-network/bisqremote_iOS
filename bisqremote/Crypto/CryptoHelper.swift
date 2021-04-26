//
//  CryptoHelper.swift
//  LionsAttendance
//
//  Created by Mata Prasad Chauhan on 01/11/17.
//

import Foundation
import CryptoSwift

class CryptoHelper{
    
    public static var iv: String = ""
    public static var key = ""
    
    public static func encrypt(input:String)->String?{
        do {
            if iv.count != 16 {
                fatalError("iv not 16 characters")
            }
            if key.count != 32 {
                fatalError("key not 32 characters")
            }
            let encrypted: Array<UInt8> = try AES(key: key, iv: iv, padding: .noPadding).encrypt(Array(input.utf8))
            return encrypted.toBase64()
        } catch {
            fatalError("could not encrypt")
        }
    }
    
    public static func decrypt(input:String)->String?{
        do {
            if iv.count != 16 {
                fatalError("iv not 16 characters")
            }
            if key.count != 32 {
                fatalError("key not 32 characters")
            }
            let d = Data(base64Encoded: input, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)
            if d == nil {
                fatalError("message not Base64")
            }
            let aes: AES = try AES(key: key, iv: iv, padding: .pkcs5)
            let db = d!.bytes
            let decrypted = try aes.decrypt(db)
            let decryptedString = String(data: Data(decrypted), encoding: .utf8)
            return decryptedString
        } catch {
            fatalError("could not decrypt "+input)
        }
    }
}
