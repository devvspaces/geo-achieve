import Text "mo:base/Text";
import Float "mo:base/Float";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Blob "mo:base/Blob";
import Vector "mo:vector";
import ICRC7Type "mo:icrc7-mo";

module {
  public type Vector<T> = Vector.Vector<T>;
  public type Result<A, B> = Result.Result<A, B>;

  public let INVALID_CANISTER_ID = "invalid!canister!id";

  public type UserType = {
    #Recipient;
    #Institution;
  };

  public type RecipientUser = {
    id : Text;
    name : Text;
    tagline : Text;
    description : Text;
    image : Blob;
    linkedin : ?Text;
    twitter : ?Text;
    github : ?Text;
    youtube : ?Text;
    created_at : Time.Time;
    updated_at : Time.Time;
  };

  public type CreateRecipientUser = {
    name : Text;
    tagline : Text;
    description : Text;
    image : Blob;
    linkedin : ?Text;
    twitter : ?Text;
    github : ?Text;
    youtube : ?Text;
  };

  public type InstitutionUser = {
    id : Text;
    verified : Bool;
    name : Text;
    address : Text;
    description : Text;
    latitude : Float;
    longitude : Float;
    logo : Blob;
    linkedin : ?Text;
    twitter : ?Text;
    github : ?Text;
    youtube : ?Text;
    created_at : Time.Time;
    updated_at : Time.Time;
  };

  public type CreateInstitutionUser = {
    name : Text;
    address : Text;
    description : Text;
    latitude : Float;
    longitude : Float;
    logo : Blob;
    linkedin : ?Text;
    twitter : ?Text;
    github : ?Text;
    youtube : ?Text;
  };

  public type Issuer = {
    principal : Principal;
    name : Text;
    created_at : Time.Time;
  };

  public type CertificateType = {
    #Degree : {
      major : Text;
      years : Nat;
      gpa : Nat;
    };
    #Workshop : {
      duration : Text;
      skills : Text;
    };
    #Certification : {
      skills : Text;
    };
    #Seminar : {
      duration : Text;
    };
  };

  public type CertificateMetadata = {
    name : Text;
    kind : CertificateType;
    image : Blob;
    recipient : Principal;
    recipient_name : Text;
    institution : Principal;
  };

  public type GeoNFT = actor {
    icrcX_mint : shared query (ICRC7Type.SetNFTRequest) -> async [ICRC7Type.SetNFTResult]
  };
};
