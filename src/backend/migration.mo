import Map "mo:core/Map";
import AccessControl "mo:caffeineai-authorization/access-control";
import Documents "./types/documents";
import Knowledge "./types/knowledge";
import Chat "./types/chat";
import Analysis "./types/analysis";
import Dashboard "./types/dashboard";

module {
  type OldActor = {
    var documents : Map.Map<Nat, Documents.Document>;
    var chunks : Map.Map<Nat, Documents.DocumentChunk>;
    var entities : Map.Map<Nat, Knowledge.Entity>;
    var relationships : Map.Map<Nat, Knowledge.Relationship>;
    var threads : Map.Map<Nat, Chat.ChatThread>;
    var messages : Map.Map<Nat, Chat.ChatMessage>;
    var incidents : Map.Map<Nat, Analysis.IncidentRecord>;
    var findings : Map.Map<Nat, Analysis.ComplianceFinding>;
    var activityLog : Map.Map<Nat, Dashboard.ActivityItem>;
    var nextDocumentId : { var value : Nat };
    var nextChunkId : { var value : Nat };
    var nextEntityId : { var value : Nat };
    var nextRelationshipId : { var value : Nat };
    var nextThreadId : { var value : Nat };
    var nextMessageId : { var value : Nat };
    var nextIncidentId : { var value : Nat };
    var nextCheckId : { var value : Nat };
    var nextAnalysisId : { var value : Nat };
    var nextActivityId : { var value : Nat };
    var accessControlState : AccessControl.AccessControlState;
  };

  type NewActor = {
    var documents : Map.Map<Nat, Documents.Document>;
    var chunks : Map.Map<Nat, Documents.DocumentChunk>;
    var entities : Map.Map<Nat, Knowledge.Entity>;
    var relationships : Map.Map<Nat, Knowledge.Relationship>;
    var threads : Map.Map<Nat, Chat.ChatThread>;
    var messages : Map.Map<Nat, Chat.ChatMessage>;
    var incidents : Map.Map<Nat, Analysis.IncidentRecord>;
    var findings : Map.Map<Nat, Analysis.ComplianceFinding>;
    var activityLog : Map.Map<Nat, Dashboard.ActivityItem>;
    var nextDocumentId : { var value : Nat };
    var nextChunkId : { var value : Nat };
    var nextEntityId : { var value : Nat };
    var nextRelationshipId : { var value : Nat };
    var nextThreadId : { var value : Nat };
    var nextMessageId : { var value : Nat };
    var nextIncidentId : { var value : Nat };
    var nextCheckId : { var value : Nat };
    var nextAnalysisId : { var value : Nat };
    var nextActivityId : { var value : Nat };
    var accessControlState : AccessControl.AccessControlState;
  };

  public func run(old : OldActor) : NewActor {
    {
      var documents = old.documents;
      var chunks = old.chunks;
      var entities = old.entities;
      var relationships = old.relationships;
      var threads = old.threads;
      var messages = old.messages;
      var incidents = old.incidents;
      var findings = old.findings;
      var activityLog = old.activityLog;
      var nextDocumentId = old.nextDocumentId;
      var nextChunkId = old.nextChunkId;
      var nextEntityId = old.nextEntityId;
      var nextRelationshipId = old.nextRelationshipId;
      var nextThreadId = old.nextThreadId;
      var nextMessageId = old.nextMessageId;
      var nextIncidentId = old.nextIncidentId;
      var nextCheckId = old.nextCheckId;
      var nextAnalysisId = old.nextAnalysisId;
      var nextActivityId = old.nextActivityId;
      var accessControlState = old.accessControlState;
    };
  };
};
