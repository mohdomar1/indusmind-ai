import Common "common";

module {
  public type ChatThreadId = Common.ChatThreadId;
  public type ChatMessageId = Common.ChatMessageId;
  public type Timestamp = Common.Timestamp;

  public type ChatThread = {
    id : ChatThreadId;
    owner : Principal;
    title : Text;
    createdAt : Timestamp;
    updatedAt : Timestamp;
  };

  public type ChatMessage = {
    id : ChatMessageId;
    threadId : ChatThreadId;
    role : MessageRole;
    content : Text;
    sources : [SourceCitation];
    confidence : ?Float;
    createdAt : Timestamp;
  };

  public type MessageRole = {
    #user;
    #assistant;
  };

  public type SourceCitation = {
    documentId : Common.DocumentId;
    documentName : Text;
    chunkIndex : Nat;
    excerpt : Text;
  };
};
