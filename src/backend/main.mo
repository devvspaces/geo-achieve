import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Types "types";
import Map "mo:map/Map";
import { phash; thash; nhash } "mo:map/Map";
import Vector "mo:vector";
import Blob "mo:base/Blob";
import Error "mo:base/Error";
import Debug "mo:base/Debug";
import Time "mo:base/Time";
import Utils "utils";
import ICRC7 "mo:icrc7-mo/service";
import ICRC7Type "mo:icrc7-mo";
import CandyTypesLib "mo:candy_0_3_0/types";

shared ({ caller }) actor class Backend() {
  type Result<A, B> = Types.Result<A, B>;
  type UserType = Types.UserType;
  type RecipientUser = Types.RecipientUser;
  type CreateRecipientUser = Types.CreateRecipientUser;
  type InstitutionUser = Types.InstitutionUser;
  type CreateInstitutionUser = Types.CreateInstitutionUser;
  type Issuer = Types.Issuer;
  type CertificateType = Types.CertificateType;
  type CertificateMetadata = Types.CertificateMetadata;
  type GeoNFT = Types.GeoNFT;

  stable let user_to_type = Map.new<Principal, UserType>();
  stable let user_to_recipient = Map.new<Principal, RecipientUser>();
  stable let user_to_institution = Map.new<Principal, InstitutionUser>();
  stable let institution_to_issuers = Map.new<Text, Map.Map<Principal, Issuer>>();
  stable let institution_to_certs = Map.new<Text, Vector.Vector<Nat>>();
  stable var tokenCounter = 0;
  stable var acls = Vector.new<Principal>();
  stable var admin = caller;

  var nftActor_ : GeoNFT = actor ("aaaaa-aa");
  stable var nftCanisterId_ : Text = Types.INVALID_CANISTER_ID;

  private func _isAdmin(p : Principal) : Bool {
    Debug.print(Principal.toText(admin));
    Debug.print(Principal.toText(p));
    Debug.print(debug_show (Principal.toText(p) == Principal.toText(admin)));
    Principal.equal(admin, p);
  };

  private func _isAllowed(p : Principal) : Bool {
    if (_isAdmin(p)) {
      return true;
    };
    for (k in Vector.vals(acls)) {
      if (Principal.equal(p, k)) {
        return true;
      };
    };
    return false;
  };

  // Admin: Get acls
  public query func getAcls() : async [Principal] {
    Vector.toArray(acls);
  };

  // Get admin
  public query func getAdmin() : async Principal {
    admin;
  };

  // Admin: Add acls
  public shared ({ caller }) func addAcls(p : Principal) : () {
    assert _isAdmin(caller);
    Vector.add(acls, p);
  };

  // Admin: Remove acls
  public shared ({ caller }) func removeAcls(p : Principal) : async Result<(), Text> {
    assert _isAdmin(caller);
    let newAcls = Vector.new<Principal>();
    if (Vector.contains<Principal>(acls, p, Principal.equal) == false) {
      return #err("Principal not found");
    };
    for (k in Vector.vals(acls)) {
      if (Principal.notEqual(p, k)) {
        Vector.add(newAcls, k);
      };
    };
    acls := newAcls;
    #ok();
  };

  // Admin: Change admin
  public shared ({ caller }) func changeAdmin(newAdmin : Text) {
    assert _isAdmin(caller);
    admin := Principal.fromText(newAdmin);
  };

  // get nft canister id
  public query func get_nft_canister_id() : async Text {
    nftCanisterId_;
  };

  // set nft canister
  public shared ({ caller }) func set_nft_canister(nftCanisterId : Text) : async Result<(), Text> {
    if (_isAllowed(caller) == false) return #err("Not authorized");

    let nftCanister = try {
      #ok(await Utils.createNftActor(nftCanisterId));
    } catch e #err(e);

    switch (nftCanister) {
      case (#ok(nftActor)) {
        nftActor_ := nftActor;
        nftCanisterId_ := nftCanisterId;
        #ok;
      };
      case (#err(e)) {
        #err("Failed to instantiate GepNFT canister from given id(" # nftCanisterId # ") for reason " # Error.message(e));
      };
    };
  };

  public shared ({ caller }) func get_user_type() : async Result<UserType, Text> {
    let callerType = Map.get(user_to_type, phash, caller);
    switch (callerType) {
      case (null) {
        #err("User not found");
      };
      case (?t) {
        #ok(t);
      };
    };
  };

  public shared ({ caller }) func get_recipient_user() : async Result<RecipientUser, Text> {
    let callerRecipient = Map.get(user_to_recipient, phash, caller);
    switch (callerRecipient) {
      case (null) {
        #err("User not found");
      };
      case (?t) {
        #ok(t);
      };
    };
  };

  public func get_recipient_user_by_principal(user : Principal) : async Result<RecipientUser, Text> {
    let callerRecipient = Map.get(user_to_recipient, phash, user);
    switch (callerRecipient) {
      case (null) {
        #err("User not found");
      };
      case (?t) {
        #ok(t);
      };
    };
  };

  public shared ({ caller }) func get_institution_user() : async Result<InstitutionUser, Text> {
    let callerInstitution = Map.get(user_to_institution, phash, caller);
    switch (callerInstitution) {
      case (null) {
        #err("User not found");
      };
      case (?t) {
        #ok(t);
      };
    };
  };

  public func get_institution_user_by_principal(user : Principal) : async Result<InstitutionUser, Text> {
    let callerInstitution = Map.get(user_to_institution, phash, user);
    switch (callerInstitution) {
      case (null) {
        #err("User not found");
      };
      case (?t) {
        #ok(t);
      };
    };
  };

  public func get_issuers(institutionId : Text) : async Result<[Issuer], Text> {
    let issuers = Map.get(institution_to_issuers, thash, institutionId);
    switch (issuers) {
      case (null) {
        #err("Institution not found");
      };
      case (?t) {
        #ok(Iter.toArray(Map.vals(t)));
      };
    };
  };

  public shared ({ caller }) func add_issuer(issuer : Principal, name : Text) : async Result<(), Text> {
    let callerInstitution = Map.get(user_to_institution, phash, caller);
    switch (callerInstitution) {
      case (null) {
        return #err("Unauthorized");
      };
      case (?institution) {
        let issuers = Map.get(institution_to_issuers, thash, institution.id);
        let newIssuer = {
          principal = issuer;
          name = name;
          created_at = Time.now();
        };
        switch (issuers) {
          case (null) {
            let newIssuers = Map.new<Principal, Issuer>();
            Map.set(newIssuers, phash, caller, newIssuer);
            Map.set(institution_to_issuers, thash, institution.id, newIssuers);
          };
          case (?t) {
            Map.set(t, phash, caller, newIssuer);
            Map.set(institution_to_issuers, thash, institution.id, t);
          };
        };
        #ok;
      };
    };
  };

  public shared ({ caller }) func add_recipient_user(user : CreateRecipientUser) : async Result<(), Text> {
    let userType = Map.get(user_to_type, phash, caller);
    if (userType != null) {
      return #err("User already exists");
    };

    let r_user = {
      id = await Utils.uuid();
      name = user.name;
      tagline = user.tagline;
      description = user.description;
      image = user.image;
      linkedin = user.linkedin;
      twitter = user.twitter;
      github = user.github;
      youtube = user.youtube;
      created_at = Time.now();
      updated_at = Time.now();
    };
    Map.set(user_to_type, phash, caller, #Recipient);
    Map.set(user_to_recipient, phash, caller, r_user);
    #ok;
  };

  public shared ({ caller }) func update_recipient_user(user : CreateRecipientUser) : async Result<(), Text> {
    let callerRecipient = Map.get(user_to_recipient, phash, caller);
    switch (callerRecipient) {
      case (null) {
        return #err("User not found");
      };
      case (?t) {
        let updatedUser = {
          id = t.id;
          name = user.name;
          tagline = user.tagline;
          description = user.description;
          image = user.image;
          linkedin = user.linkedin;
          twitter = user.twitter;
          github = user.github;
          youtube = user.youtube;
          created_at = t.created_at;
          updated_at = Time.now();
        };
        Map.set(user_to_recipient, phash, caller, updatedUser);
        #ok;
      };
    };
  };

  public shared ({ caller }) func add_institution_user(user : CreateInstitutionUser) : async Result<(), Text> {
    let userType = Map.get(user_to_type, phash, caller);
    if (userType != null) {
      return #err("User already exists");
    };

    let i_user = {
      id = await Utils.uuid();
      verified = false;
      name = user.name;
      address = user.address;
      description = user.description;
      latitude = user.latitude;
      longitude = user.longitude;
      logo = user.logo;
      linkedin = user.linkedin;
      twitter = user.twitter;
      github = user.github;
      youtube = user.youtube;
      created_at = Time.now();
      updated_at = Time.now();
    };
    Map.set(user_to_type, phash, caller, #Institution);
    Map.set(user_to_institution, phash, caller, i_user);
    #ok;
  };

  public shared ({ caller }) func update_institution_user(user : CreateInstitutionUser) : async Result<(), Text> {
    let callerInstitution = Map.get(user_to_institution, phash, caller);
    switch (callerInstitution) {
      case (null) {
        return #err("User not found");
      };
      case (?t) {
        let updatedUser = {
          id = t.id;
          verified = t.verified;
          name = user.name;
          address = user.address;
          description = user.description;
          latitude = user.latitude;
          longitude = user.longitude;
          logo = user.logo;
          linkedin = user.linkedin;
          twitter = user.twitter;
          github = user.github;
          youtube = user.youtube;
          created_at = t.created_at;
          updated_at = Time.now();
        };
        Map.set(user_to_institution, phash, caller, updatedUser);
        #ok;
      };
    };
  };

  private func _can_issue_institution_cert(user : Principal, institutionId : Text) : async Bool {
    let issuers = Map.get(institution_to_issuers, thash, institutionId);
    switch (issuers) {
      case (null) {};
      case (?t) {
        let issuer = Map.get(t, phash, user);
        if (issuer != null) {
          return true;
        };
      };
    };
    return false;
  };

  public shared ({ caller }) func issue_cert(metadata : CertificateMetadata) : async Result<Nat, Text> {
    let callerInstitution = Map.get(user_to_institution, phash, metadata.institution);
    switch (callerInstitution) {
      case (null) {
        return #err("Unauthorized");
      };
      case (?institution) {
        if (caller != metadata.institution and ((await _can_issue_institution_cert(caller, institution.id)) == false)) {
          return #err("Unauthorized");
        };
        var certKindMeta : CandyTypesLib.CandyShared = #Class([]);
        let certKind = switch (metadata.kind) {
          case (#Degree(x)) {
            certKindMeta := #Class([
              {
                immutable = false;
                name = "major";
                value = #Text(x.major);
              },
              {
                immutable = false;
                name = "years";
                value = #Nat(x.years);
              },
              {
                immutable = false;
                name = "gpa";
                value = #Nat(x.gpa);
              },
            ]);
            "Degree";
          };
          case (#Workshop(x)) {
            certKindMeta := #Class([
              {
                immutable = false;
                name = "duration";
                value = #Text(x.duration);
              },
              {
                immutable = false;
                name = "skills";
                value = #Text(x.skills);
              },
            ]);
            "Workshop";
          };
          case (#Certification(x)) {
            certKindMeta := #Class([
              {
                immutable = false;
                name = "skills";
                value = #Text(x.skills);
              },
            ]);
            "Certification";
          };
          case (#Seminar(x)) {
            certKindMeta := #Class([
              {
                immutable = false;
                name = "duration";
                value = #Text(x.duration);
              },
            ]);
            "Seminar";
          };
        };
        let candyMetadata : CandyTypesLib.CandyShared = #Class([
          {
            immutable = false;
            name = "name";
            value = #Text(metadata.name);
          },
          {
            immutable = false;
            name = "recipient_name";
            value = #Text(metadata.recipient_name);
          },
          {
            immutable = false;
            name = "image";
            value = #Blob(metadata.image);
          },
          {
            immutable = false;
            name = "institution";
            value = #Principal(metadata.institution);
          },
          {
            immutable = false;
            name = "kind";
            value = #Text(certKind);
          },
          {
            immutable = false;
            name = "meta";
            value = certKindMeta;
          },
        ]);
        let tokens : ICRC7Type.SetNFTRequest = [{
          token_id = tokenCounter + 1;
          owner = ?{ owner = metadata.recipient; subaccount = null };
          override = true;
          created_at_time = null;
          memo = ?Text.encodeUtf8("Transfer memo");
          metadata = candyMetadata;
        }];
        let nfts = await nftActor_.icrcX_mint(tokens);
        let nft = nfts[0];
        switch (nft) {
          case (#Ok(tokId)) {
            switch (tokId) {
              case (null) {
                return #err("Failed to mint NFT");
              };
              case (?tokenId) {
                let certs = Map.get(institution_to_certs, thash, institution.id);
                switch (certs) {
                  case (null) {
                    let newCerts = Vector.new<Nat>();
                    Vector.add(newCerts, tokenId);
                    Map.set(institution_to_certs, thash, institution.id, newCerts);
                  };
                  case (?t) {
                    Vector.add(t, tokenId);
                    Map.set(institution_to_certs, thash, institution.id, t);
                  };
                };
                tokenCounter := tokenCounter + 1;
                return #ok(tokenId);
              };
            };
          };
          case (#Err(err)) {
            switch (err) {
              case (#NonExistingTokenId) {
                return #err("Non existing token id");
              };
              case (#TokenExists) {
                return #err("Token already exists");
              };
              case (#TooOld) {
                return #err("Transaction is too old");
              };
              case (#GenericError(e)) {
                return #err("Generic error: " # debug_show (e.error_code) # ", Message: " # e.message);
              };
              case (#CreatedInFuture(e)) {
                return #err("Created in future: " # debug_show (e.ledger_time));
              };
            };
          };
          case (#GenericError(e)) {
            return #err("Generic error: " # debug_show (e.error_code) # ", Message: " # e.message);
          };
        };
      };
    };
  };

  public shared ({ caller }) func get_institution_certs() : async Result<[Nat], Text> {
    let callerInstitution = Map.get(user_to_institution, phash, caller);
    switch (callerInstitution) {
      case (null) {
        #err("Unauthorized");
      };
      case (?institution) {
        let certs = Map.get(institution_to_certs, thash, institution.id);
        switch (certs) {
          case (null) {
            #ok([]);
          };
          case (?t) {
            #ok(Vector.toArray(t));
          };
        };
      };
    };
  };

  public func get_institution_certs_by_id(institutionId : Text) : async Result<[Nat], Text> {
    let certs = Map.get(institution_to_certs, thash, institutionId);
    switch (certs) {
      case (null) {
        #err("Institution not found");
      };
      case (?t) {
        #ok(Vector.toArray(t));
      };
    };
  };
};
