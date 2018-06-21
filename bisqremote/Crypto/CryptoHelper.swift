//
//  CryptoHelper.swift
//  LionsAttendance
//
//  Created by Mata Prasad Chauhan on 01/11/17.
//

import Foundation
import CryptoSwift

class CryptoHelper{
    
    public static var iv: String = ""// required 16 char secret key
    public static var key = "sdlkghjdsflkg"
    
    public static func encrypt(input:String)->String?{
        do {
            if iv.count != 16 {
                fatalError("iv not 16 characters")
            }
            let encrypted: Array<UInt8> = try AES(key: key, iv: iv, padding: .noPadding).encrypt(Array(input.utf8))
            return encrypted.toBase64()
        } catch {
            fatalError("could not encrypt")
        }
        return nil
    }
    
    public static func decrypt(input:String)->String?{
        do {
            if iv.count != 16 {
                fatalError("iv not 16 characters")
            }
            let d = Data(base64Encoded: input, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)
            if d == nil {
                fatalError("message not Base64")
            }
            let aes: AES = try AES(key: key, iv: iv, padding: .pkcs5)
            let db = d!.bytes
            let decrypted = try aes.decrypt(db)
            return String(data: Data(decrypted), encoding: .utf8)
        } catch {
            print("could not decrypt "+input)
        }
        return nil
    }
}
