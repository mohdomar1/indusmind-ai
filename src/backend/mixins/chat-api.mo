import Debug "mo:core/Debug";
import Map "mo:core/Map";
import Runtime "mo:core/Runtime";
import AccessControl "mo:caffeineai-authorization/access-control";
import Types "../types/chat";
import Common "../types/common";
import ChatLib "../lib/chat";
import DocumentTypes "../types/documents";
import KnowledgeTypes "../types/knowledge";

mixin (
  accessControlState : AccessControl.AccessControlState,
  threads : Map.Map<Common.ChatThreadId, Types.ChatThread>,
  messages : Map.Map<Common.ChatMessageId, Types.ChatMessage>,
  chunks : Map.Map<Common.ChunkId, DocumentTypes.DocumentChunk>,
  entities : Map.Map<Common.EntityId, KnowledgeTypes.Entity>,
  relationships : Map.Map<Common.RelationshipId, KnowledgeTypes.Relationship>,
  documents : Map.Map<Common.DocumentId, DocumentTypes.Document>,
  nextThreadId : { var value : Nat },
  nextMessageId : { var value : Nat },
) {
  public shared ({ caller }) func createChatThread(title : Text) : async Types.ChatThread {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    let id = nextThreadId.value;
    nextThreadId.value += 1;
    ChatLib.createChatThread(threads, id, caller, title);
  };

  public shared ({ caller }) func sendMessage(
    threadId : Common.ChatThreadId,
    role : Types.MessageRole,
    content : Text,
    sources : [Types.SourceCitation],
    confidence : ?Float,
  ) : async Common.Result<Types.ChatMessage, Common.AppError> {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    let id = nextMessageId.value;
    nextMessageId.value += 1;
    let result = ChatLib.sendMessage(threads, messages, threadId, id, role, content, sources, confidence);

    // Auto-generate AI assistant response for user messages
    switch (result) {
      case (#ok userMsg) {
        if (role == #user) {
          let aiId = nextMessageId.value;
          nextMessageId.value += 1;
          ignore ChatLib.generateAIResponse(
            messages, chunks, entities, relationships, documents,
            threadId, aiId, content,
          );
        };
      };
      case (#err _) {};
    };
    result;
  };

  public query ({ caller }) func getChatThreads() : async [Types.ChatThread] {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    ChatLib.getChatThreads(threads, caller);
  };

  public query ({ caller }) func getChatMessages(threadId : Common.ChatThreadId) : async [Types.ChatMessage] {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    ChatLib.getChatMessages(messages, threadId);
  };
};
