import Common "common";
import Storage "mo:caffeineai-object-storage/Storage";

module {
  public type DocumentId = Common.DocumentId;
  public type Timestamp = Common.Timestamp;

  public type DocumentStatus = {
    #uploaded;
    #processing;
    #extracted;
    #chunked;
    #embedded;
    #ready;
    #error;
  };

  public type Document = {
    id : DocumentId;
    owner : Principal;
    filename : Text;
    mimeType : Text;
    blob : Storage.ExternalBlob;
    status : DocumentStatus;
    extractedText : ?Text;
    metadata : DocumentMetadata;
    createdAt : Timestamp;
    updatedAt : Timestamp;
  };

  public type DocumentMetadata = {
    fileSize : Nat;
    pageCount : ?Nat;
    equipmentIds : [Text];
    assetNames : [Text];
    maintenanceEvents : [Text];
    failureTypes : [Text];
    dates : [Text];
    personnel : [Text];
    safetyReferences : [Text];
    regulatoryReferences : [Text];
  };

  public type DocumentChunk = {
    id : Common.ChunkId;
    documentId : DocumentId;
    chunkIndex : Nat;
    content : Text;
    embedding : ?[Float];
    createdAt : Timestamp;
  };

  public type DocumentSummary = {
    id : DocumentId;
    filename : Text;
    mimeType : Text;
    status : DocumentStatus;
    createdAt : Timestamp;
  };
};
