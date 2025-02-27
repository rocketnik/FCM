import JWT
import Foundation

struct GAuthPayload: JWTPayload {
    let uid: String
    
    var exp: ExpirationClaim
    var iat: IssuedAtClaim
    var iss: IssuerClaim
    var sub: SubjectClaim
    var scope: String
    var aud: AudienceClaim
    
    static var expirationClaim: ExpirationClaim {
        return ExpirationClaim(value: Date().addingTimeInterval(60 * 60))
    }

    init(iss: String, sub: String, scope: String, aud: String) {
        self.uid = UUID().uuidString
        self.exp = GAuthPayload.expirationClaim
        self.iat = IssuedAtClaim(value: Date())
        self.iss = IssuerClaim(value: iss)
        self.sub = SubjectClaim(value: sub)
        self.scope = scope
        self.aud = AudienceClaim(value: aud)
    }
    
    private init(iss: IssuerClaim, sub: SubjectClaim, scope: String, aud: AudienceClaim) {
        self.uid = UUID().uuidString
        self.exp = GAuthPayload.expirationClaim
        self.iat = IssuedAtClaim(value: Date())
        self.iss = iss
        self.sub = sub
        self.scope = scope
        self.aud = aud
    }

    func verify(using signer: JWTSigner) throws {
        // not used
    }

    var hasExpired: Bool {
        let now = Date().timeIntervalSince1970
        return now >= exp.value.timeIntervalSince1970 - (5 * 60)
    }

    func updated() -> Self {
        GAuthPayload(iss: iss, sub: sub, scope: scope, aud: aud)
    }
}
