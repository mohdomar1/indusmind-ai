import Debug "mo:core/Debug";
import Map "mo:core/Map";
import Types "../types/dashboard";
import Common "../types/common";
import DocumentTypes "../types/documents";
import KnowledgeTypes "../types/knowledge";
import ChatTypes "../types/chat";
import AnalysisTypes "../types/analysis";
import List "mo:core/List";
import Array "mo:core/Array";
import Time "mo:core/Time";
import Int "mo:core/Int";

module {
  public type DashboardStats = Types.DashboardStats;
  public type ActivityItem = Types.ActivityItem;

  public func getDashboardStats(
    documents : Map.Map<Common.DocumentId, DocumentTypes.Document>,
    entities : Map.Map<Common.EntityId, KnowledgeTypes.Entity>,
    relationships : Map.Map<Common.RelationshipId, KnowledgeTypes.Relationship>,
    threads : Map.Map<Common.ChatThreadId, ChatTypes.ChatThread>,
    incidents : Map.Map<Common.IncidentId, AnalysisTypes.IncidentRecord>,
    findings : Map.Map<Common.ComplianceCheckId, AnalysisTypes.ComplianceFinding>,
  ) : DashboardStats {
    var documentsProcessed = 0;
    for ((_, doc) in documents.entries()) {
      if (doc.status == #extracted or doc.status == #chunked) {
        documentsProcessed += 1;
      };
    };
    {
      totalDocuments = documents.size();
      documentsProcessed = documentsProcessed;
      totalEntities = entities.size();
      totalRelationships = relationships.size();
      totalChatThreads = threads.size();
      totalIncidents = incidents.size();
      totalComplianceChecks = findings.size();
      recentUploads = documents.size();
    };
  };

  public func getRecentActivity(
    activityLog : Map.Map<Nat, Types.ActivityItem>,
    limit : Nat,
  ) : [ActivityItem] {
    let entries = activityLog.entries();
    var count = 0;
    let result = List.empty<ActivityItem>();
    for ((_, item) in entries) {
      if (count >= limit) { break };
      result.add(item);
      count += 1;
    };
    result.toArray()
  };

  public func logActivity(
    activityLog : Map.Map<Nat, ActivityItem>,
    activityType : Types.ActivityType,
    description : Text,
    relatedDocumentId : ?Common.DocumentId,
    nextActivityId : { var value : Nat },
  ) : () {
    let id = nextActivityId.value;
    nextActivityId.value += 1;
    let item : ActivityItem = {
      id = id;
      activityType = activityType;
      description = description;
      timestamp = Int.abs(Time.now());
      relatedDocumentId = relatedDocumentId;
    };
    activityLog.add(Nat.compare, id, item);
  };
};
