import Debug "mo:core/Debug";
import Map "mo:core/Map";
import List "mo:core/List";
import Runtime "mo:core/Runtime";
import AccessControl "mo:caffeineai-authorization/access-control";
import Types "../types/dashboard";
import Common "../types/common";
import DashboardLib "../lib/dashboard";
import DocumentTypes "../types/documents";
import KnowledgeTypes "../types/knowledge";
import ChatTypes "../types/chat";
import AnalysisTypes "../types/analysis";

mixin (
  accessControlState : AccessControl.AccessControlState,
  documents : Map.Map<Common.DocumentId, DocumentTypes.Document>,
  entities : Map.Map<Common.EntityId, KnowledgeTypes.Entity>,
  relationships : Map.Map<Common.RelationshipId, KnowledgeTypes.Relationship>,
  threads : Map.Map<Common.ChatThreadId, ChatTypes.ChatThread>,
  incidents : Map.Map<Common.IncidentId, AnalysisTypes.IncidentRecord>,
  findings : Map.Map<Common.ComplianceCheckId, AnalysisTypes.ComplianceFinding>,
  activityLog : Map.Map<Nat, Types.ActivityItem>,
  nextActivityId : { var value : Nat },
) {
  public query ({ caller }) func getDashboardStats() : async Types.DashboardStats {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    DashboardLib.getDashboardStats(documents, entities, relationships, threads, incidents, findings);
  };

  public query ({ caller }) func getRecentActivity(limit : Nat) : async [Types.ActivityItem] {
    if (not AccessControl.hasPermission(accessControlState, caller, #user)) {
      Runtime.trap("Unauthorized");
    };
    DashboardLib.getRecentActivity(activityLog, limit);
  };
};
