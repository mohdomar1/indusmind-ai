import Principal "mo:core/Principal";

module {
  public type UserId = Principal;
  public type Timestamp = Nat;
  public type DocumentId = Nat;
  public type ChunkId = Nat;
  public type EntityId = Nat;
  public type RelationshipId = Nat;
  public type ChatThreadId = Nat;
  public type ChatMessageId = Nat;
  public type IncidentId = Nat;
  public type ComplianceCheckId = Nat;

  public type Result<T, E> = {
    #ok : T;
    #err : E;
  };

  public type AppError = {
    #notFound;
    #unauthorized;
    #invalidInput;
    #alreadyExists;
    #storageError;
    #processingError;
  };
};
