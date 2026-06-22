import Debug "mo:core/Debug";
import Map "mo:core/Map";
import List "mo:core/List";
import Principal "mo:core/Principal";
import Storage "mo:caffeineai-object-storage/Storage";
import Types "../types/documents";
import Common "../types/common";
import Time "mo:core/Time";
import Int "mo:core/Int";
import Text "mo:core/Text";
import Array "mo:core/Array";

module {
  public type Document = Types.Document;
  public type DocumentChunk = Types.DocumentChunk;
  public type DocumentSummary = Types.DocumentSummary;
  public type DocumentStatus = Types.DocumentStatus;
  public type DocumentMetadata = Types.DocumentMetadata;
  public type Result<T> = Common.Result<T, Common.AppError>;

  public func uploadDocument(
    documents : Map.Map<Common.DocumentId, Document>,
    chunks : Map.Map<Common.ChunkId, DocumentChunk>,
    owner : Principal,
    id : Common.DocumentId,
    filename : Text,
    mimeType : Text,
    blob : Storage.ExternalBlob,
    fileSize : Nat,
  ) : Result<Document> {
    let now = Int.abs(Time.now());
    let doc : Document = {
      id;
      owner;
      filename;
      mimeType;
      blob;
      status = #uploaded;
      extractedText = null;
      metadata = {
        fileSize;
        pageCount = null;
        equipmentIds = [];
        assetNames = [];
        maintenanceEvents = [];
        failureTypes = [];
        dates = [];
        personnel = [];
        safetyReferences = [];
        regulatoryReferences = [];
      };
      createdAt = now;
      updatedAt = now;
    };
    documents.add(id, doc);
    #ok doc;
  };

  public func getDocuments(
    documents : Map.Map<Common.DocumentId, Document>,
    owner : Principal,
  ) : [DocumentSummary] {
    let results = List.empty<DocumentSummary>();
    for ((_id, doc) in documents.entries()) {
      if (doc.owner == owner) {
        results.add({
          id = doc.id;
          filename = doc.filename;
          mimeType = doc.mimeType;
          status = doc.status;
          createdAt = doc.createdAt;
        });
      };
    };
    results.toArray();
  };

  public func getDocument(
    documents : Map.Map<Common.DocumentId, Document>,
    id : Common.DocumentId,
  ) : Result<Document> {
    switch (documents.get(id)) {
      case (?doc) { #ok doc };
      case null { #err(#notFound) };
    };
  };

  public func deleteDocument(
    documents : Map.Map<Common.DocumentId, Document>,
    chunks : Map.Map<Common.ChunkId, DocumentChunk>,
    id : Common.DocumentId,
    owner : Principal,
  ) : Result<()> {
    switch (documents.get(id)) {
      case (?doc) {
        if (doc.owner != owner) {
          return #err(#unauthorized);
        };
        // Remove associated chunks
        let docChunkIds = List.empty<Common.ChunkId>();
        for ((cid, chunk) in chunks.entries()) {
          if (chunk.documentId == id) {
            docChunkIds.add(cid);
          };
        };
        for (chunkId in docChunkIds.toArray().vals()) {
          chunks.remove(chunkId);
        };
        documents.remove(id);
        #ok ();
      };
      case null { #err(#notFound) };
    };
  };

  public func extractText(
    documents : Map.Map<Common.DocumentId, Document>,
    id : Common.DocumentId,
    extractedText : Text,
  ) : Result<Document> {
    switch (documents.get(id)) {
      case (?doc) {
        let updated = { doc with extractedText = ?extractedText; status = #extracted; updatedAt = Int.abs(Time.now()) };
        documents.add(id, updated);
        #ok updated;
      };
      case null { #err(#notFound) };
    };
  };

  public func createChunks(
    documents : Map.Map<Common.DocumentId, Document>,
    chunks : Map.Map<Common.ChunkId, DocumentChunk>,
    documentId : Common.DocumentId,
    chunkContents : [Text],
    nextChunkId : { var value : Nat },
  ) : Result<[DocumentChunk]> {
    switch (documents.get(documentId)) {
      case (?doc) {
        let now = Int.abs(Time.now());
        let createdChunks = chunkContents.map<Text, DocumentChunk>(
          func(content) {
            let chunkId = nextChunkId.value;
            nextChunkId.value += 1;
            {
              id = chunkId;
              documentId;
              chunkIndex = chunkId;
              content;
              embedding = null;
              createdAt = now;
            };
          }
        );
        for (chunk in createdChunks.vals()) {
          chunks.add(chunk.id, chunk);
        };
        let updated = { doc with status = #chunked; updatedAt = now };
        documents.add(documentId, updated);
        #ok createdChunks;
      };
      case null { #err(#notFound) };
    };
  };

  public func createEmbedding(
    chunks : Map.Map<Common.ChunkId, DocumentChunk>,
    chunkId : Common.ChunkId,
    embedding : [Float],
  ) : Result<DocumentChunk> {
    switch (chunks.get(chunkId)) {
      case (?chunk) {
        let updated = { chunk with embedding = ?embedding };
        chunks.add(chunkId, updated);
        #ok updated;
      };
      case null { #err(#notFound) };
    };
  };

  public func semanticSearch(
    chunks : Map.Map<Common.ChunkId, DocumentChunk>,
    searchQuery : Text,
    limit : Nat,
  ) : [DocumentChunk] {
    // Simple keyword-based search as fallback since we can't compute embeddings on-chain
    let queryLower = searchQuery.toLower();
    let words = queryLower.split(#char ' ');
    let results = List.empty<DocumentChunk>();
    for ((_id, chunk) in chunks.entries()) {
      let contentLower = chunk.content.toLower();
      var matches = false;
      for (word in words) {
        if (contentLower.contains(#text word)) {
          matches := true;
        };
      };
      if (matches) {
        results.add(chunk);
      };
    };
    let allResults = results.toArray();
    if (allResults.size() > limit) {
      Array.tabulate<DocumentChunk>(limit, func(i) { allResults[i] })
    } else {
      allResults
    };
  };
};
