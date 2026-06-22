import Map "mo:core/Map";
import List "mo:core/List";
import AccessControl "mo:caffeineai-authorization/access-control";
import MixinAuthorization "mo:caffeineai-authorization/MixinAuthorization";
import MixinObjectStorage "mo:caffeineai-object-storage/Mixin";
import Documents "./types/documents";
import Knowledge "./types/knowledge";
import Chat "./types/chat";
import Analysis "./types/analysis";
import Dashboard "./types/dashboard";
import Migration "./migration";
import DocumentsApi "./mixins/documents-api";
import KnowledgeApi "./mixins/knowledge-api";
import ChatApi "./mixins/chat-api";
import AnalysisApi "./mixins/analysis-api";
import DashboardApi "./mixins/dashboard-api";
import Seed "./lib/seed";

(with migration = Migration.run)
actor {
  let documents = Map.empty<Nat, Documents.Document>();
  let chunks = Map.empty<Nat, Documents.DocumentChunk>();
  let entities = Map.empty<Nat, Knowledge.Entity>();
  let relationships = Map.empty<Nat, Knowledge.Relationship>();
  let threads = Map.empty<Nat, Chat.ChatThread>();
  let messages = Map.empty<Nat, Chat.ChatMessage>();
  let incidents = Map.empty<Nat, Analysis.IncidentRecord>();
  let findings = Map.empty<Nat, Analysis.ComplianceFinding>();
  let activityLog = Map.empty<Nat, Dashboard.ActivityItem>();

  let nextDocumentId = { var value = 0 };
  let nextChunkId = { var value = 0 };
  let nextEntityId = { var value = 0 };
  let nextRelationshipId = { var value = 0 };
  let nextThreadId = { var value = 0 };
  let nextMessageId = { var value = 0 };
  let nextIncidentId = { var value = 0 };
  let nextCheckId = { var value = 0 };
  let nextAnalysisId = { var value = 0 };
  let nextActivityId = { var value = 0 };

  let accessControlState = AccessControl.initState();
  include MixinObjectStorage();

  include MixinAuthorization(accessControlState, null);


  include DocumentsApi(accessControlState, documents, chunks, nextDocumentId, nextChunkId);
  include KnowledgeApi(accessControlState, entities, relationships, nextEntityId, nextRelationshipId);
  include ChatApi(accessControlState, threads, messages, chunks, entities, relationships, documents, nextThreadId, nextMessageId);
  include AnalysisApi(accessControlState, incidents, findings, entities, relationships, documents, nextIncidentId, nextCheckId, nextAnalysisId);
  include DashboardApi(accessControlState, documents, entities, relationships, threads, incidents, findings, activityLog, nextActivityId);

  // Seed demo data on first initialization
  transient let seedState : Seed.SeedState = {
    documents;
    chunks;
    entities;
    relationships;
    threads;
    messages;
    incidents;
    findings;
    activityLog;
    nextDocumentId;
    nextChunkId;
    nextEntityId;
    nextRelationshipId;
    nextThreadId;
    nextMessageId;
    nextIncidentId;
    nextCheckId;
    nextAnalysisId;
    nextActivityId;
  };
  Seed.seedAll(seedState);
};
