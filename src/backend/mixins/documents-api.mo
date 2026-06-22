import Debug "mo:core/Debug";
import Map "mo:core/Map";
import Principal "mo:core/Principal";
import Runtime "mo:core/Runtime";
import Storage "mo:caffeineai-object-storage/Storage";
import AccessControl "mo:caffeineai-authorization/access-control";
import Types "../types/documents";
import Common "../types/common";
import DocumentLib "../lib/documents";

mixin (
  accessControlState : AccessControl.AccessControlState,
  documents : Map.Map<Common.DocumentId, Types.Document>,
  chunks : Map.Map<Common.ChunkId, Types.DocumentChunk>,
  nextDocumentId : { var value : Nat },
  nextChunkId : { var value : Nat },
) {
  public shared ({ caller }) func uploadDocument(
    filename : Text,
    mimeType : Text,
    blob : Storage.ExternalBlob,
    fileSize : Nat,
  ) : async Common.Result<Types.Document, Common.AppError> {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    let id = nextDocumentId.value;
    nextDocumentId.value += 1;
    DocumentLib.uploadDocument(documents, chunks, caller, id, filename, mimeType, blob, fileSize);
  };

  public query ({ caller }) func getDocuments() : async [Types.DocumentSummary] {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    DocumentLib.getDocuments(documents, caller);
  };

  public query ({ caller }) func getDocument(id : Common.DocumentId) : async Common.Result<Types.Document, Common.AppError> {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    DocumentLib.getDocument(documents, id);
  };

  public shared ({ caller }) func deleteDocument(id : Common.DocumentId) : async Common.Result<(), Common.AppError> {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    DocumentLib.deleteDocument(documents, chunks, id, caller);
  };

  public shared ({ caller }) func extractText(
    id : Common.DocumentId,
    extractedText : Text,
  ) : async Common.Result<Types.Document, Common.AppError> {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    DocumentLib.extractText(documents, id, extractedText);
  };

  public shared ({ caller }) func createChunks(
    documentId : Common.DocumentId,
    chunkContents : [Text],
  ) : async Common.Result<[Types.DocumentChunk], Common.AppError> {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    DocumentLib.createChunks(documents, chunks, documentId, chunkContents, nextChunkId);
  };

  public shared ({ caller }) func createEmbedding(
    chunkId : Common.ChunkId,
    embedding : [Float],
  ) : async Common.Result<Types.DocumentChunk, Common.AppError> {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    DocumentLib.createEmbedding(chunks, chunkId, embedding);
  };

  public query ({ caller }) func semanticSearch(
    searchQuery : Text,
    limit : Nat,
  ) : async [Types.DocumentChunk] {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    DocumentLib.semanticSearch(chunks, searchQuery, limit);
  };
};
