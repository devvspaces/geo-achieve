import UUID "mo:uuid/UUID";
import Source "mo:uuid/async/SourceV4";
import Text "mo:base/Text";
import Result "mo:base/Result";
import ICRC7 "mo:icrc7-mo/service";
import Types "types";

module {
  type Result<A, B> = Result.Result<A, B>;
  type GeoNFT = Types.GeoNFT;

  public func createNftActor(canisterId : Text) : async GeoNFT {
    actor (canisterId);
  };

  public func uuid() : async Text {
    let g = Source.Source();
    UUID.toText(await g.new());
  };
};
